import 'dart:developer' as developer;
import 'dart:io';

import 'package:media_core/media_core.dart';
import 'package:pure_live/core/player/core/loopback_stream_relay.dart';
import 'package:pure_live/core/player/core/playback_input_lease.dart';
import 'package:pure_live/domains/live/domain/playback_source_interceptor.dart';

import 'playback_source_transport.dart';

class IngestSourceInterceptor implements PlaybackSourceInterceptor {
  IngestSourceInterceptor({PlaybackSourceTransport? transport}) : _transport = transport ?? PlaybackSourceTransport();

  final PlaybackSourceTransport _transport;
  final List<LoopbackStreamRelay> _relays = <LoopbackStreamRelay>[];

  /// Relays this source through the app instead of letting the player fetch it.
  ///
  /// Windows only for now: the bundled libmpv is what some CDNs refuse, and the
  /// DLL is the Windows build. HLS keeps its existing manifest relay, which
  /// already reaches the player over loopback; FLV had no relay at all, which is
  /// why Douyu's line stayed unplayable while the app itself read 200/video/x-flv.
  static bool shouldRelayThroughApp(PlayerSource source) {
    if (!Platform.isWindows) return false;
    final uri = source.uri;
    if (!const <String>{'http', 'https'}.contains(uri.scheme.toLowerCase())) return false;
    if (uri.host == InternetAddress.loopbackIPv4.address || uri.host == 'localhost') return false;
    return uri.path.toLowerCase().endsWith('.flv');
  }

  @override
  Future<List<PlayerSource>> intercept(PlaybackSourceInterception request) async {
    final List<PlayerSource> sources = request.sources;
    if (sources.isEmpty) return sources;
    final PlayerSource primary = sources.first;
    if (!const <String>{'http', 'https'}.contains(primary.uri.scheme.toLowerCase())) return sources;
    if (shouldRelayThroughApp(primary)) {
      try {
        final relay = await LoopbackStreamRelay.start(
          source: primary.uri,
          headers: primary.headers?.values ?? const <String, String>{},
        );
        _relays.add(relay);
        developer.log('loopback ${primary.uri.host} -> ${relay.inputUri}', name: 'PlaybackIngest');
        return <PlayerSource>[
          primary.copyWith(uri: relay.inputUri, headers: SourceHeaders.empty),
          ...sources.skip(1),
        ];
      } catch (error) {
        developer.log('loopback relay unavailable: $error', name: 'PlaybackIngest');
      }
    }
    final String url = primary.uri.toString();
    final PlaybackInputLease? lease;
    try {
      lease = await _transport.prepare(
        url: url,
        headers: primary.headers?.values ?? const <String, String>{},
        facts: request.streamFacts[url],
        policy: request.sourceQueryPolicies[url],
      );
    } catch (error) {
      developer.log('relay unavailable, playing the upstream directly: $error', name: 'PlaybackIngest');
      return sources;
    }
    if (lease == null || !lease.isUsable) return sources;
    // Host only: a signed live URL carries its token in the query.
    developer.log('relay ${primary.uri.host} -> ${lease.uri}', name: 'PlaybackIngest');
    return <PlayerSource>[primary.copyWith(uri: lease.uri, headers: SourceHeaders.empty), ...sources.skip(1)];
  }

  @override
  Future<void> release() async {
    await _transport.release();
    await _closeRelays();
  }

  @override
  Future<void> close() async {
    await _transport.close();
    await _closeRelays();
  }

  Future<void> _closeRelays() async {
    final relays = List<LoopbackStreamRelay>.from(_relays);
    _relays.clear();
    for (final relay in relays) {
      try {
        await relay.close();
      } catch (error) {
        developer.log('loopback relay close failed: $error', name: 'PlaybackIngest');
      }
    }
  }
}

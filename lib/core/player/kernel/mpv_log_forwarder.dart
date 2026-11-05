import 'dart:async';
import 'dart:developer' as developer;

import 'package:media_core_media_kit/media_core_media_kit.dart' as mk;
import 'package:pure_live/core/network/douyu_diagnose.dart';

final Expando<StreamSubscription<mk.PlayerLog>> _forwarders = Expando<StreamSubscription<mk.PlayerLog>>();
final Expando<StreamSubscription<String>> _errorForwarders = Expando<StreamSubscription<String>>();

void attachMpvLogForwarder(mk.Player player) {
  if (_forwarders[player] != null) return;
  _forwarders[player] = player.stream.log.listen((entry) {
    developer.log('${entry.prefix}/${entry.level}: ${entry.text}', name: 'mpv');
    // A release build has no console, and "opened but never played" and
    // "refused the request" look identical from the outside. mpv's own error
    // lines say which happened, so keep them for the diagnostics file.
    if (entry.level == 'error' || entry.level == 'fatal') {
      DouyuDiagnose.record('mpv-error', <String, Object?>{
        'at': entry.prefix,
        'text': entry.text,
      }, 600);
    }
  });
}

/// Keeps the engine's own error text for the diagnostics file.
///
/// The adapter defers an engine exception into the open that caused it and the
/// caller only ever sees `backendOpenFailed` / `NO_PLAYABLE_STREAM`, so without
/// this the actual reason is discarded before anyone can read it.
void attachEngineErrorRecorder(mk.Player player) {
  if (_errorForwarders[player] != null) return;
  _errorForwarders[player] = player.stream.error.listen((message) {
    DouyuDiagnose.record('engine-error', <String, Object?>{'text': message}, 600);
  });
}

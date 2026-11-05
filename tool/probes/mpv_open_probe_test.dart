@Tags(['probe'])
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pure_live/core/config/settings_service.dart';
import 'package:pure_live/core/models/live_play_quality.dart';
import 'package:pure_live/core/models/live_room.dart';
import 'package:pure_live/core/storage/hive_pref_util.dart';
import 'package:pure_live/get/get.dart';
import 'package:pure_live/shared/platforms/douyu/douyu_site.dart';
import 'package:pure_live/shared/platforms/live_site.dart';

/// Opens a real platform URL with the bundled libmpv, outside the app.
///
/// The app only reports `NO_PLAYABLE_STREAM` after its own sweep gives up, so
/// "mpv cannot read this stream" and "mpv reads it but nothing is presented"
/// look identical. This probe resolves a Douyu play URL through the shipped
/// signing code and hands it straight to libmpv with `vo=null`: if the stream
/// decodes here, the fault is in the app's presentation path, not in mpv or the
/// network.
///
///   PURELIVE_MPV_PROBE=1
///   PURELIVE_MPV_DLL=<path to libmpv-2.dll>
///   PURELIVE_MPV_RESOLVE_DOUYU=<room id>     (or PURELIVE_MPV_URL=<url>)
///   flutter test tool/probes/mpv_open_probe_test.dart
void main() {
  final enabled = Platform.environment['PURELIVE_MPV_PROBE'] == '1';
  final dllPath = Platform.environment['PURELIVE_MPV_DLL'] ?? '';
  final directUrl = Platform.environment['PURELIVE_MPV_URL'] ?? '';
  final douyuRoom = Platform.environment['PURELIVE_MPV_RESOLVE_DOUYU'] ?? '';

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!enabled) return;
    final temp = await Directory.systemTemp.createTemp('mpv-probe-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => temp.path,
    );
    await Hive.openBox<dynamic>('app_settings', bytes: Uint8List(0));
    await HivePrefUtil.init();
    Get.put(SettingsService(), permanent: true);
  });

  tearDownAll(() async {
    if (!enabled) return;
    await Hive.close();
  });

  test('libmpv 能否打开给定地址', () async {
    if (!enabled) {
      // ignore: avoid_print
      print('[mpv-probe] skipped (set PURELIVE_MPV_PROBE=1)');
      return;
    }
    expect(dllPath, isNotEmpty, reason: 'PURELIVE_MPV_DLL 未设置');

    final url = directUrl.isNotEmpty ? directUrl : await _resolveDouyu(douyuRoom);
    expect(url, isNotEmpty, reason: '既没有 URL，也没有解析出斗鱼地址');

    final logPath = '${Directory.systemTemp.path}${Platform.pathSeparator}mpv_probe.log';
    final logFile = File(logPath);
    if (logFile.existsSync()) logFile.deleteSync();

    final mpv = _Mpv(DynamicLibrary.open(dllPath));
    final handle = mpv.create();
    expect(handle.address, isNot(0), reason: 'mpv_create 失败');

    // Headless on purpose: decode is the question, presentation is not.
    mpv.setOption(handle, 'vo', 'null');
    mpv.setOption(handle, 'ao', 'null');
    mpv.setOption(handle, 'idle', 'yes');
    mpv.setOption(handle, 'terminal', 'no');
    mpv.setOption(handle, 'msg-level', 'all=v');
    mpv.setOption(handle, 'log-file', logPath);
    mpv.setOption(handle, 'network-timeout', '15');
    mpv.setOption(handle, 'cache', 'yes');
    // The app sends browser-shaped headers; a CDN that checks Referer would
    // otherwise fail here and hide the real answer.
    mpv.setOption(
      handle,
      'http-header-fields',
      'Referer: https://www.douyu.com/,Origin: https://www.douyu.com,'
          'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    );

    expect(mpv.initialize(handle), 0, reason: 'mpv_initialize 失败');

    final commandResult = mpv.command(handle, <String>['loadfile', url]);
    // ignore: avoid_print
    print('[mpv-probe] loadfile -> $commandResult');
    // ignore: avoid_print
    print('[mpv-probe] url = $url');

    final events = <String>[];
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    var sawVideoConfig = false;
    var ended = '';

    while (DateTime.now().isBefore(deadline) && ended.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final event = mpv.waitEvent(handle, 0.25);
      if (event == null) continue;
      events.add(event);
      if (event.startsWith('MPV_EVENT_VIDEO_RECONFIG')) sawVideoConfig = true;
      if (event.startsWith('MPV_EVENT_END_FILE')) ended = event;
    }

    // Ask mpv what it thinks of the stream: the demuxer or decoder refused here
    // when the sweep only says "no playable stream".
    final idle = mpv.getString(handle, 'idle-active');
    final path = mpv.getString(handle, 'path');
    final width = mpv.getString(handle, 'width');
    final videoFormat = mpv.getString(handle, 'video-format');

    mpv.terminate(handle);

    final log = logFile.existsSync() ? logFile.readAsStringSync() : '';
    // ignore: avoid_print
    print('[mpv-probe] events: ${events.join(' | ')}');
    // ignore: avoid_print
    print('[mpv-probe] idle-active=$idle width=$width format=$videoFormat');
    // ignore: avoid_print
    print('[mpv-probe] path=$path');
    // ignore: avoid_print
    print('[mpv-probe] log start >>>');
    // ignore: avoid_print
    print(_tail(log, 80));
    // ignore: avoid_print
    print('<<< log end');

    expect(sawVideoConfig, isTrue, reason: 'libmpv 没有解出视频参数，见日志');
  }, timeout: const Timeout(Duration(minutes: 3)));
}

Future<String> _resolveDouyu(String room) async {
  if (room.isEmpty) return '';
  final site = DouyuSite();
  final detail = await site.getRoomDetail(LiveRoom(roomId: room, platform: 'douyu'));
  final qualities = await site.getPlayQualites(liveroom: detail);
  final urls = await site.getPlayUrls(
    liveroom: detail,
    quality: qualities.isEmpty ? LivePlayQuality(quality: '原画', sort: 0) : qualities.first,
  );
  // ignore: avoid_print
  print('[mpv-probe] douyu ${detail.liveStatus} ${detail.title} -> ${urls.length} url(s)');
  return urls.isEmpty ? '' : urls.first;
}

String _tail(String text, int lines) {
  final all = const LineSplitter().convert(text);
  return all.length <= lines ? text : all.sublist(all.length - lines).join('\n');
}

/// The slice of the libmpv C API this probe needs.
class _Mpv {
  _Mpv(DynamicLibrary lib)
    : _create = lib.lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>('mpv_create'),
      _initialize = lib.lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>('mpv_initialize'),
      _setOptionString = lib
          .lookupFunction<
            Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
            int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)
          >('mpv_set_option_string'),
      _command = lib
          .lookupFunction<
            Int32 Function(Pointer<Void>, Pointer<Pointer<Utf8>>),
            int Function(Pointer<Void>, Pointer<Pointer<Utf8>>)
          >('mpv_command'),
      _getPropertyString = lib
          .lookupFunction<
            Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
            int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)
          >('mpv_get_property_string'),
      _waitEvent = lib
          .lookupFunction<
            Pointer<_MpvEvent> Function(Pointer<Void>, Double),
            Pointer<_MpvEvent> Function(Pointer<Void>, double)
          >('mpv_wait_event'),
      _terminate = lib.lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
        'mpv_terminate_destroy',
      );

  final Pointer<Void> Function() _create;
  final int Function(Pointer<Void>) _initialize;
  final int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>) _setOptionString;
  final int Function(Pointer<Void>, Pointer<Pointer<Utf8>>) _command;
  final int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>) _getPropertyString;
  final Pointer<_MpvEvent> Function(Pointer<Void>, double) _waitEvent;
  final void Function(Pointer<Void>) _terminate;

  Pointer<Void> create() => _create();

  int initialize(Pointer<Void> handle) => _initialize(handle);

  void setOption(Pointer<Void> handle, String name, String value) {
    final namePtr = name.toNativeUtf8();
    final valuePtr = value.toNativeUtf8();
    final result = _setOptionString(handle, namePtr, valuePtr);
    if (result < 0) {
      // ignore: avoid_print
      print('[mpv-probe] option $name rejected ($result)');
    }
    malloc.free(namePtr);
    malloc.free(valuePtr);
  }

  String getString(Pointer<Void> handle, String name) {
    final namePtr = name.toNativeUtf8();
    final buffer = calloc<Uint8>(512).cast<Utf8>();
    final result = _getPropertyString(handle, namePtr, buffer);
    final value = result < 0 ? '<error $result>' : buffer.toDartString();
    malloc.free(namePtr);
    calloc.free(buffer);
    return value;
  }

  int command(Pointer<Void> handle, List<String> args) {
    final array = calloc<Pointer<Utf8>>(args.length + 1);
    for (var i = 0; i < args.length; i++) {
      array[i] = args[i].toNativeUtf8();
    }
    array[args.length] = nullptr;
    final result = _command(handle, array);
    calloc.free(array);
    return result;
  }

  String? waitEvent(Pointer<Void> handle, double timeout) {
    final event = _waitEvent(handle, timeout);
    if (event == nullptr) return null;
    final id = event.ref.eventId;
    if (id == 0) return null;
    final data = event.ref.data;
    final label = _eventName(id);
    if (id == 2 && data != nullptr) {
      // MPV_EVENT_END_FILE -> mpv_event_end_file { reason, error, ... }
      final reason = data.cast<Int32>().value;
      final error = data.cast<Int32>().elementAt(1).value;
      return '$label(reason=$reason, error=$error)';
    }
    return label;
  }

  void terminate(Pointer<Void> handle) => _terminate(handle);
}

String _eventName(int id) {
  const names = <int, String>{
    1: 'MPV_EVENT_SHUTDOWN',
    2: 'MPV_EVENT_END_FILE',
    3: 'MPV_EVENT_FILE_LOADED',
    6: 'MPV_EVENT_START_FILE',
    8: 'MPV_EVENT_VIDEO_RECONFIG',
    21: 'MPV_EVENT_PROPERTY_CHANGE',
  };
  return names[id] ?? 'MPV_EVENT_$id';
}

final class _MpvEvent extends Struct {
  @Int32()
  external int eventId;

  @Int32()
  external int error;

  @Uint64()
  external int replyUserdata;

  external Pointer<Void> data;
}

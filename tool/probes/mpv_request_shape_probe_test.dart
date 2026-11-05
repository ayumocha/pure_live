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
import 'package:pure_live/shared/platforms/douyin/douyin_site.dart';
import 'package:pure_live/shared/platforms/live_site.dart';

/// Finds which mpv request shape a CDN accepts.
///
/// The app reads the stream with Dart (200, video/x-flv) at the same instant mpv
/// reports the stream unusable, so the refusal is about the request mpv sends,
/// not the URL. This probe resolves a fresh URL through the shipped code and then
/// opens it several ways, printing mpv's own verdict for each.
///
///   PURELIVE_MPV_PROBE=1
///   PURELIVE_MPV_DLL=<path to libmpv-2.dll>
///   PURELIVE_MPV_RESOLVE_DOUYIN=<room id>
///   flutter test tool/probes/mpv_request_shape_probe_test.dart
void main() {
  final enabled = Platform.environment['PURELIVE_MPV_PROBE'] == '1';
  final dllPath = Platform.environment['PURELIVE_MPV_DLL'] ?? '';
  final douyinRoom = Platform.environment['PURELIVE_MPV_RESOLVE_DOUYIN'] ?? '';

  TestWidgetsFlutterBinding.ensureInitialized();

  // The widget binding replaces HttpClient with a 400 responder; these probes
  // must reach the real network to learn what the CDN and mpv actually do.
  HttpOverrides.global = null;

  setUpAll(() async {
    if (!enabled) return;
    final temp = await Directory.systemTemp.createTemp('mpv-shape-');
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

  test('不同请求形态下 mpv 能否打开同一地址', () async {
    if (!enabled) {
      // ignore: avoid_print
      print('[shape-probe] skipped (set PURELIVE_MPV_PROBE=1)');
      return;
    }
    expect(dllPath, isNotEmpty, reason: 'PURELIVE_MPV_DLL 未设置');

    final url = await _resolveDouyin(douyinRoom);
    expect(url, isNotEmpty, reason: '没有解析出抖音地址');

    const browserUa =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/128.0.0.0 Safari/537.36';

    final shapes = <String, Map<String, String>>{
      'default(ffmpeg UA)': <String, String>{},
      'browser UA': <String, String>{'user-agent': browserUa},
      'browser UA + referer': <String, String>{
        'user-agent': browserUa,
        'referrer': 'https://live.douyin.com/',
      },
      'lavf off + http1.1': <String, String>{
        'user-agent': browserUa,
        'demuxer-lavf-o': 'http_persistent=0',
      },
    };

    final results = <String, String>{};
    for (final entry in shapes.entries) {
      results[entry.key] = await _tryOpen(dllPath, url, entry.value);
    }

    for (final entry in results.entries) {
      // ignore: avoid_print
      print('[shape-probe] ${entry.key.padRight(24)} -> ${entry.value}');
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<String> _resolveDouyin(String room) async {
  if (room.isEmpty) return '';
  final site = DouyinSite();
  final detail = await site.getRoomDetail(LiveRoom(roomId: room, platform: 'douyin'));
  final qualities = await site.getPlayQualites(liveroom: detail);
  final urls = await site.getPlayUrls(
    liveroom: detail,
    quality: qualities.isEmpty ? LivePlayQuality(quality: '原画', sort: 0) : qualities.first,
  );
  // ignore: avoid_print
  print('[shape-probe] douyin ${detail.liveStatus} -> ${urls.length} url(s)');
  return urls.isEmpty ? '' : urls.first;
}

Future<String> _tryOpen(String dllPath, String url, Map<String, String> options) async {
  final mpv = _Mpv(DynamicLibrary.open(dllPath));
  final handle = mpv.create();
  if (handle.address == 0) return 'mpv_create failed';

  mpv.setOption(handle, 'vo', 'null');
  mpv.setOption(handle, 'ao', 'null');
  mpv.setOption(handle, 'idle', 'yes');
  mpv.setOption(handle, 'terminal', 'no');
  mpv.setOption(handle, 'network-timeout', '10');
  options.forEach((key, value) => mpv.setOption(handle, key, value));

  if (mpv.initialize(handle) != 0) {
    mpv.terminate(handle);
    return 'mpv_initialize failed';
  }

  mpv.command(handle, <String>['loadfile', url]);
  var video = false;
  var end = '';
  final until = DateTime.now().add(const Duration(seconds: 12));
  while (DateTime.now().isBefore(until) && !video && end.isEmpty) {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final event = mpv.waitEvent(handle, 0.2);
    if (event == null) continue;
    if (event.startsWith('MPV_EVENT_VIDEO_RECONFIG')) video = true;
    if (event.startsWith('MPV_EVENT_END_FILE')) end = event;
  }
  mpv.terminate(handle);
  if (video) return 'video configured';
  return end.isEmpty ? 'no event' : end;
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
      print('[shape-probe] option $name rejected ($result)');
    }
    malloc.free(namePtr);
    malloc.free(valuePtr);
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
    2: 'MPV_EVENT_END_FILE',
    6: 'MPV_EVENT_START_FILE',
    8: 'MPV_EVENT_VIDEO_RECONFIG',
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

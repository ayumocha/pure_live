@Tags(['probe'])
library;

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asks libmpv whether the property writes the app performs before opening a
/// source are accepted, and with which values.
///
/// `applyToSource` writes empty strings for "leave this at the engine default"
/// (`http-proxy`, `demuxer-lavf-format`). If libmpv rejects those, media_kit's
/// `setProperty` throws inside `beforeOpen`, the source is never opened, and the
/// player reports no event at all — which is exactly the failure being chased.
///
///   PURELIVE_MPV_PROPS_PROBE=1
///   PURELIVE_MPV_DLL=<path to libmpv-2.dll>
void main() {
  final enabled = Platform.environment['PURELIVE_MPV_PROPS_PROBE'] == '1';
  final dllPath = Platform.environment['PURELIVE_MPV_DLL'] ?? '';

  test('mpv 接受/拒绝哪些属性写入', () {
    if (!enabled) {
      // ignore: avoid_print
      print('[props-probe] skipped (set PURELIVE_MPV_PROPS_PROBE=1)');
      return;
    }
    final lib = DynamicLibrary.open(dllPath);
    final create = lib.lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>('mpv_create');
    final initialize = lib.lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>(
      'mpv_initialize',
    );
    final setOption = lib
        .lookupFunction<
          Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
          int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)
        >('mpv_set_option_string');
    final setProperty = lib
        .lookupFunction<
          Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
          int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)
        >('mpv_set_property_string');
    final terminate = lib.lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      'mpv_terminate_destroy',
    );

    final handle = create();
    setOption(handle, 'terminal'.toNativeUtf8(), 'no'.toNativeUtf8());
    initialize(handle);

    const cases = <(String, String)>[
      ('http-proxy', ''),
      ('http-proxy', 'DIRECT'),
      ('demuxer-lavf-format', ''),
      ('demuxer-lavf-format', 'hls'),
      ('force-seekable', 'no'),
      ('cache-pause', 'no'),
      ('volume-gain', '0'),
    ];

    for (final entry in cases) {
      final code = setProperty(handle, entry.$1.toNativeUtf8(), entry.$2.toNativeUtf8());
      // ignore: avoid_print
      print('[props-probe] ${entry.$1}="${entry.$2}" -> $code ${code < 0 ? 'REJECTED' : 'ok'}');
    }
    terminate(handle);
  });
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pure_live/get/get.dart';
import 'package:pure_live/player/utils/loudness_compensation_policy.dart';

/// media_kit's current NativePlayer.setProperty does not check libmpv's return
/// code. Read the numerical property back so an unsupported or rejected write
/// becomes a visible, nonfatal binding failure.
Future<void> setVerifiedMpvLoudnessGain(
  Future<void> Function(String name, String value) setProperty,
  Future<String> Function(String name) getProperty,
  String name,
  String value,
) async {
  if (name != 'volume-gain') throw ArgumentError.value(name, 'name');
  await setProperty(name, value);
  final actual = double.tryParse(await getProperty(name));
  final requested = double.parse(value);
  if (actual == null || !actual.isFinite || (actual - requested).abs() > 0.001) {
    throw StateError('MPV volume-gain readback differs: requested $value dB, actual $actual');
  }
}

/// One binding belongs to one native MPV instance. It changes only MPV's
/// source gain property; user volume, mute, streams, and AF are untouched.
class MpvLoudnessBinding {
  MpvLoudnessBinding({
    required RxString mode,
    required Future<void> Function(String name, String value) setProperty,
    this.onFailure,
  }) : _mode = mode,
       _setProperty = setProperty;

  final RxString _mode;
  final Future<void> Function(String name, String value) _setProperty;
  final void Function(Object error, StackTrace stackTrace)? onFailure;

  StreamSubscription<String>? _subscription;
  Completer<void>? _idle;
  bool _running = false;
  bool _disposed = false;
  int _revision = 0;
  LoudnessCompensationMode _desired = LoudnessCompensationMode.off;
  LoudnessCompensationMode _applied = LoudnessCompensationMode.off;
  bool _nativeStateUncertain = false;
  Object? _lastError;

  /// Requested and applied modes differ when libmpv rejected the property.
  Object? get lastError => _lastError;
  LoudnessCompensationMode get appliedMode => _applied;
  LoudnessCompensationMode get requestedMode => _desired;
  bool get isDisposed => _disposed;

  /// Subscribe before applying the saved mode, before the first source opens.
  Future<void> start() {
    if (_disposed) return Future.value();
    _subscription ??= _mode.listen(_requestRaw);
    return _request(normalizeLoudnessCompensationMode(_mode.value));
  }

  void _requestRaw(String rawMode) {
    unawaited(_request(normalizeLoudnessCompensationMode(rawMode)));
  }

  Future<void> _request(LoudnessCompensationMode mode) {
    if (_disposed) return Future.value();
    _desired = mode;
    _revision++;
    if (mode == _applied && !_nativeStateUncertain) _lastError = null;
    if (_running) return _idle!.future;
    _running = true;
    final idle = Completer<void>();
    _idle = idle;
    unawaited(_drain(idle));
    return idle.future;
  }

  Future<void> _drain(Completer<void> idle) async {
    try {
      while (!_disposed && (_desired != _applied || _nativeStateUncertain)) {
        final revision = _revision;
        final target = _desired;
        try {
          _nativeStateUncertain = true;
          await _setProperty('volume-gain', '${loudnessCompensationGainDb(target)}');
          _applied = target;
          _nativeStateUncertain = false;
          _lastError = null;
        } catch (error, stackTrace) {
          if (_disposed) break;
          if (_revision != revision) continue;
          _lastError = error;
          debugPrint('MPV loudness gain failed (${target.name}): $error\n$stackTrace');
          try {
            onFailure?.call(error, stackTrace);
          } catch (callbackError, callbackStack) {
            debugPrint('MPV loudness failure callback failed: $callbackError\n$callbackStack');
          }
          // A rejected property must not enter the player's error/reconnect
          // path. Another setting event can request a fresh transition.
          break;
        }
      }
    } finally {
      _running = false;
      _idle = null;
      idle.complete();
    }
  }

  /// Stop observing and wait for a property command already sent to settle.
  /// The owner then disposes the native player with no later binding writes.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    await _idle?.future;
  }
}

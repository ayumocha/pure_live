import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/get/get.dart';
import 'package:pure_live/player/utils/loudness_compensation_policy.dart';
import 'package:pure_live/player/utils/mpv_loudness_binding.dart';

void main() {
  test('unknown setting is off and presets map to 0/3/6/9 dB', () {
    expect(normalizeLoudnessCompensationMode('invalid'), LoudnessCompensationMode.off);
    expect(loudnessCompensationGainDb(LoudnessCompensationMode.off), 0);
    expect(loudnessCompensationGainDb(LoudnessCompensationMode.gentle), 3);
    expect(loudnessCompensationGainDb(LoudnessCompensationMode.standard), 6);
    expect(loudnessCompensationGainDb(LoudnessCompensationMode.strong), 9);
  });

  test('native readback catches silent rejection, missing value, and NaN', () async {
    Future<void> ignored(String name, String value) async {}

    await setVerifiedMpvLoudnessGain(ignored, (_) async => '6.000000', 'volume-gain', '6');
    await expectLater(setVerifiedMpvLoudnessGain(ignored, (_) async => '0', 'volume-gain', '6'), throwsStateError);
    await expectLater(setVerifiedMpvLoudnessGain(ignored, (_) async => '', 'volume-gain', '6'), throwsStateError);
    await expectLater(setVerifiedMpvLoudnessGain(ignored, (_) async => 'NaN', 'volume-gain', '6'), throwsStateError);
  });

  test('saved active mode is applied before start completes', () async {
    final mode = RxString('standard');
    final writes = <(String, String)>[];
    final binding = MpvLoudnessBinding(mode: mode, setProperty: (name, value) async => writes.add((name, value)));
    await binding.start();
    expect(writes, [('volume-gain', '6')]);
    expect(binding.appliedMode, LoudnessCompensationMode.standard);
    await binding.dispose();
  });

  test('fast changes serialize and converge on the final mode', () async {
    final mode = RxString('off');
    final firstWrite = Completer<void>();
    final writeStarted = Completer<void>();
    final writes = <(String, String)>[];
    final binding = MpvLoudnessBinding(
      mode: mode,
      setProperty: (name, value) async {
        writes.add((name, value));
        if (!writeStarted.isCompleted) {
          writeStarted.complete();
          await firstWrite.future;
        }
      },
    );
    await binding.start();
    mode.value = 'gentle';
    await writeStarted.future;
    mode.value = 'standard';
    mode.value = 'strong';
    await Future<void>.delayed(Duration.zero);
    expect(binding.requestedMode, LoudnessCompensationMode.strong);
    firstWrite.complete();
    await Future<void>.delayed(Duration.zero);

    expect(writes, [('volume-gain', '3'), ('volume-gain', '9')]);
    expect(binding.appliedMode, LoudnessCompensationMode.strong);
    expect(binding.lastError, isNull);
    await binding.dispose();
  });

  test('failure is visible, nonfatal, and later setting recovers', () async {
    final mode = RxString('gentle');
    final writes = <(String, String)>[];
    final failures = <Object>[];
    var failNext = true;
    final binding = MpvLoudnessBinding(
      mode: mode,
      setProperty: (name, value) async {
        writes.add((name, value));
        if (failNext) {
          failNext = false;
          throw StateError('libmpv rejected volume-gain');
        }
      },
      onFailure: (error, _) => failures.add(error),
    );
    await binding.start();
    expect(failures, hasLength(1));
    expect(binding.lastError, isA<StateError>());
    expect(binding.requestedMode, LoudnessCompensationMode.gentle);
    expect(binding.appliedMode, LoudnessCompensationMode.off);

    mode.value = 'standard';
    await Future<void>.delayed(Duration.zero);
    expect(writes, [('volume-gain', '3'), ('volume-gain', '6')]);
    expect(binding.appliedMode, LoudnessCompensationMode.standard);
    expect(binding.lastError, isNull);
    await binding.dispose();
  });

  test('off skips the default write and resets applied gain to zero', () async {
    final mode = RxString('off');
    final writes = <(String, String)>[];
    final binding = MpvLoudnessBinding(mode: mode, setProperty: (name, value) async => writes.add((name, value)));
    await binding.start();
    expect(writes, isEmpty);
    mode.value = 'gentle';
    await Future<void>.delayed(Duration.zero);
    mode.value = 'off';
    await Future<void>.delayed(Duration.zero);
    expect(writes, [('volume-gain', '3'), ('volume-gain', '0')]);
    expect(binding.appliedMode, LoudnessCompensationMode.off);
    await binding.dispose();
  });

  test('off reconciles an uncertain write after a reported failure', () async {
    final mode = RxString('gentle');
    final writes = <(String, String)>[];
    var first = true;
    final binding = MpvLoudnessBinding(
      mode: mode,
      setProperty: (name, value) async {
        writes.add((name, value));
        if (first) {
          first = false;
          throw StateError('readback unavailable after write');
        }
      },
    );
    await binding.start();
    expect(binding.lastError, isA<StateError>());
    mode.value = 'off';
    await Future<void>.delayed(Duration.zero);
    expect(writes, [('volume-gain', '3'), ('volume-gain', '0')]);
    expect(binding.lastError, isNull);
    await binding.dispose();
  });

  test('superseded failed write still resets native gain to the final off mode', () async {
    final mode = RxString('gentle');
    final writeStarted = Completer<void>();
    final finishWrite = Completer<void>();
    final writes = <(String, String)>[];
    var first = true;
    final binding = MpvLoudnessBinding(
      mode: mode,
      setProperty: (name, value) async {
        writes.add((name, value));
        if (first) {
          first = false;
          writeStarted.complete();
          await finishWrite.future;
          throw StateError('readback failed after gain changed');
        }
      },
    );
    final startup = binding.start();
    await writeStarted.future;
    mode.value = 'off';
    finishWrite.complete();
    await startup;
    expect(writes, [('volume-gain', '3'), ('volume-gain', '0')]);
    expect(binding.appliedMode, LoudnessCompensationMode.off);
    expect(binding.lastError, isNull);
    await binding.dispose();
  });

  test('dispose waits for in-flight write and suppresses later writes', () async {
    final mode = RxString('gentle');
    final writeStarted = Completer<void>();
    final finishWrite = Completer<void>();
    final writes = <(String, String)>[];
    final binding = MpvLoudnessBinding(
      mode: mode,
      setProperty: (name, value) async {
        writes.add((name, value));
        writeStarted.complete();
        await finishWrite.future;
      },
    );
    final startup = binding.start();
    await writeStarted.future;
    final disposed = binding.dispose();
    mode.value = 'strong';
    var completed = false;
    disposed.then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    finishWrite.complete();
    await Future.wait([startup, disposed]);
    mode.value = 'off';
    await Future<void>.delayed(Duration.zero);
    expect(writes, [('volume-gain', '3')]);
    expect(binding.isDisposed, isTrue);
  });

  test('players keep independent state and never write user volume or mute', () async {
    final mode = RxString('standard');
    final first = <(String, String)>[];
    final second = <(String, String)>[];
    final firstBinding = MpvLoudnessBinding(mode: mode, setProperty: (name, value) async => first.add((name, value)));
    final secondBinding = MpvLoudnessBinding(mode: mode, setProperty: (name, value) async => second.add((name, value)));
    await Future.wait([firstBinding.start(), secondBinding.start()]);
    expect(first, [('volume-gain', '6')]);
    expect(second, [('volume-gain', '6')]);
    await firstBinding.dispose();
    mode.value = 'strong';
    await Future<void>.delayed(Duration.zero);
    expect(first, [('volume-gain', '6')]);
    expect(second, [('volume-gain', '6'), ('volume-gain', '9')]);
    expect([...first, ...second].every((write) => write.$1 == 'volume-gain'), isTrue);
    expect(secondBinding.appliedMode, LoudnessCompensationMode.strong);
    await secondBinding.dispose();
  });
}

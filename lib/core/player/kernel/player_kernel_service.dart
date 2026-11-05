import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:media_core/media_core.dart';
import 'package:pure_live/core/player/kernel/player_consts.dart';
import 'package:pure_live/core/player/presentation/fullscreen_window.dart';
import 'package:pure_live/core/player/presentation/kernel_floating_window_presenter.dart';
import 'package:pure_live/domains/live/domain/global_player_service.dart';
import 'package:media_core_floating/media_core_floating.dart';
import 'package:media_core_media_kit/media_core_media_kit.dart' hide PlayerConsts;
import 'package:pure_live/core/player/presentation/windows_pip_driver.dart';
import 'package:pure_live/core/player/kernel/owned_input_opener.dart';
import 'package:pure_live/core/player/kernel/mpv_log_forwarder.dart';
import 'package:pure_live/core/network/douyu_diagnose.dart';
import 'package:media_core_ijk_player/media_core_ijk_player.dart';
import 'package:media_core_logging/media_core_logging.dart' as mlog;
import 'package:media_core_mediasession/media_core_mediasession.dart';
import 'package:pure_live/core/player/kernel/loudness_compensation.dart';
import 'package:pure_live/core/player/kernel/media_kit_live_properties.dart';
import 'package:pure_live/core/player/kernel/open_volume.dart';
import 'package:media_core_better_player/media_core_better_player.dart';
import 'package:pure_live/core/config/player_settings_controller.dart';

class PlayerKernelService {
  PlayerKernelService._();

  static final PlayerKernelService instance = PlayerKernelService._();

  static final FloatingDriver floatingDriver = FloatingDriver();

  static mlog.MemoryLogSink? logRing;
  static bool _diagnosticSinkAttached = false;

  PlayerKernel? _kernel;

  PlayerKernel get kernel {
    _kernel ??= _buildKernel();
    return _kernel!;
  }

  PlayerKernel _buildKernel() {
    final kernel = PlayerKernel()
      ..registerBackend(
        MediaKitAdapterFactory(
          playerConfiguration: MediaKitLiveProperties.playerConfiguration(),
          customInputOpener: openOwnedInputOnKernelPlayer,
          beforeOpen: (player, source) async {
            // A throw here aborts the open before libmpv ever sees a loadfile,
            // which leaves no mpv log, no loading event and a source that looks
            // unplayable. Record the step and the error instead of losing them.
            var step = 'attach-log';
            try {
              DouyuDiagnose.record('open-begin', <String, Object?>{
                'uri': source.uri.toString(),
                'headers': source.headers?.values.length ?? 0,
              }, 400);
              attachMpvLogForwarder(player);
              attachEngineErrorRecorder(player);
              step = 'volume';
              final initialVolume = OpenVolume.resolve(source);
              if (initialVolume != null) {
                try {
                  await player.setVolume(initialVolume * 100.0);
                } catch (_) {}
              }
              step = 'source-properties';
              await MediaKitLiveProperties.applyToSource(player, source);
              // Saved loudness gain, if the user enabled it. This runs before the
              // first loadfile, so the room opens already at the chosen level.
              step = 'loudness';
              await MediaKitLiveProperties.applyLoudnessCompensation(player, LoudnessCompensation.savedMode);
              DouyuDiagnose.record('open-prepared', <String, Object?>{'host': source.uri.host});
            } catch (error, stackTrace) {
              DouyuDiagnose.record('open-failed', <String, Object?>{
                'step': step,
                'error': error,
                'stack': stackTrace.toString().split('\n').take(4).join(' | '),
              }, 900);
              rethrow;
            }
          },
          videoControllerConfigurationBuilder: MediaKitLiveProperties.buildVideoControllerConfiguration,
          // The app declares every tuning value it wants; the adapter applies
          // only what it is told.
          configure: MediaKitLiveProperties.applyTo,
        ).registration(),
      );

    if (PlayerConsts.mobileOnlyEnginesAvailable(defaultTargetPlatform)) {
      kernel
        ..registerBackend(const FlvLzcPlayerAdapterFactory().registration())
        ..registerBackend(const BetterPlayerAdapterFactory().registration());
    }

    kernel.attachPresentation(
      PresentationDriverChain(
        bindings: [
          PresentationDriverBinding(
            modes: {PresentationMode.fullscreen, PresentationMode.windowFullscreen},
            driver: fullscreenDriver,
          ),
          PresentationDriverBinding(modes: {PresentationMode.pip}, driver: windowsPipDriver),
          PresentationDriverBinding(modes: {PresentationMode.floating}, driver: floatingDriver),
        ],
      ),
    );
    // The driver ships with a null presenter, so a `floating` request was
    // silently dropped. Install the host surface so any host that calls
    // kernel.enterFloating (the local video player) actually opens a window for
    // that handle. The live room's own floating path never reaches the driver,
    // so this only enables the kernel-driven path.
    floatingDriver.updatePresenter(KernelFloatingWindowPresenter(kernel: kernel, driver: floatingDriver));
    return kernel;
  }

  static Future<void> ensureInitialized() async {
    MediaKitPlayerAdapter.ensureInitialized();
    DouyuDiagnose.record('kernel-init', <String, Object?>{'adapter': 'media_kit'});

    // The desktop chrome asks the window, not a player, whether the picture is
    // compact, and the driver is what makes it compact. Start mirroring it
    // before any player can ask for the mode.
    observeWindowsPipState();

    // Output settings ride two rails: mpv-property changes (hwdec, tuning
    // table, shaders, ao, ...) apply to the live engine through engine
    // options; a render-context change (vo / custom-output switch) needs a
    // same-backend engine rebuild, which preserves source, position and
    // play intent.
    PlayerSettingsController.outputSettingsDispatcher = ({required bool rebuild}) {
      final handle = GlobalPlayerService.instance.player.handle;
      if (handle == null) return;
      if (rebuild) {
        unawaited(handle.rebuildEngine(reason: 'video output settings changed'));
        return;
      }
      unawaited(MediaKitLiveProperties.engineOptions().then((options) => handle.applyEngineOptions(options)));
    };

    // A loudness change is one mpv property write on the engine that is
    // already playing. The handle reports whether the engine took it, and a
    // rejection is remembered for the settings page instead of entering the
    // playback error/reconnect path.
    PlayerSettingsController.loudnessCompensationDispatcher = () {
      final handle = GlobalPlayerService.instance.player.handle;
      if (handle == null) return;
      unawaited(LoudnessCompensation.applyTo(handle));
    };

    logRing = mlog.MediaCoreLog.attachMemorySink(capacity: 500);
    // media_core reports an adapter failure once, with the reason, and then only
    // a summary code reaches the app. Keep the reasons where a device report can
    // carry them.
    if (!_diagnosticSinkAttached) {
      _diagnosticSinkAttached = true;
      mlog.MediaCoreLog.addSink(_forwardKernelRecordToDiagnostics);
    }
    if (!const bool.fromEnvironment('dart.vm.product')) {
      mlog.MediaCoreLog.level = mlog.LogLevel.debug;
    }
    await MediaSessionBootstrap.attachTo(instance.kernel, config: const MediaSessionConfig.video());
  }
}

/// Copies media_core's own warning/error records into the diagnostics file.
void _forwardKernelRecordToDiagnostics(mlog.PlayerLogRecord record) {
  if (record.level != mlog.LogLevel.error &&
      record.level != mlog.LogLevel.warning &&
      record.level != mlog.LogLevel.critical) {
    return;
  }
  DouyuDiagnose.record('kernel', <String, Object?>{
    'at': record.category.name,
    'level': record.level.name,
    'msg': record.message,
  }, 700);
}

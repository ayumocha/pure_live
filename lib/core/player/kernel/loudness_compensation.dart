import 'package:media_core/media_core.dart';
import 'package:pure_live/core/index.dart';

/// Optional source loudness gain for the live engine.
///
/// The gain travels as mpv's own `volume-gain` property: it scales the source
/// before the user's volume and mute controls, so those two stay independent
/// and every source gets the same correction. Nothing here touches the audio
/// filter chain, the track selection or the picture.
enum LoudnessCompensationMode { off, gentle, standard, strong }

/// Unknown or stale strings fall back to [LoudnessCompensationMode.off]: a
/// settings value this build does not understand must never change the audio
/// on its own.
LoudnessCompensationMode normalizeLoudnessCompensationMode(String value) {
  for (final mode in LoudnessCompensationMode.values) {
    if (mode.name == value) return mode;
  }

  return LoudnessCompensationMode.off;
}

/// Source gain in dB for [mode]. `off` still writes `0`, which is what makes
/// turning the feature back off restore the untouched source level.
int loudnessCompensationGainDb(LoudnessCompensationMode mode) => switch (mode) {
  LoudnessCompensationMode.off => 0,
  LoudnessCompensationMode.gentle => 3,
  LoudnessCompensationMode.standard => 6,
  LoudnessCompensationMode.strong => 9,
};

/// Translation key for the mode name shown on the settings page.
String loudnessCompensationLabelKey(LoudnessCompensationMode mode) => 'loudness_compensation_mode_${mode.name}';

/// Translation key for the one-line explanation under each mode.
String loudnessCompensationDescriptionKey(LoudnessCompensationMode mode) =>
    'loudness_compensation_mode_${mode.name}_desc';

/// The mpv property this feature owns. It is the only property the feature
/// writes, so a rejection can be attributed exactly.
const String loudnessCompensationProperty = 'volume-gain';

/// The gain as an engine option, for a live settings change.
EngineOption loudnessCompensationOption(LoudnessCompensationMode mode) =>
    EngineOption(loudnessCompensationProperty, '${loudnessCompensationGainDb(mode)}');

/// The gain as a creation-time property map, so a freshly opened engine is
/// born at the saved level instead of leaking one full-loudness frame.
Map<String, String> loudnessCompensationProperties(LoudnessCompensationMode mode) => <String, String>{
  loudnessCompensationProperty: '${loudnessCompensationGainDb(mode)}',
};

/// `null` when the engine accepted the write (live or staged for the next
/// open). A rejection is reported instead of thrown: an unsupported property
/// must not enter the player's error/reconnect path.
String? loudnessCompensationFailure(EngineOptionReport report, LoudnessCompensationMode mode) {
  final rejected = report.unsupported.any((option) => option.key == loudnessCompensationProperty);

  if (!rejected) return null;

  return 'the engine rejected $loudnessCompensationProperty=${loudnessCompensationGainDb(mode)}';
}

/// Runtime owner of the setting: reads the saved mode, pushes a change to the
/// live engine and remembers a rejection so the settings page can say so.
abstract final class LoudnessCompensation {
  /// Last rejection, or `null` while every write has been accepted. The
  /// settings page listens to this instead of pretending the profile applied.
  static final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);

  /// The mode stored in settings, normalised.
  static LoudnessCompensationMode get savedMode =>
      normalizeLoudnessCompensationMode(SettingsService.to.player.loudnessCompensation.v);

  /// Applies [mode] (default: the saved one) to a live handle.
  ///
  /// [EngineOptionEffect.nextOpen] is deliberate: a gain tweak never justifies
  /// replacing the engine, so an option this instance cannot take live waits
  /// for the next open instead of triggering a rebuild mid-playback. Errors
  /// from the handle are recorded, not rethrown.
  static Future<void> applyTo(PlayerHandle handle, {LoudnessCompensationMode? mode}) async {
    final target = mode ?? savedMode;

    try {
      final report = await handle.applyEngineOptions(
        <EngineOption>[loudnessCompensationOption(target)],
        effect: EngineOptionEffect.nextOpen,
      );

      lastError.value = loudnessCompensationFailure(report, target);
    } catch (error) {
      lastError.value = '$error';
    }
  }
}

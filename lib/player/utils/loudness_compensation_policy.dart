/// Optional source loudness gain for MPV. The user's volume and mute controls
/// remain independent, and the gain applies equally to every source.
enum LoudnessCompensationMode { off, gentle, standard, strong }

LoudnessCompensationMode normalizeLoudnessCompensationMode(String value) {
  for (final mode in LoudnessCompensationMode.values) {
    if (mode.name == value) return mode;
  }
  return LoudnessCompensationMode.off;
}

int loudnessCompensationGainDb(LoudnessCompensationMode mode) => switch (mode) {
  LoudnessCompensationMode.off => 0,
  LoudnessCompensationMode.gentle => 3,
  LoudnessCompensationMode.standard => 6,
  LoudnessCompensationMode.strong => 9,
};

import 'package:remixicon/remixicon.dart';
import 'package:pure_live/core/index.dart';
import 'package:pure_live/core/player/kernel/loudness_compensation.dart';

/// Source loudness compensation: off / gentle / standard / strong.
///
/// The page is reachable on every platform because the property is a plain
/// mpv one; when the running engine refuses it the page says so instead of
/// showing the profile as applied.
class PlayerLoudnessPage extends GetView<SettingsService> {
  const PlayerLoudnessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = normalizeLoudnessCompensationMode(SettingsService.to.player.loudnessCompensation.v);

    return Scaffold(
      appBar: AppBar(title: Text(i18n('loudness_compensation_section'))),
      body: ListView(
        physics: const PureLiveScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(i18n('loudness_compensation_hint'), style: theme.textTheme.bodySmall),
          ),
          for (final mode in LoudnessCompensationMode.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(i18n(loudnessCompensationLabelKey(mode)), style: theme.textTheme.titleMedium),
                  subtitle: Text(
                    i18n(loudnessCompensationDescriptionKey(mode)),
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: current == mode
                      ? Icon(Remix.checkbox_circle_fill, color: theme.colorScheme.primary)
                      : const Icon(Remix.checkbox_blank_circle_line),
                  onTap: () => SettingsService.to.player.loudnessCompensation.v = mode.name,
                ),
              ),
            ),
          ValueListenableBuilder<String?>(
            valueListenable: LoudnessCompensation.lastError,
            builder: (context, error, _) {
              if (error == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(
                  '${i18n('loudness_compensation_unavailable')}: $error',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

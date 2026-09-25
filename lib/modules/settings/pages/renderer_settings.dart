import 'package:flutter/foundation.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/player/utils/player_consts.dart';
import 'package:pure_live/player/utils/mpv_platform_profile.dart';

class RendererSettingsPage extends GetView<SettingsService> {
  const RendererSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = defaultTargetPlatform;
    final available = mpvVideoOutputDriversForPlatform(platform);
    return Scaffold(
      appBar: AppBar(title: Text(i18n('video_output_driver'))),
      body: ListView(
        physics: const PureLiveScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          context.buildGroupTitle(i18n('video_output_driver')),
          context.buildModernCard([
            Obx(
              () => Column(
                children: available.entries.map((item) {
                  final key = item.key;
                  final selected =
                      normalizeMpvVideoOutputDriverForPlatform(controller.player.videoOutputDriver.v, platform) == key;

                  return _RendererTile(
                    title: _getLocalizedName(context, item),
                    selected: selected,
                    onTap: () {
                      controller.player.videoOutputDriver.v = key;
                    },
                  );
                }).toList(),
              ),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLocalizedName(BuildContext context, MapEntry<String, String> item) {
    final bool isZh = Get.locale?.languageCode == 'zh';
    if (!isZh) return item.value;
    final translated = PlayerConsts.videoRenderersList.firstWhere(
      (driver) => driver['key'] == item.key,
      orElse: () => {'nameZh': item.value},
    );
    return translated['nameZh']!;
  }
}

class _RendererTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _RendererTile({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 22,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppTextStyles.t14)),
          ],
        ),
      ),
    );
  }
}

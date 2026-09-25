import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/common/models/live_room.dart';
import 'package:pure_live/common/services/settings/favorite_room_controller.dart';
import 'package:pure_live/common/services/settings/history_controller.dart';
import 'package:pure_live/common/services/settings/player_settings_controller.dart';
import 'package:pure_live/common/services/settings/volume_settings_controller.dart';
import 'package:pure_live/common/services/utils/fork_site_migration.dart';
import 'package:pure_live/common/services/utils/settings_upgrade_migration.dart';
import 'package:pure_live/core/sites.dart';

Map<String, dynamic> room(String platform, {int watched = 1, List<String> tags = const []}) => {
  'platform': platform,
  'roomId': '12345',
  'title': 'saved room',
  'tagIds': tags,
  'lastWatchedAt': watched,
};

void main() {
  test('legacy platform resolves to one canonical site and model identity', () {
    expect(Sites.isSupported(' xhs '), isTrue);
    expect(identical(Sites.of('xhs'), Sites.of('xiaohongshu')), isTrue);
    final legacy = LiveRoom.fromJson(room('xhs'));
    expect(legacy.identityKey, 'xiaohongshu:12345');
    expect(legacy.hasSameIdentity(LiveRoom.fromJson(room('xiaohongshu'))), isTrue);
    expect(legacy.toJson()['platform'], 'xiaohongshu');
  });

  test('startup migrates saved catalog, selection, collections and room settings', () {
    final source = {
      'hotAreasList': ['douyu', 'xhs', 'xiaohongshu'],
      'preferPlatform': 'xhs',
      'favoriteRooms': [
        jsonEncode(room('xhs', tags: ['old'])),
      ],
      'historyRooms': jsonEncode({
        'list': [room('xhs', watched: 12)],
      }),
      'portraitRoomOverrides': jsonEncode({'xhs:12345': 'portrait'}),
      'roomVolumes': jsonEncode({'room_vol_xhs_12345': 0.3}),
    };
    final original = jsonEncode(source);
    final result = SettingsUpgradeMigration.mergeRawSettings(source, []);
    expect(result['hotAreasList'], ['douyu', 'xiaohongshu']);
    expect(result['preferPlatform'], 'xiaohongshu');
    expect(jsonDecode(result['favoriteRooms'] as String)['list'][0]['platform'], 'xiaohongshu');
    expect(jsonDecode(result['historyRooms'] as String)['list'][0]['lastWatchedAt'], 12);
    expect(jsonDecode(result['portraitRoomOverrides'] as String), {'xiaohongshu:12345': 'portrait'});
    expect(jsonDecode(result['roomVolumes'] as String), {'room_vol_xiaohongshu_12345': 0.3});
    expect(jsonEncode(source), original);
    expect(SettingsUpgradeMigration.mergeRawSettings(result, []), result);
  });

  test('mixed old/new aliases merge tags and retain the latest history timestamp', () {
    final input = {
      'list': [
        room('xhs', tags: ['a']),
        room('xiaohongshu', watched: 9, tags: ['b']),
      ],
      'extra': 1,
    };
    final output = ForkSiteMigration.normalize({'historyRooms': input})['historyRooms'] as Map;
    expect(output['extra'], 1);
    final entries = output['list'] as List;
    expect(entries, hasLength(1));
    expect(entries.single['tagIds'], ['a', 'b']);
    expect(entries.single['lastWatchedAt'], 9);
    expect((input['list'] as List), hasLength(2));
  });

  test('backup restoration shares migration for favorites and history', () {
    final favorites = FavoriteRoomController.parseConfig({
      'preferPlatform': 'xhs',
      'hotAreasList': ['xhs'],
      'favoriteRooms': [room('xhs'), room('xiaohongshu')],
    });
    expect(favorites['preferPlatform'], 'xiaohongshu');
    expect(favorites['hotAreasList'], ['xiaohongshu']);
    expect(favorites['favoriteRooms'], hasLength(1));
    final history = HistoryController.extractConfig({
      'history': {
        'historyRooms': [room('xhs')],
      },
    });
    expect((history['historyRooms'] as List).single['platform'], 'xiaohongshu');
    expect(VolumeSettingsController.parseRoomVolumes({'xhs:12345': 0.3, 'xiaohongshu:12345': 0.8}), {
      'xiaohongshu:12345': 0.8,
    });
    expect(VolumeSettingsController.parseRoomVolumes({'room_vol_xhs_12345': 0.3, 'room_vol_xiaohongshu_12345': 0.8}), {
      'room_vol_xiaohongshu_12345': 0.8,
    });
    expect(PlayerSettingsController.parsePortraitRoomOverrides({'xhs:12345': 'portrait'}), {
      'xiaohongshu:12345': 'portrait',
    });
  });

  test('cross-directory aliases retain latest watch time and favorite tags', () {
    final result = SettingsUpgradeMigration.mergeRawSettings(
      {
        'historyRooms': [room('xhs', watched: 1)],
        'favoriteRooms': [
          room('xhs', tags: ['target']),
        ],
      },
      [
        {
          'historyRooms': [room('xiaohongshu', watched: 9)],
          'favoriteRooms': [
            room('xiaohongshu', tags: ['source']),
          ],
        },
      ],
    );
    final history = jsonDecode(result['historyRooms'] as String)['list'] as List;
    expect(history, hasLength(1));
    expect(history.single['lastWatchedAt'], 9);
    final favorites = jsonDecode(result['favoriteRooms'] as String)['list'] as List;
    expect(favorites.single['tagIds'], ['target', 'source']);
  });

  test('malformed values remain invalid instead of bypassing import validation', () {
    for (final raw in [
      '{broken',
      42,
      {
        'list': [room('xhs'), 'not json'],
      },
    ]) {
      expect(ForkSiteMigration.normalize({'favoriteRooms': raw})['favoriteRooms'], raw);
      expect(() => FavoriteRoomController.parseFavoriteLists({'favoriteRooms': raw}), throwsFormatException);
    }
  });
}

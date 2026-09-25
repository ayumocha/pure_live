import 'dart:convert';

import 'package:pure_live/common/models/site_id.dart';

/// Converts the 3.0.7 fork's Xiaohongshu identity at storage/import boundaries.
/// Unknown settings and malformed values are preserved for normal validation.
class ForkSiteMigration {
  static Map<String, dynamic> normalize(Map<String, dynamic> values) {
    final result = Map<String, dynamic>.from(values);
    final catalog = values['hotAreasList'];
    if (catalog is List && catalog.every((value) => value is String)) {
      result['hotAreasList'] = catalog.cast<String>().map(canonicalSiteId).toSet().toList();
    }
    if (values['preferPlatform'] is String) {
      result['preferPlatform'] = canonicalSiteId(values['preferPlatform'] as String);
    }
    for (final key in ['favoriteRooms', 'historyRooms', 'favoriteAreas']) {
      if (values.containsKey(key)) result[key] = _collection(values[key], key);
    }
    for (final key in ['portraitRoomOverrides', 'roomVolumes']) {
      if (values.containsKey(key)) result[key] = normalizeRoomMap(values[key]);
    }
    return result;
  }

  static dynamic normalizeRoomMap(dynamic raw) {
    dynamic decoded = raw;
    if (raw is String) {
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        return raw;
      }
    }
    if (decoded is! Map || decoded.keys.any((key) => key is! String)) return raw;
    final result = Map<String, dynamic>.from(decoded);
    for (final key in decoded.keys.cast<String>()) {
      final String canonical;
      if (key.startsWith('xhs:')) {
        canonical = 'xiaohongshu:${key.substring(4)}';
      } else if (key.startsWith('room_vol_xhs_')) {
        canonical = 'room_vol_xiaohongshu_${key.substring('room_vol_xhs_'.length)}';
      } else {
        continue;
      }
      result.putIfAbsent(canonical, () => decoded[key]);
      result.remove(key);
    }
    return raw is String ? jsonEncode(result) : result;
  }

  static dynamic _collection(dynamic raw, String key) {
    dynamic decoded = raw;
    if (raw is String) {
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        return raw;
      }
    }
    final dynamic entries = decoded is Map ? decoded['list'] : decoded;
    if (entries is! List) return raw;
    final parsed = <Map<String, dynamic>>[];
    for (final entry in entries) {
      dynamic value = entry;
      if (entry is String) {
        try {
          value = jsonDecode(entry);
        } on FormatException {
          return raw;
        }
      }
      if (value is! Map || value.keys.any((key) => key is! String)) return raw;
      parsed.add(Map<String, dynamic>.from(value));
    }
    // Only touch affected lists. This is not a new general-purpose deduper.
    if (!parsed.any(
      (item) => item['platform'] is String && (item['platform'] as String).trim().toLowerCase() == 'xhs',
    )) {
      return raw;
    }
    final result = <Map<String, dynamic>>[];
    final roomIndices = <String, int>{};
    for (final item in parsed) {
      final site = item['platform'];
      if (site is String) item['platform'] = canonicalSiteId(site);
      final identityPart = key == 'favoriteAreas' ? item['areaId'] : item['roomId'];
      final identity = item['platform'] == 'xiaohongshu' && identityPart is String && identityPart.trim().isNotEmpty
          ? identityPart.trim()
          : null;
      final previousIndex = identity == null ? null : roomIndices[identity];
      if (previousIndex == null) {
        if (identity != null) roomIndices[identity] = result.length;
        result.add(item);
        continue;
      }
      final previous = result[previousIndex];
      for (final entry in item.entries) {
        final current = previous[entry.key];
        if (current == null || current == '' || current is List && current.isEmpty) {
          previous[entry.key] = entry.value;
        }
      }
      final oldTags = previous['tagIds'];
      final newTags = item['tagIds'];
      if ((oldTags == null || oldTags is List) && (newTags == null || newTags is List)) {
        if (oldTags != null || newTags != null) {
          final tags = <dynamic>{};
          if (oldTags is List) tags.addAll(oldTags);
          if (newTags is List) tags.addAll(newTags);
          previous['tagIds'] = tags.toList();
        }
      }
      final oldWatch = previous['lastWatchedAt'];
      final newWatch = item['lastWatchedAt'];
      if (newWatch is num && (oldWatch == null || oldWatch is num && newWatch > oldWatch)) {
        previous['lastWatchedAt'] = newWatch;
      }
    }
    final dynamic normalized = decoded is Map ? {...decoded, 'list': result} : result;
    return raw is String ? jsonEncode(normalized) : normalized;
  }
}

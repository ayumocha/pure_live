import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/common/utils/live_short_link_session.dart';
import 'package:pure_live/core/site/xiaohongshu/xiaohongshu_api.dart';
import 'package:pure_live/core/site/xiaohongshu/xiaohongshu_link.dart';
import 'package:pure_live/core/site/xiaohongshu/xiaohongshu_share.dart';
import 'package:pure_live/core/site/xiaohongshu/xiaohongshu_site.dart';

import 'live_short_link_test.dart' as fixtures;

const userId = '6a90256f000000001302240d';
const roomId = '570429070963278308';
const profileUrl = 'https://www.xiaohongshu.com/user/profile/$userId';

String page(Map<String, dynamic> state) =>
    '<script>window.__INITIAL_STATE__=${jsonEncode({'liveStream': state})}</script>';

Map<String, dynamic> liveState() {
  final state = jsonDecode(File('test/fixtures/xiaohongshu/live.json').readAsStringSync()) as Map<String, dynamic>;
  state['userId'] = userId;
  return state;
}

Matcher failure(XiaohongshuFailure kind) =>
    throwsA(isA<XiaohongshuException>().having((error) => error.kind, 'kind', kind));

void main() {
  test('profile links are recognized as user IDs, never room IDs', () {
    expect(XiaohongshuLink.profileUserId('$profileUrl?xsec_token=fixture'), userId);
    expect(XiaohongshuLink.parse(profileUrl), isNull);
    for (final bad in [
      'https://www.xiaohongshu.com.evil.test/user/profile/$userId',
      'https://user@www.xiaohongshu.com/user/profile/$userId',
      'https://www.xiaohongshu.com:8443/user/profile/$userId',
      'https://www.xiaohongshu.com/user/profile/%36a90256f000000001302240d',
      'https://www.xiaohongshu.com/user/profile/$userId/..',
      'https://www.xiaohongshu.com/user/profile/$userId/extra',
      'https://www.xiaohongshu.com/user/profile/$roomId',
    ]) {
      expect(XiaohongshuLink.profileUserId(bad), isNull, reason: bad);
    }
  });

  test('profile SSR requires matching broadcaster and an actual numeric room', () {
    final state = liveState();
    expect(XiaohongshuShare.profileRoomId(page(state), userId: userId), roomId);
    state['roomData']['roomInfo']['roomId'] = int.parse(roomId);
    expect(XiaohongshuShare.profileRoomId(page(state), userId: userId), roomId);
    state['userId'] = 'aaaaaaaaaaaaaaaaaaaaaaaa';
    expect(() => XiaohongshuShare.profileRoomId(page(state), userId: userId), failure(XiaohongshuFailure.identity));
    state['userId'] = userId;
    (state['roomData']['roomInfo'] as Map<String, dynamic>).remove('roomId');
    state['nextRoomInfo'] = {'roomId': roomId};
    expect(() => XiaohongshuShare.profileRoomId(page(state), userId: userId), failure(XiaohongshuFailure.identity));
    state['liveStatus'] = 'end';
    expect(XiaohongshuShare.profileRoomId(page(state), userId: userId), isNull);
  });

  test('profile and short redirect resolve only after verified SSR lookup', () async {
    final fixture = fixtures.ShortLinkFixture((_) async => fixtures.redirect(302, profileUrl));
    final session = LiveShortLinkSession(
      timeout: const Duration(seconds: 1),
      clientFactory: () {
        fixture.created++;
        return Dio()..httpClientAdapter = fixtures.FixtureAdapter(fixture);
      },
    );
    final lookedUp = <String>[];
    Future<String?> lookup(String user) async {
      lookedUp.add(user);
      return XiaohongshuShare.profileRoomId(page(liveState()), userId: user);
    }

    try {
      expect(await XiaohongshuLink.resolve(profileUrl, session: session, profileLookup: lookup), roomId);
      expect(fixture.created, 0);
      expect(
        await XiaohongshuLink.resolve('https://xhslink.com/m/fixture', session: session, profileLookup: lookup),
        roomId,
      );
      expect(fixture.requests.map((request) => request.uri.host), ['xhslink.com']);
      expect(lookedUp, [userId, userId]);
    } finally {
      session.close();
    }
  });

  test('short redirects cannot launder an encoded or foreign profile into lookup', () async {
    for (final target in [
      'https://www.xiaohongshu.com.evil.test/user/profile/$userId',
      'https://www.xiaohongshu.com/user/profile/%36a90256f000000001302240d',
      'https://www.xiaohongshu.com/user/profile/$userId/..',
    ]) {
      final fixture = fixtures.ShortLinkFixture((_) async => fixtures.redirect(302, target));
      final session = LiveShortLinkSession(
        timeout: const Duration(seconds: 1),
        clientFactory: () => Dio()..httpClientAdapter = fixtures.FixtureAdapter(fixture),
      );
      var lookups = 0;
      try {
        expect(
          await XiaohongshuLink.resolve(
            'https://xhslink.com/m/fixture',
            session: session,
            profileLookup: (_) async {
              lookups++;
              return roomId;
            },
          ),
          isNull,
          reason: target,
        );
        expect(lookups, 0);
      } finally {
        session.close();
      }
    }
  });

  test('site resolves a legacy profile to a canonical room and accepts old platform ID', () async {
    final requests = <Uri>[];
    final api = XiaohongshuApi(
      request: (uri, _) async {
        requests.add(uri);
        return (status: 200, body: page(liveState()));
      },
    );
    final site = XiaohongshuSite(api: api);
    final found = await site.searchRooms(profileUrl);
    expect(found.single.roomId, roomId);
    expect(found.single.platform, 'xiaohongshu');
    expect(found.single.userId, anyOf(isNull, isEmpty));
    expect(requests.map((uri) => uri.path), ['/user/profile/$userId', '/livestream/$roomId']);
    expect((await site.getRoomDetail(roomId: roomId, platform: 'xhs')).roomId, roomId);
  });

  test('profile lookup cannot substitute a recommended or mismatched room', () async {
    final state = liveState();
    final api = XiaohongshuApi(
      request: (uri, _) async {
        if (uri.path.startsWith('/user/profile/')) return (status: 200, body: page(state));
        final wrong = liveState();
        wrong['roomData']['roomInfo']['roomId'] = '123';
        return (status: 200, body: page(wrong));
      },
    );
    final site = XiaohongshuSite(api: api);
    await expectLater(site.searchRooms(profileUrl), failure(XiaohongshuFailure.identity));
  });
}

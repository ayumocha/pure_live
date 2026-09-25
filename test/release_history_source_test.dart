import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/common/utils/version_util.dart';
import 'package:pure_live/modules/about/widgets/release_history_repository.dart';
import 'package:pure_live/plugins/race_http.dart';

void main() {
  test('release history probes only the fork official GitHub source', () {
    final raw = VersionUtil.mirror.rawUrl(ReleaseHistoryRepository.releaseAssetPath);
    final urls = ReleaseHistoryRepository.selectSourceUrls(raw: raw);

    expect(VersionUtil.updateOwner, 'ayumocha');
    expect(VersionUtil.updateRepository, 'pure_live');
    expect(urls, ['https://raw.githubusercontent.com/ayumocha/pure_live/master/assets/releases.json']);
    expect(Uri.parse(urls.single).scheme, 'https');
  });

  test('failed official source does not probe a healthy mirror', () async {
    final rawServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final mirrorServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await rawServer.close(force: true);
      await mirrorServer.close(force: true);
    });

    var rawRequests = 0;
    var mirrorRequests = 0;
    rawServer.listen((request) async {
      rawRequests++;
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
    });
    mirrorServer.listen((request) async {
      mirrorRequests++;
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
    });

    final raw = 'http://${rawServer.address.address}:${rawServer.port}/releases.json';
    final mirror = 'http://${mirrorServer.address.address}:${mirrorServer.port}/releases.json';
    final urls = ReleaseHistoryRepository.selectSourceUrls(raw: raw);

    final winner = await HttpOverrides.runZoned(
      () => RaceHttp.findFastestUrl(urls, timeout: const Duration(seconds: 1)),
      createHttpClient: (context) => _RealHttpOverrides().createHttpClient(context)..findProxy = (_) => 'DIRECT',
    );
    expect(winner, isNull);
    expect(rawRequests, 1);
    expect(mirrorRequests, 0, reason: mirror);
  });
}

class _RealHttpOverrides extends HttpOverrides {}

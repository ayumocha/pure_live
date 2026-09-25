import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/modules/about/widgets/release_history_repository.dart';
import 'package:pure_live/plugins/race_http.dart';

void main() {
  test('official update source excludes mirrors before the source probe', () {
    final urls = ReleaseHistoryRepository.selectSourceUrls(
      raw: 'https://raw.example.test/releases.json',
      mirrors: const ['https://mirror.example.test/releases.json', 'https://raw.example.test/releases.json'],
      githubOriginOnly: true,
    );

    expect(urls, ['https://raw.example.test/releases.json']);
  });

  test('accelerated source keeps mirror order and one raw fallback', () {
    final urls = ReleaseHistoryRepository.selectSourceUrls(
      raw: 'https://raw.example.test/releases.json',
      mirrors: const [
        'https://mirror-a.example.test/releases.json',
        'https://raw.example.test/releases.json',
        'https://mirror-b.example.test/releases.json',
        'https://mirror-a.example.test/releases.json',
      ],
      githubOriginOnly: false,
    );

    expect(urls, [
      'https://mirror-a.example.test/releases.json',
      'https://raw.example.test/releases.json',
      'https://mirror-b.example.test/releases.json',
    ]);

    expect(
      ReleaseHistoryRepository.selectSourceUrls(
        raw: 'https://raw.example.test/releases.json',
        mirrors: const ['https://mirror-a.example.test/releases.json'],
        githubOriginOnly: false,
      ),
      ['https://mirror-a.example.test/releases.json', 'https://raw.example.test/releases.json'],
    );
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
    final urls = ReleaseHistoryRepository.selectSourceUrls(raw: raw, mirrors: [mirror], githubOriginOnly: true);

    final winner = await HttpOverrides.runZoned(
      () => RaceHttp.findFastestUrl(urls, timeout: const Duration(seconds: 1)),
      createHttpClient: (context) => _RealHttpOverrides().createHttpClient(context)..findProxy = (_) => 'DIRECT',
    );
    expect(winner, isNull);
    expect(rawRequests, 1);
    expect(mirrorRequests, 0);
  });
}

class _RealHttpOverrides extends HttpOverrides {}

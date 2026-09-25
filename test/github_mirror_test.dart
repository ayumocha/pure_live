import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/common/utils/githup_mirror.dart';

void main() {
  test('mirror list is ordered, unique, and keeps direct GitHub first', () {
    final urls = GitHubMirror(owner: 'owner', repo: 'repo', branch: 'main').mirrors('assets/config.json');

    expect(urls.first, 'https://raw.githubusercontent.com/owner/repo/main/assets/config.json');
    expect(urls.toSet(), hasLength(urls.length));
    expect(urls, everyElement(startsWith('https://')));
  });

  test('runtime configuration, update and font sources exclude the blocked mirror', () {
    for (final source in <({String owner, String repo, String path})>[
      (owner: 'liuchuancong', repo: 'pure_live', path: 'assets/play_config.json'),
      (owner: 'ayumocha', repo: 'pure_live', path: 'assets/version.json'),
      (owner: 'ayumocha', repo: 'pure_live', path: 'assets/releases.json'),
      (owner: 'liuchuancong', repo: 'fonts', path: 'font.ttf'),
    ]) {
      final urls = GitHubMirror(owner: source.owner, repo: source.repo).mirrors(source.path);

      expect(urls, isNotEmpty);
      expect(
        urls.map((url) => Uri.parse(url).host),
        isNot(contains('v6.gh-proxy.org')),
        reason: '${source.repo}/${source.path}',
      );
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/common/utils/githup_mirror.dart';
import 'package:pure_live/common/utils/version_util.dart';

void main() {
  test('existing mirror API returns only the official GitHub raw URL', () {
    final urls = GitHubMirror(owner: 'owner', repo: 'repo', branch: 'main').mirrors('assets/config.json');

    expect(urls, ['https://raw.githubusercontent.com/owner/repo/main/assets/config.json']);
    expect(() => urls.add('https://example.test/config.json'), throwsUnsupportedError);
  });

  test('runtime configuration, version, release history and fonts use GitHub only', () {
    for (final source in <({String owner, String repo, String path})>[
      (owner: 'liuchuancong', repo: 'pure_live', path: 'assets/play_config.json'),
      (owner: 'ayumocha', repo: 'pure_live', path: 'assets/version.json'),
      (owner: 'ayumocha', repo: 'pure_live', path: 'assets/releases.json'),
      (owner: 'liuchuancong', repo: 'fonts', path: 'font.ttf'),
    ]) {
      final urls = GitHubMirror(owner: source.owner, repo: source.repo).mirrors(source.path);

      expect(urls, ['https://raw.githubusercontent.com/${source.owner}/${source.repo}/master/${source.path}']);
      expect(Uri.parse(urls.single).scheme, 'https');
    }
  });

  test('version check uses one official GitHub candidate', () {
    expect(VersionUtil.versionSourceUrls, [
      'https://raw.githubusercontent.com/ayumocha/pure_live/master/assets/version.json',
    ]);
  });
}

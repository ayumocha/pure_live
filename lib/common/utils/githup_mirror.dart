class GitHubMirror {
  final String owner;
  final String repo;
  final String branch;

  GitHubMirror({required this.owner, required this.repo, this.branch = 'master'});

  String rawUrl(String filePath) {
    return 'https://raw.githubusercontent.com/$owner/$repo/$branch/$filePath';
  }

  /// Keep the existing caller API while limiting runtime sources to GitHub.
  List<String> mirrors(String filePath) {
    return List.unmodifiable([rawUrl(filePath)]);
  }
}

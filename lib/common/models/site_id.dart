/// Canonical platform identity for current routes and older fork backups.
String canonicalSiteId(String? value) {
  final id = value?.trim().toLowerCase() ?? '';
  return id == 'xhs' ? 'xiaohongshu' : id;
}

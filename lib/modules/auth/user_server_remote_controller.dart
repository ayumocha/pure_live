import 'dart:async';

import 'package:pure_live/common/index.dart';
import 'package:pure_live/core/common/log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pure_live/modules/auth/auth_controller.dart';
import 'package:pure_live/modules/auth/models/user_item.dart';
import 'package:pure_live/modules/auth/utils/firebase_manager.dart';

class UserServerRemoteController extends ServerRemotePageController<UserItem> {
  final rxSearchKeyword = "".obs;
  String searchKeyword = "";
  late bool isSuperAdmin;
  DocumentSnapshot? lastDocument;

  final adminCount = 0.obs;
  final managerCount = 0.obs;
  final userCount = 0.obs;

  Worker? _searchWorker;
  Timer? _searchTimer;
  int _searchVersion = 0;

  String get currentUserUid => Get.find<AuthController>().user!.uid;

  // Keep cloud I/O separate from cursor ownership so failed or late requests
  // can be exercised without a Firebase application in lifecycle tests.
  Future<List<String>> readCloudUserIds() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Map<String, String>> readCloudRoles(List<String>? uids) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('permissions');
    if (uids != null) query = query.where(FieldPath.documentId, whereIn: uids);
    final snapshot = await query.get();
    return {
      for (final doc in snapshot.docs)
        if ((doc.data()['role'] as String?)?.trim().isNotEmpty == true) doc.id: (doc.data()['role'] as String).trim(),
    };
  }

  Future<List<DocumentSnapshot>> readCloudUsers({
    required int limitCount,
    required String keyword,
    required DocumentSnapshot? after,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .orderBy('email')
        .limit(limitCount);
    if (keyword.isNotEmpty) {
      final start = keyword.toLowerCase();
      final end = start.substring(0, start.length - 1) + String.fromCharCode(start.codeUnitAt(start.length - 1) + 1);
      query = query.where('email', isGreaterThanOrEqualTo: start).where('email', isLessThan: end);
    }
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<Map<String, Map<String, dynamic>>> readCloudPermissionData(List<String> uids) async {
    final permissions = <String, Map<String, dynamic>>{};
    for (var i = 0; i < uids.length; i += 30) {
      final batch = uids.skip(i).take(30);
      final results = await Future.wait(
        batch.map((uid) => FirebaseFirestore.instance.collection('permissions').doc(uid).get()),
      );
      for (final permission in results) {
        if (permission.exists) permissions[permission.id] = permission.data() ?? {};
      }
    }
    return permissions;
  }

  Future<void> writeCloudUser(String docId, Map<String, dynamic> updateData) =>
      FirebaseFirestore.instance.collection('users').doc(docId).update(updateData);

  @override
  void onInit() {
    super.onInit();

    isSuperAdmin = FirebaseManager.getInstance().isAdmin();

    _fetchGlobalStats();

    _searchWorker = ever(rxSearchKeyword, (String keyword) {
      if (isClosed) return;

      final version = ++_searchVersion;
      _searchTimer?.cancel();

      _searchTimer = Timer(const Duration(milliseconds: 500), () => unawaited(_commitSearch(keyword, version)));
    });

    // BasePageView does not trigger the initial request.
    if (list.isEmpty && totalCount.value == null) {
      unawaited(refreshData());
    }
  }

  @override
  void onClose() {
    _searchVersion++;
    _searchTimer?.cancel();
    _searchWorker?.dispose();
    super.onClose();
  }

  /// The only entry point allowed to reset the cursor. The base class internally
  /// may call `fetchNetworkData` multiple times while assembling a single page,
  /// so its `page` argument does not represent "the user navigated to page N".
  /// Resetting based on `page == 1` inside `fetchNetworkData` would be incorrect.
  @override
  Future<void> refreshData() async {
    if (isClosed) return;
    while (activePageOperation != null && !isClosed) {
      await activePageOperation;
    }
    if (isClosed) return;
    lastDocument = null;
    await super.refreshData();
  }

  Future<void> _commitSearch(String keyword, int version) async {
    while (!isClosed && version == _searchVersion) {
      final active = activePageOperation;
      if (active == null) break;
      await active;
    }

    if (isClosed || version != _searchVersion || keyword == searchKeyword) {
      return;
    }

    // Only the latest still-valid search intent may reset the directory.
    searchKeyword = keyword;
    await refreshData();
  }

  /// Global statistics include users without a permissions document.
  Future<void> _fetchGlobalStats() async {
    if (isClosed) return;

    try {
      final userIds = await readCloudUserIds();
      if (isClosed) return;
      final permissionRoles = await readCloudRoles(null);
      if (isClosed) return;

      var admin = 0;
      var manager = 0;
      var user = 0;

      for (final uid in userIds) {
        final role = permissionRoles[uid] ?? 'user';

        switch (role) {
          case 'admin':
            admin++;
            break;
          case 'manager':
            manager++;
            break;
          default:
            user++;
            break;
        }
      }

      if (isClosed) return;

      adminCount.value = admin;
      managerCount.value = manager;
      userCount.value = user;
      totalCount.value = userIds.length;
    } catch (e, stackTrace) {
      if (isClosed) return;
      Log.e('[UserMgr] failed to fetch global stats: $e', stackTrace);
    }
  }

  /// Assemble one visible page. Only commit the cloud cursor after every
  /// corresponding permissions read succeeds and the controller is still live.
  @override
  Future<List<UserItem>> fetchNetworkData(int page, int pageSize) async {
    if (isClosed) return [];

    final visibleRoles = FirebaseManager.getInstance().visibleRoles();
    if (visibleRoles.isEmpty) return [];

    final keyword = searchKeyword;
    var cursor = lastDocument;
    final selfUid = currentUserUid;
    final items = <UserItem>[];
    // A batch can contain only the current user or hidden roles. Keep reading
    // until a visible page is assembled or the cloud collection is exhausted;
    // returning an empty filtered batch makes the base pager stop early.
    while (items.length < pageSize) {
      final needed = pageSize - items.length;
      final rawDocs = await readCloudUsers(limitCount: needed, keyword: keyword, after: cursor);
      if (isClosed) return [];
      if (rawDocs.isEmpty) break;

      final nextCursor = rawDocs.last;
      final userDocs = rawDocs.where((doc) => doc.id != selfUid).toList(growable: false);
      if (userDocs.isNotEmpty) {
        final permissions = await readCloudPermissionData(userDocs.map((doc) => doc.id).toList(growable: false));
        if (isClosed) return [];

        for (final doc in userDocs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final permissionData = permissions[doc.id];
          final rawRole = permissionData?['role'];
          final role = rawRole is String && rawRole.trim().isNotEmpty ? rawRole.trim() : 'user';
          if (!visibleRoles.contains(role)) continue;
          final canUpload = permissionData?['canUpload'] != null
              ? permissionData!['canUpload'] != false
              : data['canUpload'] != false;
          items.add(UserItem(uid: doc.id, email: (data['email'] as String?) ?? '', canUpload: canUpload, role: role));
        }
      }

      cursor = nextCursor;
      if (rawDocs.length < needed) break;
    }

    if (isClosed) return [];
    lastDocument = cursor;
    items.sort((a, b) {
      final roleOrder = (FirebaseManager.roleWeights[a.role] ?? 2).compareTo(FirebaseManager.roleWeights[b.role] ?? 2);
      return roleOrder != 0 ? roleOrder : a.email.compareTo(b.email);
    });
    return items;
  }

  Future<void> refreshByKeyword(String keyword) async {
    if (isClosed || keyword == rxSearchKeyword.value) return;

    _searchVersion++;
    _searchTimer?.cancel();
    rxSearchKeyword.value = keyword;
  }

  Future<void> onConfigSaved(String docId, Map<String, dynamic> updateData) async {
    if (isClosed) return;

    await writeCloudUser(docId, updateData);

    if (isClosed) return;

    await refreshData();
  }
}

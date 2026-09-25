import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/get/get.dart';
import 'package:pure_live/modules/remote_receiver/remote_sync_service.dart';
import 'package:pure_live/routes/app_pages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.deleteAll(force: true);
    Get.reset();
  });

  test('unpaired remote sync has no route, server, discovery, or settings transfer', () async {
    Get.testMode = true;
    expect(AppPages.routes.any((route) => route.name == '/remote_sync'), isFalse);

    // Get.put calls onInit. An unpaired service must not open a listener there
    // or when another caller explicitly invokes its public entry points.
    final service = Get.put(RemoteSyncService());
    await service.start();
    await service.startServer();
    expect(await service.startDiscovery(), isFalse);
    expect(service.isServerRunning.value, isFalse);
    expect(service.isDiscovering.value, isFalse);

    // No BackupController is registered: attempting to send settings would
    // fail if the disabled path were allowed to reach the export call.
    expect(await service.syncToAddress('127.0.0.1', 9), isFalse);
    expect(await service.getRemoteSettings('127.0.0.1', 9), isNull);
    expect(service.isSyncing.value, isFalse);
    await service.stop();
  });
}

import 'dart:async';

import '../sync/sync_orchestrator.dart';
import '../../data/local/app_database.dart';
import '../../data/seed/seed_installer.dart';

class BootstrapCoordinator {
  const BootstrapCoordinator({
    required this.db,
    this.seedInstaller = const SeedInstaller(),
    this.syncOrchestratorFactory = _defaultSyncOrchestratorFactory,
  });

  final AppDatabase db;
  final SeedInstaller seedInstaller;
  final SyncOrchestrator Function(AppDatabase db) syncOrchestratorFactory;

  Future<BootstrapResult> run() async {
    final meta = await db.select(db.snapshotMeta).get();
    final installedSeed = await seedInstaller.installIfNeeded(db);

    // Remote sync is independent from bundled seed install/update:
    // startupSync() itself decides whether to refresh based on RefreshPolicy.
    unawaited(syncOrchestratorFactory(db).startupSync());

    return BootstrapResult(
      hasSnapshot: meta.isNotEmpty || installedSeed,
      installedSeed: installedSeed,
      syncScheduled: true,
    );
  }
}

SyncOrchestrator _defaultSyncOrchestratorFactory(AppDatabase db) => SyncOrchestrator(db: db);

class BootstrapResult {
  const BootstrapResult({
    required this.hasSnapshot,
    required this.installedSeed,
    required this.syncScheduled,
  });

  final bool hasSnapshot;
  final bool installedSeed;
  final bool syncScheduled;
}


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

  /// [onProgress] is called with a monotonically increasing fraction in
  /// `[0, 1]` as bootstrap proceeds, ending at exactly `1.0`. Reporting is
  /// coarse (3 stages) rather than byte-level, since installing the bundled
  /// seed has no finer-grained progress hook today (`SeedInstaller` exposes
  /// a single opaque `Future<bool>`) — this replaces Splash's previous
  /// simulated timer with real, if coarse, progress.
  Future<BootstrapResult> run({
    void Function(double fraction)? onProgress,
  }) async {
    onProgress?.call(0.0);
    final meta = await db.select(db.snapshotMeta).get();

    onProgress?.call(0.3);
    final installedSeed = await seedInstaller.installIfNeeded(db);

    onProgress?.call(0.9);
    // Remote sync is independent from bundled seed install/update:
    // startupSync() itself decides whether to refresh based on RefreshPolicy.
    unawaited(syncOrchestratorFactory(db).startupSync());

    onProgress?.call(1.0);
    return BootstrapResult(
      hasSnapshot: meta.isNotEmpty || installedSeed,
      installedSeed: installedSeed,
      syncScheduled: true,
    );
  }
}

SyncOrchestrator _defaultSyncOrchestratorFactory(AppDatabase db) =>
    SyncOrchestrator(db: db);

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

import '../../data/local/snapshot_repository.dart';

class RefreshPolicy {
  const RefreshPolicy({
    this.maxSnapshotAge = const Duration(hours: 6),
  });

  final Duration maxSnapshotAge;

  Future<bool> shouldRefresh(SnapshotRepository snapshotRepository) async {
    final current = await snapshotRepository.getCurrentMeta();
    if (current == null) return true;

    final fetchedAt = DateTime.fromMillisecondsSinceEpoch(current.fetchedAtMs);
    final age = DateTime.now().difference(fetchedAt);
    return age >= maxSnapshotAge;
  }
}


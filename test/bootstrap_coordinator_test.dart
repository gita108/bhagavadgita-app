import 'package:bhagavadgita_book/app/bootstrap/bootstrap_coordinator.dart';
import 'package:bhagavadgita_book/data/local/app_database.dart';
import 'package:bhagavadgita_book/data/seed/seed_installer.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bypasses the real bundled-seed asset (not available/needed in a unit
/// test) — only the progress-reporting contract is under test here.
class _FakeSeedInstaller extends SeedInstaller {
  const _FakeSeedInstaller();

  @override
  Future<bool> installIfNeeded(AppDatabase db) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return true;
  }
}

void main() {
  test('run reports monotonically increasing progress reaching 1.0', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final coordinator = BootstrapCoordinator(
      db: db,
      seedInstaller: const _FakeSeedInstaller(),
    );

    final progressValues = <double>[];
    final result = await coordinator.run(onProgress: progressValues.add);

    expect(progressValues, isNotEmpty);
    expect(progressValues.first, 0.0);
    expect(progressValues.last, 1.0);
    for (var i = 1; i < progressValues.length; i++) {
      expect(progressValues[i], greaterThanOrEqualTo(progressValues[i - 1]));
    }
    expect(result.installedSeed, isTrue);
    expect(result.hasSnapshot, isTrue);

    await db.close();
  });

  test('run works with no onProgress callback supplied', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final coordinator = BootstrapCoordinator(
      db: db,
      seedInstaller: const _FakeSeedInstaller(),
    );

    final result = await coordinator.run();
    expect(result.installedSeed, isTrue);

    await db.close();
  });
}

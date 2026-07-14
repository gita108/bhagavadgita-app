import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // Uses IndexedDB under the hood.
    return WebDatabase('bhagavadgita');
  });
}


import 'package:drift/drift.dart';

class AudioTracks extends Table {
  TextColumn get sourceUrl => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get artist => text().withDefault(const Constant(''))();
  TextColumn get album => text().withDefault(const Constant(''))();
  TextColumn get mimeType => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get artworkUri => text().nullable()();
  BlobColumn get audioData => blob().nullable()();
  TextColumn get compression => text().nullable()();
  IntColumn get originalBytes => integer().withDefault(const Constant(0))();
  IntColumn get storedBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAccessedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sourceUrl};
}

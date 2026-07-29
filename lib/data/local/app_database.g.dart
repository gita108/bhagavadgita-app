// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SnapshotMetaTable extends SnapshotMeta
    with TableInfo<$SnapshotMetaTable, SnapshotMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMsMeta = const VerificationMeta(
    'fetchedAtMs',
  );
  @override
  late final GeneratedColumn<int> fetchedAtMs = GeneratedColumn<int>(
    'fetched_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    fetchedAtMs,
    source,
    schemaVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshot_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnapshotMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('fetched_at_ms')) {
      context.handle(
        _fetchedAtMsMeta,
        fetchedAtMs.isAcceptableOrUnknown(
          data['fetched_at_ms']!,
          _fetchedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMsMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnapshotMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      fetchedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at_ms'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $SnapshotMetaTable createAlias(String alias) {
    return $SnapshotMetaTable(attachedDatabase, alias);
  }
}

class SnapshotMetaData extends DataClass
    implements Insertable<SnapshotMetaData> {
  final int id;
  final String contentHash;
  final int fetchedAtMs;
  final String source;
  final int schemaVersion;
  const SnapshotMetaData({
    required this.id,
    required this.contentHash,
    required this.fetchedAtMs,
    required this.source,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['fetched_at_ms'] = Variable<int>(fetchedAtMs);
    map['source'] = Variable<String>(source);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  SnapshotMetaCompanion toCompanion(bool nullToAbsent) {
    return SnapshotMetaCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      fetchedAtMs: Value(fetchedAtMs),
      source: Value(source),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory SnapshotMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotMetaData(
      id: serializer.fromJson<int>(json['id']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      fetchedAtMs: serializer.fromJson<int>(json['fetchedAtMs']),
      source: serializer.fromJson<String>(json['source']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentHash': serializer.toJson<String>(contentHash),
      'fetchedAtMs': serializer.toJson<int>(fetchedAtMs),
      'source': serializer.toJson<String>(source),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  SnapshotMetaData copyWith({
    int? id,
    String? contentHash,
    int? fetchedAtMs,
    String? source,
    int? schemaVersion,
  }) => SnapshotMetaData(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    fetchedAtMs: fetchedAtMs ?? this.fetchedAtMs,
    source: source ?? this.source,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  SnapshotMetaData copyWithCompanion(SnapshotMetaCompanion data) {
    return SnapshotMetaData(
      id: data.id.present ? data.id.value : this.id,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      fetchedAtMs: data.fetchedAtMs.present
          ? data.fetchedAtMs.value
          : this.fetchedAtMs,
      source: data.source.present ? data.source.value : this.source,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotMetaData(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('fetchedAtMs: $fetchedAtMs, ')
          ..write('source: $source, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contentHash, fetchedAtMs, source, schemaVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotMetaData &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.fetchedAtMs == this.fetchedAtMs &&
          other.source == this.source &&
          other.schemaVersion == this.schemaVersion);
}

class SnapshotMetaCompanion extends UpdateCompanion<SnapshotMetaData> {
  final Value<int> id;
  final Value<String> contentHash;
  final Value<int> fetchedAtMs;
  final Value<String> source;
  final Value<int> schemaVersion;
  const SnapshotMetaCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.fetchedAtMs = const Value.absent(),
    this.source = const Value.absent(),
    this.schemaVersion = const Value.absent(),
  });
  SnapshotMetaCompanion.insert({
    this.id = const Value.absent(),
    required String contentHash,
    required int fetchedAtMs,
    required String source,
    required int schemaVersion,
  }) : contentHash = Value(contentHash),
       fetchedAtMs = Value(fetchedAtMs),
       source = Value(source),
       schemaVersion = Value(schemaVersion);
  static Insertable<SnapshotMetaData> custom({
    Expression<int>? id,
    Expression<String>? contentHash,
    Expression<int>? fetchedAtMs,
    Expression<String>? source,
    Expression<int>? schemaVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (fetchedAtMs != null) 'fetched_at_ms': fetchedAtMs,
      if (source != null) 'source': source,
      if (schemaVersion != null) 'schema_version': schemaVersion,
    });
  }

  SnapshotMetaCompanion copyWith({
    Value<int>? id,
    Value<String>? contentHash,
    Value<int>? fetchedAtMs,
    Value<String>? source,
    Value<int>? schemaVersion,
  }) {
    return SnapshotMetaCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      fetchedAtMs: fetchedAtMs ?? this.fetchedAtMs,
      source: source ?? this.source,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (fetchedAtMs.present) {
      map['fetched_at_ms'] = Variable<int>(fetchedAtMs.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotMetaCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('fetchedAtMs: $fetchedAtMs, ')
          ..write('source: $source, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }
}

class $LanguagesTable extends Languages
    with TableInfo<$LanguagesTable, Language> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nativeNameMeta = const VerificationMeta(
    'nativeName',
  );
  @override
  late final GeneratedColumn<String> nativeName = GeneratedColumn<String>(
    'native_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scriptMeta = const VerificationMeta('script');
  @override
  late final GeneratedColumn<String> script = GeneratedColumn<String>(
    'script',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    nativeName,
    script,
    direction,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'languages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Language> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('native_name')) {
      context.handle(
        _nativeNameMeta,
        nativeName.isAcceptableOrUnknown(data['native_name']!, _nativeNameMeta),
      );
    }
    if (data.containsKey('script')) {
      context.handle(
        _scriptMeta,
        script.isAcceptableOrUnknown(data['script']!, _scriptMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Language map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Language(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      nativeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_name'],
      ),
      script: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}script'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
    );
  }

  @override
  $LanguagesTable createAlias(String alias) {
    return $LanguagesTable(attachedDatabase, alias);
  }
}

class Language extends DataClass implements Insertable<Language> {
  final int id;
  final String code;
  final String? name;
  final String? nativeName;
  final String? script;
  final String? direction;
  final String? type;
  const Language({
    required this.id,
    required this.code,
    this.name,
    this.nativeName,
    this.script,
    this.direction,
    this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || nativeName != null) {
      map['native_name'] = Variable<String>(nativeName);
    }
    if (!nullToAbsent || script != null) {
      map['script'] = Variable<String>(script);
    }
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(direction);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    return map;
  }

  LanguagesCompanion toCompanion(bool nullToAbsent) {
    return LanguagesCompanion(
      id: Value(id),
      code: Value(code),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      nativeName: nativeName == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeName),
      script: script == null && nullToAbsent
          ? const Value.absent()
          : Value(script),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
    );
  }

  factory Language.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Language(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String?>(json['name']),
      nativeName: serializer.fromJson<String?>(json['nativeName']),
      script: serializer.fromJson<String?>(json['script']),
      direction: serializer.fromJson<String?>(json['direction']),
      type: serializer.fromJson<String?>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String?>(name),
      'nativeName': serializer.toJson<String?>(nativeName),
      'script': serializer.toJson<String?>(script),
      'direction': serializer.toJson<String?>(direction),
      'type': serializer.toJson<String?>(type),
    };
  }

  Language copyWith({
    int? id,
    String? code,
    Value<String?> name = const Value.absent(),
    Value<String?> nativeName = const Value.absent(),
    Value<String?> script = const Value.absent(),
    Value<String?> direction = const Value.absent(),
    Value<String?> type = const Value.absent(),
  }) => Language(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name.present ? name.value : this.name,
    nativeName: nativeName.present ? nativeName.value : this.nativeName,
    script: script.present ? script.value : this.script,
    direction: direction.present ? direction.value : this.direction,
    type: type.present ? type.value : this.type,
  );
  Language copyWithCompanion(LanguagesCompanion data) {
    return Language(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      nativeName: data.nativeName.present
          ? data.nativeName.value
          : this.nativeName,
      script: data.script.present ? data.script.value : this.script,
      direction: data.direction.present ? data.direction.value : this.direction,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Language(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nativeName: $nativeName, ')
          ..write('script: $script, ')
          ..write('direction: $direction, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, name, nativeName, script, direction, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Language &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.nativeName == this.nativeName &&
          other.script == this.script &&
          other.direction == this.direction &&
          other.type == this.type);
}

class LanguagesCompanion extends UpdateCompanion<Language> {
  final Value<int> id;
  final Value<String> code;
  final Value<String?> name;
  final Value<String?> nativeName;
  final Value<String?> script;
  final Value<String?> direction;
  final Value<String?> type;
  const LanguagesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.nativeName = const Value.absent(),
    this.script = const Value.absent(),
    this.direction = const Value.absent(),
    this.type = const Value.absent(),
  });
  LanguagesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    this.name = const Value.absent(),
    this.nativeName = const Value.absent(),
    this.script = const Value.absent(),
    this.direction = const Value.absent(),
    this.type = const Value.absent(),
  }) : code = Value(code);
  static Insertable<Language> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? nativeName,
    Expression<String>? script,
    Expression<String>? direction,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (nativeName != null) 'native_name': nativeName,
      if (script != null) 'script': script,
      if (direction != null) 'direction': direction,
      if (type != null) 'type': type,
    });
  }

  LanguagesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String?>? name,
    Value<String?>? nativeName,
    Value<String?>? script,
    Value<String?>? direction,
    Value<String?>? type,
  }) {
    return LanguagesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      script: script ?? this.script,
      direction: direction ?? this.direction,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nativeName.present) {
      map['native_name'] = Variable<String>(nativeName.value);
    }
    if (script.present) {
      map['script'] = Variable<String>(script.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguagesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nativeName: $nativeName, ')
          ..write('script: $script, ')
          ..write('direction: $direction, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageIdMeta = const VerificationMeta(
    'languageId',
  );
  @override
  late final GeneratedColumn<int> languageId = GeneratedColumn<int>(
    'language_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialsMeta = const VerificationMeta(
    'initials',
  );
  @override
  late final GeneratedColumn<String> initials = GeneratedColumn<String>(
    'initials',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, languageId, name, initials];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('language_id')) {
      context.handle(
        _languageIdMeta,
        languageId.isAcceptableOrUnknown(data['language_id']!, _languageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_languageIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initials')) {
      context.handle(
        _initialsMeta,
        initials.isAcceptableOrUnknown(data['initials']!, _initialsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      languageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}language_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      initials: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initials'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final int languageId;
  final String name;
  final String? initials;
  const Book({
    required this.id,
    required this.languageId,
    required this.name,
    this.initials,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['language_id'] = Variable<int>(languageId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || initials != null) {
      map['initials'] = Variable<String>(initials);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      languageId: Value(languageId),
      name: Value(name),
      initials: initials == null && nullToAbsent
          ? const Value.absent()
          : Value(initials),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      languageId: serializer.fromJson<int>(json['languageId']),
      name: serializer.fromJson<String>(json['name']),
      initials: serializer.fromJson<String?>(json['initials']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'languageId': serializer.toJson<int>(languageId),
      'name': serializer.toJson<String>(name),
      'initials': serializer.toJson<String?>(initials),
    };
  }

  Book copyWith({
    int? id,
    int? languageId,
    String? name,
    Value<String?> initials = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    languageId: languageId ?? this.languageId,
    name: name ?? this.name,
    initials: initials.present ? initials.value : this.initials,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      languageId: data.languageId.present
          ? data.languageId.value
          : this.languageId,
      name: data.name.present ? data.name.value : this.name,
      initials: data.initials.present ? data.initials.value : this.initials,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('languageId: $languageId, ')
          ..write('name: $name, ')
          ..write('initials: $initials')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, languageId, name, initials);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.languageId == this.languageId &&
          other.name == this.name &&
          other.initials == this.initials);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<int> languageId;
  final Value<String> name;
  final Value<String?> initials;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.languageId = const Value.absent(),
    this.name = const Value.absent(),
    this.initials = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required int languageId,
    required String name,
    this.initials = const Value.absent(),
  }) : languageId = Value(languageId),
       name = Value(name);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<int>? languageId,
    Expression<String>? name,
    Expression<String>? initials,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (languageId != null) 'language_id': languageId,
      if (name != null) 'name': name,
      if (initials != null) 'initials': initials,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<int>? languageId,
    Value<String>? name,
    Value<String?>? initials,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      name: name ?? this.name,
      initials: initials ?? this.initials,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<int>(languageId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (initials.present) {
      map['initials'] = Variable<String>(initials.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('languageId: $languageId, ')
          ..write('name: $name, ')
          ..write('initials: $initials')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookId, name, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
  final int bookId;
  final String name;
  final int position;
  const Chapter({
    required this.id,
    required this.bookId,
    required this.name,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      name: Value(name),
      position: Value(position),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  Chapter copyWith({int? id, int? bookId, String? name, int? position}) =>
      Chapter(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        name: name ?? this.name,
        position: position ?? this.position,
      );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.position == this.position);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> name;
  final Value<int> position;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String name,
    required int position,
  }) : bookId = Value(bookId),
       name = Value(name),
       position = Value(position);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? name,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? name,
    Value<int>? position,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $SlokasTable extends Slokas with TableInfo<$SlokasTable, Sloka> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SlokasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slokaTextMeta = const VerificationMeta(
    'slokaText',
  );
  @override
  late final GeneratedColumn<String> slokaText = GeneratedColumn<String>(
    'sloka_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptionMeta = const VerificationMeta(
    'transcription',
  );
  @override
  late final GeneratedColumn<String> transcription = GeneratedColumn<String>(
    'transcription',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioMeta = const VerificationMeta('audio');
  @override
  late final GeneratedColumn<String> audio = GeneratedColumn<String>(
    'audio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioSanskritMeta = const VerificationMeta(
    'audioSanskrit',
  );
  @override
  late final GeneratedColumn<String> audioSanskrit = GeneratedColumn<String>(
    'audio_sanskrit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapterId,
    name,
    slokaText,
    transcription,
    translation,
    comment,
    position,
    audio,
    audioSanskrit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'slokas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sloka> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sloka_text')) {
      context.handle(
        _slokaTextMeta,
        slokaText.isAcceptableOrUnknown(data['sloka_text']!, _slokaTextMeta),
      );
    }
    if (data.containsKey('transcription')) {
      context.handle(
        _transcriptionMeta,
        transcription.isAcceptableOrUnknown(
          data['transcription']!,
          _transcriptionMeta,
        ),
      );
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('audio')) {
      context.handle(
        _audioMeta,
        audio.isAcceptableOrUnknown(data['audio']!, _audioMeta),
      );
    }
    if (data.containsKey('audio_sanskrit')) {
      context.handle(
        _audioSanskritMeta,
        audioSanskrit.isAcceptableOrUnknown(
          data['audio_sanskrit']!,
          _audioSanskritMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sloka map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sloka(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      slokaText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sloka_text'],
      ),
      transcription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription'],
      ),
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      audio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio'],
      ),
      audioSanskrit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_sanskrit'],
      ),
    );
  }

  @override
  $SlokasTable createAlias(String alias) {
    return $SlokasTable(attachedDatabase, alias);
  }
}

class Sloka extends DataClass implements Insertable<Sloka> {
  final int id;
  final int chapterId;
  final String name;
  final String? slokaText;
  final String? transcription;
  final String? translation;
  final String? comment;
  final int position;
  final String? audio;
  final String? audioSanskrit;
  const Sloka({
    required this.id,
    required this.chapterId,
    required this.name,
    this.slokaText,
    this.transcription,
    this.translation,
    this.comment,
    required this.position,
    this.audio,
    this.audioSanskrit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || slokaText != null) {
      map['sloka_text'] = Variable<String>(slokaText);
    }
    if (!nullToAbsent || transcription != null) {
      map['transcription'] = Variable<String>(transcription);
    }
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || audio != null) {
      map['audio'] = Variable<String>(audio);
    }
    if (!nullToAbsent || audioSanskrit != null) {
      map['audio_sanskrit'] = Variable<String>(audioSanskrit);
    }
    return map;
  }

  SlokasCompanion toCompanion(bool nullToAbsent) {
    return SlokasCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      name: Value(name),
      slokaText: slokaText == null && nullToAbsent
          ? const Value.absent()
          : Value(slokaText),
      transcription: transcription == null && nullToAbsent
          ? const Value.absent()
          : Value(transcription),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      position: Value(position),
      audio: audio == null && nullToAbsent
          ? const Value.absent()
          : Value(audio),
      audioSanskrit: audioSanskrit == null && nullToAbsent
          ? const Value.absent()
          : Value(audioSanskrit),
    );
  }

  factory Sloka.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sloka(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      name: serializer.fromJson<String>(json['name']),
      slokaText: serializer.fromJson<String?>(json['slokaText']),
      transcription: serializer.fromJson<String?>(json['transcription']),
      translation: serializer.fromJson<String?>(json['translation']),
      comment: serializer.fromJson<String?>(json['comment']),
      position: serializer.fromJson<int>(json['position']),
      audio: serializer.fromJson<String?>(json['audio']),
      audioSanskrit: serializer.fromJson<String?>(json['audioSanskrit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'name': serializer.toJson<String>(name),
      'slokaText': serializer.toJson<String?>(slokaText),
      'transcription': serializer.toJson<String?>(transcription),
      'translation': serializer.toJson<String?>(translation),
      'comment': serializer.toJson<String?>(comment),
      'position': serializer.toJson<int>(position),
      'audio': serializer.toJson<String?>(audio),
      'audioSanskrit': serializer.toJson<String?>(audioSanskrit),
    };
  }

  Sloka copyWith({
    int? id,
    int? chapterId,
    String? name,
    Value<String?> slokaText = const Value.absent(),
    Value<String?> transcription = const Value.absent(),
    Value<String?> translation = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    int? position,
    Value<String?> audio = const Value.absent(),
    Value<String?> audioSanskrit = const Value.absent(),
  }) => Sloka(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    name: name ?? this.name,
    slokaText: slokaText.present ? slokaText.value : this.slokaText,
    transcription: transcription.present
        ? transcription.value
        : this.transcription,
    translation: translation.present ? translation.value : this.translation,
    comment: comment.present ? comment.value : this.comment,
    position: position ?? this.position,
    audio: audio.present ? audio.value : this.audio,
    audioSanskrit: audioSanskrit.present
        ? audioSanskrit.value
        : this.audioSanskrit,
  );
  Sloka copyWithCompanion(SlokasCompanion data) {
    return Sloka(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      name: data.name.present ? data.name.value : this.name,
      slokaText: data.slokaText.present ? data.slokaText.value : this.slokaText,
      transcription: data.transcription.present
          ? data.transcription.value
          : this.transcription,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      comment: data.comment.present ? data.comment.value : this.comment,
      position: data.position.present ? data.position.value : this.position,
      audio: data.audio.present ? data.audio.value : this.audio,
      audioSanskrit: data.audioSanskrit.present
          ? data.audioSanskrit.value
          : this.audioSanskrit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sloka(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('name: $name, ')
          ..write('slokaText: $slokaText, ')
          ..write('transcription: $transcription, ')
          ..write('translation: $translation, ')
          ..write('comment: $comment, ')
          ..write('position: $position, ')
          ..write('audio: $audio, ')
          ..write('audioSanskrit: $audioSanskrit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chapterId,
    name,
    slokaText,
    transcription,
    translation,
    comment,
    position,
    audio,
    audioSanskrit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sloka &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.name == this.name &&
          other.slokaText == this.slokaText &&
          other.transcription == this.transcription &&
          other.translation == this.translation &&
          other.comment == this.comment &&
          other.position == this.position &&
          other.audio == this.audio &&
          other.audioSanskrit == this.audioSanskrit);
}

class SlokasCompanion extends UpdateCompanion<Sloka> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<String> name;
  final Value<String?> slokaText;
  final Value<String?> transcription;
  final Value<String?> translation;
  final Value<String?> comment;
  final Value<int> position;
  final Value<String?> audio;
  final Value<String?> audioSanskrit;
  const SlokasCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.name = const Value.absent(),
    this.slokaText = const Value.absent(),
    this.transcription = const Value.absent(),
    this.translation = const Value.absent(),
    this.comment = const Value.absent(),
    this.position = const Value.absent(),
    this.audio = const Value.absent(),
    this.audioSanskrit = const Value.absent(),
  });
  SlokasCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required String name,
    this.slokaText = const Value.absent(),
    this.transcription = const Value.absent(),
    this.translation = const Value.absent(),
    this.comment = const Value.absent(),
    required int position,
    this.audio = const Value.absent(),
    this.audioSanskrit = const Value.absent(),
  }) : chapterId = Value(chapterId),
       name = Value(name),
       position = Value(position);
  static Insertable<Sloka> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<String>? name,
    Expression<String>? slokaText,
    Expression<String>? transcription,
    Expression<String>? translation,
    Expression<String>? comment,
    Expression<int>? position,
    Expression<String>? audio,
    Expression<String>? audioSanskrit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (name != null) 'name': name,
      if (slokaText != null) 'sloka_text': slokaText,
      if (transcription != null) 'transcription': transcription,
      if (translation != null) 'translation': translation,
      if (comment != null) 'comment': comment,
      if (position != null) 'position': position,
      if (audio != null) 'audio': audio,
      if (audioSanskrit != null) 'audio_sanskrit': audioSanskrit,
    });
  }

  SlokasCompanion copyWith({
    Value<int>? id,
    Value<int>? chapterId,
    Value<String>? name,
    Value<String?>? slokaText,
    Value<String?>? transcription,
    Value<String?>? translation,
    Value<String?>? comment,
    Value<int>? position,
    Value<String?>? audio,
    Value<String?>? audioSanskrit,
  }) {
    return SlokasCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      name: name ?? this.name,
      slokaText: slokaText ?? this.slokaText,
      transcription: transcription ?? this.transcription,
      translation: translation ?? this.translation,
      comment: comment ?? this.comment,
      position: position ?? this.position,
      audio: audio ?? this.audio,
      audioSanskrit: audioSanskrit ?? this.audioSanskrit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slokaText.present) {
      map['sloka_text'] = Variable<String>(slokaText.value);
    }
    if (transcription.present) {
      map['transcription'] = Variable<String>(transcription.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (audio.present) {
      map['audio'] = Variable<String>(audio.value);
    }
    if (audioSanskrit.present) {
      map['audio_sanskrit'] = Variable<String>(audioSanskrit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SlokasCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('name: $name, ')
          ..write('slokaText: $slokaText, ')
          ..write('transcription: $transcription, ')
          ..write('translation: $translation, ')
          ..write('comment: $comment, ')
          ..write('position: $position, ')
          ..write('audio: $audio, ')
          ..write('audioSanskrit: $audioSanskrit')
          ..write(')'))
        .toString();
  }
}

class $VocabulariesTable extends Vocabularies
    with TableInfo<$VocabulariesTable, Vocabulary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabulariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slokaIdMeta = const VerificationMeta(
    'slokaId',
  );
  @override
  late final GeneratedColumn<int> slokaId = GeneratedColumn<int>(
    'sloka_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenTextMeta = const VerificationMeta(
    'tokenText',
  );
  @override
  late final GeneratedColumn<String> tokenText = GeneratedColumn<String>(
    'token_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slokaId,
    tokenText,
    translation,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabularies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vocabulary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sloka_id')) {
      context.handle(
        _slokaIdMeta,
        slokaId.isAcceptableOrUnknown(data['sloka_id']!, _slokaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_slokaIdMeta);
    }
    if (data.containsKey('token_text')) {
      context.handle(
        _tokenTextMeta,
        tokenText.isAcceptableOrUnknown(data['token_text']!, _tokenTextMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenTextMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vocabulary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vocabulary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slokaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sloka_id'],
      )!,
      tokenText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_text'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $VocabulariesTable createAlias(String alias) {
    return $VocabulariesTable(attachedDatabase, alias);
  }
}

class Vocabulary extends DataClass implements Insertable<Vocabulary> {
  final int id;
  final int slokaId;
  final String tokenText;
  final String translation;
  final int? position;
  const Vocabulary({
    required this.id,
    required this.slokaId,
    required this.tokenText,
    required this.translation,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sloka_id'] = Variable<int>(slokaId);
    map['token_text'] = Variable<String>(tokenText);
    map['translation'] = Variable<String>(translation);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    return map;
  }

  VocabulariesCompanion toCompanion(bool nullToAbsent) {
    return VocabulariesCompanion(
      id: Value(id),
      slokaId: Value(slokaId),
      tokenText: Value(tokenText),
      translation: Value(translation),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory Vocabulary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vocabulary(
      id: serializer.fromJson<int>(json['id']),
      slokaId: serializer.fromJson<int>(json['slokaId']),
      tokenText: serializer.fromJson<String>(json['tokenText']),
      translation: serializer.fromJson<String>(json['translation']),
      position: serializer.fromJson<int?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slokaId': serializer.toJson<int>(slokaId),
      'tokenText': serializer.toJson<String>(tokenText),
      'translation': serializer.toJson<String>(translation),
      'position': serializer.toJson<int?>(position),
    };
  }

  Vocabulary copyWith({
    int? id,
    int? slokaId,
    String? tokenText,
    String? translation,
    Value<int?> position = const Value.absent(),
  }) => Vocabulary(
    id: id ?? this.id,
    slokaId: slokaId ?? this.slokaId,
    tokenText: tokenText ?? this.tokenText,
    translation: translation ?? this.translation,
    position: position.present ? position.value : this.position,
  );
  Vocabulary copyWithCompanion(VocabulariesCompanion data) {
    return Vocabulary(
      id: data.id.present ? data.id.value : this.id,
      slokaId: data.slokaId.present ? data.slokaId.value : this.slokaId,
      tokenText: data.tokenText.present ? data.tokenText.value : this.tokenText,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vocabulary(')
          ..write('id: $id, ')
          ..write('slokaId: $slokaId, ')
          ..write('tokenText: $tokenText, ')
          ..write('translation: $translation, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, slokaId, tokenText, translation, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vocabulary &&
          other.id == this.id &&
          other.slokaId == this.slokaId &&
          other.tokenText == this.tokenText &&
          other.translation == this.translation &&
          other.position == this.position);
}

class VocabulariesCompanion extends UpdateCompanion<Vocabulary> {
  final Value<int> id;
  final Value<int> slokaId;
  final Value<String> tokenText;
  final Value<String> translation;
  final Value<int?> position;
  const VocabulariesCompanion({
    this.id = const Value.absent(),
    this.slokaId = const Value.absent(),
    this.tokenText = const Value.absent(),
    this.translation = const Value.absent(),
    this.position = const Value.absent(),
  });
  VocabulariesCompanion.insert({
    this.id = const Value.absent(),
    required int slokaId,
    required String tokenText,
    required String translation,
    this.position = const Value.absent(),
  }) : slokaId = Value(slokaId),
       tokenText = Value(tokenText),
       translation = Value(translation);
  static Insertable<Vocabulary> custom({
    Expression<int>? id,
    Expression<int>? slokaId,
    Expression<String>? tokenText,
    Expression<String>? translation,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slokaId != null) 'sloka_id': slokaId,
      if (tokenText != null) 'token_text': tokenText,
      if (translation != null) 'translation': translation,
      if (position != null) 'position': position,
    });
  }

  VocabulariesCompanion copyWith({
    Value<int>? id,
    Value<int>? slokaId,
    Value<String>? tokenText,
    Value<String>? translation,
    Value<int?>? position,
  }) {
    return VocabulariesCompanion(
      id: id ?? this.id,
      slokaId: slokaId ?? this.slokaId,
      tokenText: tokenText ?? this.tokenText,
      translation: translation ?? this.translation,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slokaId.present) {
      map['sloka_id'] = Variable<int>(slokaId.value);
    }
    if (tokenText.present) {
      map['token_text'] = Variable<String>(tokenText.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabulariesCompanion(')
          ..write('id: $id, ')
          ..write('slokaId: $slokaId, ')
          ..write('tokenText: $tokenText, ')
          ..write('translation: $translation, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slokaIdMeta = const VerificationMeta(
    'slokaId',
  );
  @override
  late final GeneratedColumn<int> slokaId = GeneratedColumn<int>(
    'sloka_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [slokaId, createdAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sloka_id')) {
      context.handle(
        _slokaIdMeta,
        slokaId.isAcceptableOrUnknown(data['sloka_id']!, _slokaIdMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slokaId};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      slokaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sloka_id'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int slokaId;
  final int createdAtMs;
  const Bookmark({required this.slokaId, required this.createdAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sloka_id'] = Variable<int>(slokaId);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      slokaId: Value(slokaId),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      slokaId: serializer.fromJson<int>(json['slokaId']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slokaId': serializer.toJson<int>(slokaId),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  Bookmark copyWith({int? slokaId, int? createdAtMs}) => Bookmark(
    slokaId: slokaId ?? this.slokaId,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      slokaId: data.slokaId.present ? data.slokaId.value : this.slokaId,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('slokaId: $slokaId, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slokaId, createdAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.slokaId == this.slokaId &&
          other.createdAtMs == this.createdAtMs);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> slokaId;
  final Value<int> createdAtMs;
  const BookmarksCompanion({
    this.slokaId = const Value.absent(),
    this.createdAtMs = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.slokaId = const Value.absent(),
    required int createdAtMs,
  }) : createdAtMs = Value(createdAtMs);
  static Insertable<Bookmark> custom({
    Expression<int>? slokaId,
    Expression<int>? createdAtMs,
  }) {
    return RawValuesInsertable({
      if (slokaId != null) 'sloka_id': slokaId,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
    });
  }

  BookmarksCompanion copyWith({Value<int>? slokaId, Value<int>? createdAtMs}) {
    return BookmarksCompanion(
      slokaId: slokaId ?? this.slokaId,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slokaId.present) {
      map['sloka_id'] = Variable<int>(slokaId.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('slokaId: $slokaId, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slokaIdMeta = const VerificationMeta(
    'slokaId',
  );
  @override
  late final GeneratedColumn<int> slokaId = GeneratedColumn<int>(
    'sloka_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [slokaId, note, updatedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sloka_id')) {
      context.handle(
        _slokaIdMeta,
        slokaId.isAcceptableOrUnknown(data['sloka_id']!, _slokaIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slokaId};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      slokaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sloka_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int slokaId;
  final String note;
  final int updatedAtMs;
  const Note({
    required this.slokaId,
    required this.note,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sloka_id'] = Variable<int>(slokaId);
    map['note'] = Variable<String>(note);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      slokaId: Value(slokaId),
      note: Value(note),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      slokaId: serializer.fromJson<int>(json['slokaId']),
      note: serializer.fromJson<String>(json['note']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slokaId': serializer.toJson<int>(slokaId),
      'note': serializer.toJson<String>(note),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Note copyWith({int? slokaId, String? note, int? updatedAtMs}) => Note(
    slokaId: slokaId ?? this.slokaId,
    note: note ?? this.note,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      slokaId: data.slokaId.present ? data.slokaId.value : this.slokaId,
      note: data.note.present ? data.note.value : this.note,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('slokaId: $slokaId, ')
          ..write('note: $note, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slokaId, note, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.slokaId == this.slokaId &&
          other.note == this.note &&
          other.updatedAtMs == this.updatedAtMs);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> slokaId;
  final Value<String> note;
  final Value<int> updatedAtMs;
  const NotesCompanion({
    this.slokaId = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  NotesCompanion.insert({
    this.slokaId = const Value.absent(),
    required String note,
    required int updatedAtMs,
  }) : note = Value(note),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<Note> custom({
    Expression<int>? slokaId,
    Expression<String>? note,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (slokaId != null) 'sloka_id': slokaId,
      if (note != null) 'note': note,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  NotesCompanion copyWith({
    Value<int>? slokaId,
    Value<String>? note,
    Value<int>? updatedAtMs,
  }) {
    return NotesCompanion(
      slokaId: slokaId ?? this.slokaId,
      note: note ?? this.note,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slokaId.present) {
      map['sloka_id'] = Variable<int>(slokaId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('slokaId: $slokaId, ')
          ..write('note: $note, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SnapshotMetaTable snapshotMeta = $SnapshotMetaTable(this);
  late final $LanguagesTable languages = $LanguagesTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $SlokasTable slokas = $SlokasTable(this);
  late final $VocabulariesTable vocabularies = $VocabulariesTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    snapshotMeta,
    languages,
    books,
    chapters,
    slokas,
    vocabularies,
    bookmarks,
    notes,
  ];
}

typedef $$SnapshotMetaTableCreateCompanionBuilder =
    SnapshotMetaCompanion Function({
      Value<int> id,
      required String contentHash,
      required int fetchedAtMs,
      required String source,
      required int schemaVersion,
    });
typedef $$SnapshotMetaTableUpdateCompanionBuilder =
    SnapshotMetaCompanion Function({
      Value<int> id,
      Value<String> contentHash,
      Value<int> fetchedAtMs,
      Value<String> source,
      Value<int> schemaVersion,
    });

class $$SnapshotMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotMetaTable> {
  $$SnapshotMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnapshotMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotMetaTable> {
  $$SnapshotMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnapshotMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotMetaTable> {
  $$SnapshotMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );
}

class $$SnapshotMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotMetaTable,
          SnapshotMetaData,
          $$SnapshotMetaTableFilterComposer,
          $$SnapshotMetaTableOrderingComposer,
          $$SnapshotMetaTableAnnotationComposer,
          $$SnapshotMetaTableCreateCompanionBuilder,
          $$SnapshotMetaTableUpdateCompanionBuilder,
          (
            SnapshotMetaData,
            BaseReferences<_$AppDatabase, $SnapshotMetaTable, SnapshotMetaData>,
          ),
          SnapshotMetaData,
          PrefetchHooks Function()
        > {
  $$SnapshotMetaTableTableManager(_$AppDatabase db, $SnapshotMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<int> fetchedAtMs = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
              }) => SnapshotMetaCompanion(
                id: id,
                contentHash: contentHash,
                fetchedAtMs: fetchedAtMs,
                source: source,
                schemaVersion: schemaVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentHash,
                required int fetchedAtMs,
                required String source,
                required int schemaVersion,
              }) => SnapshotMetaCompanion.insert(
                id: id,
                contentHash: contentHash,
                fetchedAtMs: fetchedAtMs,
                source: source,
                schemaVersion: schemaVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnapshotMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotMetaTable,
      SnapshotMetaData,
      $$SnapshotMetaTableFilterComposer,
      $$SnapshotMetaTableOrderingComposer,
      $$SnapshotMetaTableAnnotationComposer,
      $$SnapshotMetaTableCreateCompanionBuilder,
      $$SnapshotMetaTableUpdateCompanionBuilder,
      (
        SnapshotMetaData,
        BaseReferences<_$AppDatabase, $SnapshotMetaTable, SnapshotMetaData>,
      ),
      SnapshotMetaData,
      PrefetchHooks Function()
    >;
typedef $$LanguagesTableCreateCompanionBuilder =
    LanguagesCompanion Function({
      Value<int> id,
      required String code,
      Value<String?> name,
      Value<String?> nativeName,
      Value<String?> script,
      Value<String?> direction,
      Value<String?> type,
    });
typedef $$LanguagesTableUpdateCompanionBuilder =
    LanguagesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String?> name,
      Value<String?> nativeName,
      Value<String?> script,
      Value<String?> direction,
      Value<String?> type,
    });

class $$LanguagesTableFilterComposer
    extends Composer<_$AppDatabase, $LanguagesTable> {
  $$LanguagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeName => $composableBuilder(
    column: $table.nativeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LanguagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LanguagesTable> {
  $$LanguagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeName => $composableBuilder(
    column: $table.nativeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LanguagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LanguagesTable> {
  $$LanguagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nativeName => $composableBuilder(
    column: $table.nativeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get script =>
      $composableBuilder(column: $table.script, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$LanguagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LanguagesTable,
          Language,
          $$LanguagesTableFilterComposer,
          $$LanguagesTableOrderingComposer,
          $$LanguagesTableAnnotationComposer,
          $$LanguagesTableCreateCompanionBuilder,
          $$LanguagesTableUpdateCompanionBuilder,
          (Language, BaseReferences<_$AppDatabase, $LanguagesTable, Language>),
          Language,
          PrefetchHooks Function()
        > {
  $$LanguagesTableTableManager(_$AppDatabase db, $LanguagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LanguagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LanguagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LanguagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> nativeName = const Value.absent(),
                Value<String?> script = const Value.absent(),
                Value<String?> direction = const Value.absent(),
                Value<String?> type = const Value.absent(),
              }) => LanguagesCompanion(
                id: id,
                code: code,
                name: name,
                nativeName: nativeName,
                script: script,
                direction: direction,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                Value<String?> name = const Value.absent(),
                Value<String?> nativeName = const Value.absent(),
                Value<String?> script = const Value.absent(),
                Value<String?> direction = const Value.absent(),
                Value<String?> type = const Value.absent(),
              }) => LanguagesCompanion.insert(
                id: id,
                code: code,
                name: name,
                nativeName: nativeName,
                script: script,
                direction: direction,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LanguagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LanguagesTable,
      Language,
      $$LanguagesTableFilterComposer,
      $$LanguagesTableOrderingComposer,
      $$LanguagesTableAnnotationComposer,
      $$LanguagesTableCreateCompanionBuilder,
      $$LanguagesTableUpdateCompanionBuilder,
      (Language, BaseReferences<_$AppDatabase, $LanguagesTable, Language>),
      Language,
      PrefetchHooks Function()
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required int languageId,
      required String name,
      Value<String?> initials,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<int> languageId,
      Value<String> name,
      Value<String?> initials,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initials => $composableBuilder(
    column: $table.initials,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initials => $composableBuilder(
    column: $table.initials,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get initials =>
      $composableBuilder(column: $table.initials, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> languageId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> initials = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                languageId: languageId,
                name: name,
                initials: initials,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int languageId,
                required String name,
                Value<String?> initials = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                languageId: languageId,
                name: name,
                initials: initials,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required int bookId,
      required String name,
      required int position,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> name,
      Value<int> position,
    });

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
          Chapter,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                bookId: bookId,
                name: name,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String name,
                required int position,
              }) => ChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
      Chapter,
      PrefetchHooks Function()
    >;
typedef $$SlokasTableCreateCompanionBuilder =
    SlokasCompanion Function({
      Value<int> id,
      required int chapterId,
      required String name,
      Value<String?> slokaText,
      Value<String?> transcription,
      Value<String?> translation,
      Value<String?> comment,
      required int position,
      Value<String?> audio,
      Value<String?> audioSanskrit,
    });
typedef $$SlokasTableUpdateCompanionBuilder =
    SlokasCompanion Function({
      Value<int> id,
      Value<int> chapterId,
      Value<String> name,
      Value<String?> slokaText,
      Value<String?> transcription,
      Value<String?> translation,
      Value<String?> comment,
      Value<int> position,
      Value<String?> audio,
      Value<String?> audioSanskrit,
    });

class $$SlokasTableFilterComposer
    extends Composer<_$AppDatabase, $SlokasTable> {
  $$SlokasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slokaText => $composableBuilder(
    column: $table.slokaText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioSanskrit => $composableBuilder(
    column: $table.audioSanskrit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SlokasTableOrderingComposer
    extends Composer<_$AppDatabase, $SlokasTable> {
  $$SlokasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slokaText => $composableBuilder(
    column: $table.slokaText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioSanskrit => $composableBuilder(
    column: $table.audioSanskrit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SlokasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SlokasTable> {
  $$SlokasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get slokaText =>
      $composableBuilder(column: $table.slokaText, builder: (column) => column);

  GeneratedColumn<String> get transcription => $composableBuilder(
    column: $table.transcription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get audio =>
      $composableBuilder(column: $table.audio, builder: (column) => column);

  GeneratedColumn<String> get audioSanskrit => $composableBuilder(
    column: $table.audioSanskrit,
    builder: (column) => column,
  );
}

class $$SlokasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SlokasTable,
          Sloka,
          $$SlokasTableFilterComposer,
          $$SlokasTableOrderingComposer,
          $$SlokasTableAnnotationComposer,
          $$SlokasTableCreateCompanionBuilder,
          $$SlokasTableUpdateCompanionBuilder,
          (Sloka, BaseReferences<_$AppDatabase, $SlokasTable, Sloka>),
          Sloka,
          PrefetchHooks Function()
        > {
  $$SlokasTableTableManager(_$AppDatabase db, $SlokasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SlokasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SlokasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SlokasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> slokaText = const Value.absent(),
                Value<String?> transcription = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> audio = const Value.absent(),
                Value<String?> audioSanskrit = const Value.absent(),
              }) => SlokasCompanion(
                id: id,
                chapterId: chapterId,
                name: name,
                slokaText: slokaText,
                transcription: transcription,
                translation: translation,
                comment: comment,
                position: position,
                audio: audio,
                audioSanskrit: audioSanskrit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chapterId,
                required String name,
                Value<String?> slokaText = const Value.absent(),
                Value<String?> transcription = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                required int position,
                Value<String?> audio = const Value.absent(),
                Value<String?> audioSanskrit = const Value.absent(),
              }) => SlokasCompanion.insert(
                id: id,
                chapterId: chapterId,
                name: name,
                slokaText: slokaText,
                transcription: transcription,
                translation: translation,
                comment: comment,
                position: position,
                audio: audio,
                audioSanskrit: audioSanskrit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SlokasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SlokasTable,
      Sloka,
      $$SlokasTableFilterComposer,
      $$SlokasTableOrderingComposer,
      $$SlokasTableAnnotationComposer,
      $$SlokasTableCreateCompanionBuilder,
      $$SlokasTableUpdateCompanionBuilder,
      (Sloka, BaseReferences<_$AppDatabase, $SlokasTable, Sloka>),
      Sloka,
      PrefetchHooks Function()
    >;
typedef $$VocabulariesTableCreateCompanionBuilder =
    VocabulariesCompanion Function({
      Value<int> id,
      required int slokaId,
      required String tokenText,
      required String translation,
      Value<int?> position,
    });
typedef $$VocabulariesTableUpdateCompanionBuilder =
    VocabulariesCompanion Function({
      Value<int> id,
      Value<int> slokaId,
      Value<String> tokenText,
      Value<String> translation,
      Value<int?> position,
    });

class $$VocabulariesTableFilterComposer
    extends Composer<_$AppDatabase, $VocabulariesTable> {
  $$VocabulariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slokaId => $composableBuilder(
    column: $table.slokaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenText => $composableBuilder(
    column: $table.tokenText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabulariesTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabulariesTable> {
  $$VocabulariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slokaId => $composableBuilder(
    column: $table.slokaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenText => $composableBuilder(
    column: $table.tokenText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabulariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabulariesTable> {
  $$VocabulariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slokaId =>
      $composableBuilder(column: $table.slokaId, builder: (column) => column);

  GeneratedColumn<String> get tokenText =>
      $composableBuilder(column: $table.tokenText, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$VocabulariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabulariesTable,
          Vocabulary,
          $$VocabulariesTableFilterComposer,
          $$VocabulariesTableOrderingComposer,
          $$VocabulariesTableAnnotationComposer,
          $$VocabulariesTableCreateCompanionBuilder,
          $$VocabulariesTableUpdateCompanionBuilder,
          (
            Vocabulary,
            BaseReferences<_$AppDatabase, $VocabulariesTable, Vocabulary>,
          ),
          Vocabulary,
          PrefetchHooks Function()
        > {
  $$VocabulariesTableTableManager(_$AppDatabase db, $VocabulariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabulariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabulariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabulariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> slokaId = const Value.absent(),
                Value<String> tokenText = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<int?> position = const Value.absent(),
              }) => VocabulariesCompanion(
                id: id,
                slokaId: slokaId,
                tokenText: tokenText,
                translation: translation,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int slokaId,
                required String tokenText,
                required String translation,
                Value<int?> position = const Value.absent(),
              }) => VocabulariesCompanion.insert(
                id: id,
                slokaId: slokaId,
                tokenText: tokenText,
                translation: translation,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabulariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabulariesTable,
      Vocabulary,
      $$VocabulariesTableFilterComposer,
      $$VocabulariesTableOrderingComposer,
      $$VocabulariesTableAnnotationComposer,
      $$VocabulariesTableCreateCompanionBuilder,
      $$VocabulariesTableUpdateCompanionBuilder,
      (
        Vocabulary,
        BaseReferences<_$AppDatabase, $VocabulariesTable, Vocabulary>,
      ),
      Vocabulary,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({Value<int> slokaId, required int createdAtMs});
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({Value<int> slokaId, Value<int> createdAtMs});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slokaId => $composableBuilder(
    column: $table.slokaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slokaId => $composableBuilder(
    column: $table.slokaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slokaId =>
      $composableBuilder(column: $table.slokaId, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slokaId = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
              }) => BookmarksCompanion(
                slokaId: slokaId,
                createdAtMs: createdAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> slokaId = const Value.absent(),
                required int createdAtMs,
              }) => BookmarksCompanion.insert(
                slokaId: slokaId,
                createdAtMs: createdAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> slokaId,
      required String note,
      required int updatedAtMs,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> slokaId,
      Value<String> note,
      Value<int> updatedAtMs,
    });

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slokaId => $composableBuilder(
    column: $table.slokaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slokaId => $composableBuilder(
    column: $table.slokaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slokaId =>
      $composableBuilder(column: $table.slokaId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slokaId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => NotesCompanion(
                slokaId: slokaId,
                note: note,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> slokaId = const Value.absent(),
                required String note,
                required int updatedAtMs,
              }) => NotesCompanion.insert(
                slokaId: slokaId,
                note: note,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SnapshotMetaTableTableManager get snapshotMeta =>
      $$SnapshotMetaTableTableManager(_db, _db.snapshotMeta);
  $$LanguagesTableTableManager get languages =>
      $$LanguagesTableTableManager(_db, _db.languages);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$SlokasTableTableManager get slokas =>
      $$SlokasTableTableManager(_db, _db.slokas);
  $$VocabulariesTableTableManager get vocabularies =>
      $$VocabulariesTableTableManager(_db, _db.vocabularies);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
}

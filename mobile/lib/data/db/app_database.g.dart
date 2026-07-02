// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarHueMeta = const VerificationMeta(
    'avatarHue',
  );
  @override
  late final GeneratedColumn<int> avatarHue = GeneratedColumn<int>(
    'avatar_hue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    role,
    avatarHue,
    phone,
    avatarPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('avatar_hue')) {
      context.handle(
        _avatarHueMeta,
        avatarHue.isAcceptableOrUnknown(data['avatar_hue']!, _avatarHueMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarHueMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      avatarHue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avatar_hue'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final int id;
  final String name;
  final String email;
  final String role;
  final int avatarHue;
  final String? phone;
  final String? avatarPath;
  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarHue,
    this.phone,
    this.avatarPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['avatar_hue'] = Variable<int>(avatarHue);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      role: Value(role),
      avatarHue: Value(avatarHue),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      avatarHue: serializer.fromJson<int>(json['avatarHue']),
      phone: serializer.fromJson<String?>(json['phone']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'avatarHue': serializer.toJson<int>(avatarHue),
      'phone': serializer.toJson<String?>(phone),
      'avatarPath': serializer.toJson<String?>(avatarPath),
    };
  }

  Member copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    int? avatarHue,
    Value<String?> phone = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
  }) => Member(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
    avatarHue: avatarHue ?? this.avatarHue,
    phone: phone.present ? phone.value : this.phone,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      avatarHue: data.avatarHue.present ? data.avatarHue.value : this.avatarHue,
      phone: data.phone.present ? data.phone.value : this.phone,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('avatarHue: $avatarHue, ')
          ..write('phone: $phone, ')
          ..write('avatarPath: $avatarPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, role, avatarHue, phone, avatarPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.role == this.role &&
          other.avatarHue == this.avatarHue &&
          other.phone == this.phone &&
          other.avatarPath == this.avatarPath);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> role;
  final Value<int> avatarHue;
  final Value<String?> phone;
  final Value<String?> avatarPath;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.avatarHue = const Value.absent(),
    this.phone = const Value.absent(),
    this.avatarPath = const Value.absent(),
  });
  MembersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String role,
    required int avatarHue,
    this.phone = const Value.absent(),
    this.avatarPath = const Value.absent(),
  }) : name = Value(name),
       email = Value(email),
       role = Value(role),
       avatarHue = Value(avatarHue);
  static Insertable<Member> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? role,
    Expression<int>? avatarHue,
    Expression<String>? phone,
    Expression<String>? avatarPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (avatarHue != null) 'avatar_hue': avatarHue,
      if (phone != null) 'phone': phone,
      if (avatarPath != null) 'avatar_path': avatarPath,
    });
  }

  MembersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? role,
    Value<int>? avatarHue,
    Value<String?>? phone,
    Value<String?>? avatarPath,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarHue: avatarHue ?? this.avatarHue,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (avatarHue.present) {
      map['avatar_hue'] = Variable<int>(avatarHue.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('avatarHue: $avatarHue, ')
          ..write('phone: $phone, ')
          ..write('avatarPath: $avatarPath')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<int> currentBalance = GeneratedColumn<int>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    ownerUserId,
    name,
    type,
    icon,
    initialBalance,
    currentBalance,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialBalanceMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentBalanceMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_balance'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final int id;
  final String scope;
  final int? ownerUserId;
  final String name;
  final String type;
  final String? icon;
  final int initialBalance;
  final int currentBalance;
  final bool deleted;
  const Wallet({
    required this.id,
    required this.scope,
    this.ownerUserId,
    required this.name,
    required this.type,
    this.icon,
    required this.initialBalance,
    required this.currentBalance,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<int>(ownerUserId);
    }
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['initial_balance'] = Variable<int>(initialBalance);
    map['current_balance'] = Variable<int>(currentBalance);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      scope: Value(scope),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      name: Value(name),
      type: Value(type),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      deleted: Value(deleted),
    );
  }

  factory Wallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      ownerUserId: serializer.fromJson<int?>(json['ownerUserId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String?>(json['icon']),
      initialBalance: serializer.fromJson<int>(json['initialBalance']),
      currentBalance: serializer.fromJson<int>(json['currentBalance']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'ownerUserId': serializer.toJson<int?>(ownerUserId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String?>(icon),
      'initialBalance': serializer.toJson<int>(initialBalance),
      'currentBalance': serializer.toJson<int>(currentBalance),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  Wallet copyWith({
    int? id,
    String? scope,
    Value<int?> ownerUserId = const Value.absent(),
    String? name,
    String? type,
    Value<String?> icon = const Value.absent(),
    int? initialBalance,
    int? currentBalance,
    bool? deleted,
  }) => Wallet(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon.present ? icon.value : this.icon,
    initialBalance: initialBalance ?? this.initialBalance,
    currentBalance: currentBalance ?? this.currentBalance,
    deleted: deleted ?? this.deleted,
  );
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    ownerUserId,
    name,
    type,
    icon,
    initialBalance,
    currentBalance,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.ownerUserId == this.ownerUserId &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.initialBalance == this.initialBalance &&
          other.currentBalance == this.currentBalance &&
          other.deleted == this.deleted);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<int> id;
  final Value<String> scope;
  final Value<int?> ownerUserId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> icon;
  final Value<int> initialBalance;
  final Value<int> currentBalance;
  final Value<bool> deleted;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    this.ownerUserId = const Value.absent(),
    required String name,
    required String type,
    this.icon = const Value.absent(),
    required int initialBalance,
    required int currentBalance,
    this.deleted = const Value.absent(),
  }) : scope = Value(scope),
       name = Value(name),
       type = Value(type),
       initialBalance = Value(initialBalance),
       currentBalance = Value(currentBalance);
  static Insertable<Wallet> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<int>? ownerUserId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<int>? initialBalance,
    Expression<int>? currentBalance,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (deleted != null) 'deleted': deleted,
    });
  }

  WalletsCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<int?>? ownerUserId,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? icon,
    Value<int>? initialBalance,
    Value<int>? currentBalance,
    Value<bool>? deleted,
  }) {
    return WalletsCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<int>(currentBalance.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hueMeta = const VerificationMeta('hue');
  @override
  late final GeneratedColumn<int> hue = GeneratedColumn<int>(
    'hue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, icon, hue, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('hue')) {
      context.handle(
        _hueMeta,
        hue.isAcceptableOrUnknown(data['hue']!, _hueMeta),
      );
    } else if (isInserting) {
      context.missing(_hueMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      hue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hue'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;
  final String icon;
  final int hue;
  final int? parentId;
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.hue,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon'] = Variable<String>(icon);
    map['hue'] = Variable<int>(hue);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      hue: Value(hue),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String>(json['icon']),
      hue: serializer.fromJson<int>(json['hue']),
      parentId: serializer.fromJson<int?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String>(icon),
      'hue': serializer.toJson<int>(hue),
      'parentId': serializer.toJson<int?>(parentId),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    int? hue,
    Value<int?> parentId = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    hue: hue ?? this.hue,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      hue: data.hue.present ? data.hue.value : this.hue,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('hue: $hue, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, icon, hue, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.hue == this.hue &&
          other.parentId == this.parentId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> icon;
  final Value<int> hue;
  final Value<int?> parentId;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.hue = const Value.absent(),
    this.parentId = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required String icon,
    required int hue,
    this.parentId = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       icon = Value(icon),
       hue = Value(hue);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<int>? hue,
    Expression<int>? parentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (hue != null) 'hue': hue,
      if (parentId != null) 'parent_id': parentId,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? icon,
    Value<int>? hue,
    Value<int?>? parentId,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      hue: hue ?? this.hue,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (hue.present) {
      map['hue'] = Variable<int>(hue.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('hue: $hue, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWalletIdMeta = const VerificationMeta(
    'targetWalletId',
  );
  @override
  late final GeneratedColumn<int> targetWalletId = GeneratedColumn<int>(
    'target_wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedByMeta = const VerificationMeta(
    'recordedBy',
  );
  @override
  late final GeneratedColumn<int> recordedBy = GeneratedColumn<int>(
    'recorded_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spentByMeta = const VerificationMeta(
    'spentBy',
  );
  @override
  late final GeneratedColumn<int> spentBy = GeneratedColumn<int>(
    'spent_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    serverId,
    type,
    walletId,
    targetWalletId,
    categoryId,
    amount,
    date,
    note,
    recordedBy,
    spentBy,
    receiptPath,
    updatedAt,
    deleted,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('target_wallet_id')) {
      context.handle(
        _targetWalletIdMeta,
        targetWalletId.isAcceptableOrUnknown(
          data['target_wallet_id']!,
          _targetWalletIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recorded_by')) {
      context.handle(
        _recordedByMeta,
        recordedBy.isAcceptableOrUnknown(data['recorded_by']!, _recordedByMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedByMeta);
    }
    if (data.containsKey('spent_by')) {
      context.handle(
        _spentByMeta,
        spentBy.isAcceptableOrUnknown(data['spent_by']!, _spentByMeta),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      )!,
      targetWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_wallet_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recordedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_by'],
      )!,
      spentBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spent_by'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String clientId;
  final int? serverId;
  final String type;
  final int walletId;
  final int? targetWalletId;
  final int? categoryId;
  final int amount;
  final DateTime date;
  final String? note;
  final int recordedBy;
  final int? spentBy;
  final String? receiptPath;
  final DateTime updatedAt;
  final bool deleted;
  final bool pendingSync;
  const Transaction({
    required this.clientId,
    this.serverId,
    required this.type,
    required this.walletId,
    this.targetWalletId,
    this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    required this.recordedBy,
    this.spentBy,
    this.receiptPath,
    required this.updatedAt,
    required this.deleted,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['type'] = Variable<String>(type);
    map['wallet_id'] = Variable<int>(walletId);
    if (!nullToAbsent || targetWalletId != null) {
      map['target_wallet_id'] = Variable<int>(targetWalletId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['amount'] = Variable<int>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['recorded_by'] = Variable<int>(recordedBy);
    if (!nullToAbsent || spentBy != null) {
      map['spent_by'] = Variable<int>(spentBy);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      type: Value(type),
      walletId: Value(walletId),
      targetWalletId: targetWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWalletId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordedBy: Value(recordedBy),
      spentBy: spentBy == null && nullToAbsent
          ? const Value.absent()
          : Value(spentBy),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      pendingSync: Value(pendingSync),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      type: serializer.fromJson<String>(json['type']),
      walletId: serializer.fromJson<int>(json['walletId']),
      targetWalletId: serializer.fromJson<int?>(json['targetWalletId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      amount: serializer.fromJson<int>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      recordedBy: serializer.fromJson<int>(json['recordedBy']),
      spentBy: serializer.fromJson<int?>(json['spentBy']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<int?>(serverId),
      'type': serializer.toJson<String>(type),
      'walletId': serializer.toJson<int>(walletId),
      'targetWalletId': serializer.toJson<int?>(targetWalletId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'amount': serializer.toJson<int>(amount),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'recordedBy': serializer.toJson<int>(recordedBy),
      'spentBy': serializer.toJson<int?>(spentBy),
      'receiptPath': serializer.toJson<String?>(receiptPath),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  Transaction copyWith({
    String? clientId,
    Value<int?> serverId = const Value.absent(),
    String? type,
    int? walletId,
    Value<int?> targetWalletId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    int? amount,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    int? recordedBy,
    Value<int?> spentBy = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    bool? pendingSync,
  }) => Transaction(
    clientId: clientId ?? this.clientId,
    serverId: serverId.present ? serverId.value : this.serverId,
    type: type ?? this.type,
    walletId: walletId ?? this.walletId,
    targetWalletId: targetWalletId.present
        ? targetWalletId.value
        : this.targetWalletId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    recordedBy: recordedBy ?? this.recordedBy,
    spentBy: spentBy.present ? spentBy.value : this.spentBy,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      type: data.type.present ? data.type.value : this.type,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      targetWalletId: data.targetWalletId.present
          ? data.targetWalletId.value
          : this.targetWalletId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      recordedBy: data.recordedBy.present
          ? data.recordedBy.value
          : this.recordedBy,
      spentBy: data.spentBy.present ? data.spentBy.value : this.spentBy,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('type: $type, ')
          ..write('walletId: $walletId, ')
          ..write('targetWalletId: $targetWalletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('spentBy: $spentBy, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    serverId,
    type,
    walletId,
    targetWalletId,
    categoryId,
    amount,
    date,
    note,
    recordedBy,
    spentBy,
    receiptPath,
    updatedAt,
    deleted,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.type == this.type &&
          other.walletId == this.walletId &&
          other.targetWalletId == this.targetWalletId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.note == this.note &&
          other.recordedBy == this.recordedBy &&
          other.spentBy == this.spentBy &&
          other.receiptPath == this.receiptPath &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.pendingSync == this.pendingSync);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> clientId;
  final Value<int?> serverId;
  final Value<String> type;
  final Value<int> walletId;
  final Value<int?> targetWalletId;
  final Value<int?> categoryId;
  final Value<int> amount;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<int> recordedBy;
  final Value<int?> spentBy;
  final Value<String?> receiptPath;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.type = const Value.absent(),
    this.walletId = const Value.absent(),
    this.targetWalletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.spentBy = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String clientId,
    this.serverId = const Value.absent(),
    required String type,
    required int walletId,
    this.targetWalletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int amount,
    required DateTime date,
    this.note = const Value.absent(),
    required int recordedBy,
    this.spentBy = const Value.absent(),
    this.receiptPath = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       type = Value(type),
       walletId = Value(walletId),
       amount = Value(amount),
       date = Value(date),
       recordedBy = Value(recordedBy),
       updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? clientId,
    Expression<int>? serverId,
    Expression<String>? type,
    Expression<int>? walletId,
    Expression<int>? targetWalletId,
    Expression<int>? categoryId,
    Expression<int>? amount,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? recordedBy,
    Expression<int>? spentBy,
    Expression<String>? receiptPath,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (type != null) 'type': type,
      if (walletId != null) 'wallet_id': walletId,
      if (targetWalletId != null) 'target_wallet_id': targetWalletId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (recordedBy != null) 'recorded_by': recordedBy,
      if (spentBy != null) 'spent_by': spentBy,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? clientId,
    Value<int?>? serverId,
    Value<String>? type,
    Value<int>? walletId,
    Value<int?>? targetWalletId,
    Value<int?>? categoryId,
    Value<int>? amount,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<int>? recordedBy,
    Value<int?>? spentBy,
    Value<String?>? receiptPath,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      targetWalletId: targetWalletId ?? this.targetWalletId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      recordedBy: recordedBy ?? this.recordedBy,
      spentBy: spentBy ?? this.spentBy,
      receiptPath: receiptPath ?? this.receiptPath,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (targetWalletId.present) {
      map['target_wallet_id'] = Variable<int>(targetWalletId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordedBy.present) {
      map['recorded_by'] = Variable<int>(recordedBy.value);
    }
    if (spentBy.present) {
      map['spent_by'] = Variable<int>(spentBy.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('type: $type, ')
          ..write('walletId: $walletId, ')
          ..write('targetWalletId: $targetWalletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('spentBy: $spentBy, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMonthMeta = const VerificationMeta(
    'periodMonth',
  );
  @override
  late final GeneratedColumn<String> periodMonth = GeneratedColumn<String>(
    'period_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    ownerUserId,
    categoryId,
    amount,
    periodMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period_month')) {
      context.handle(
        _periodMonthMeta,
        periodMonth.isAcceptableOrUnknown(
          data['period_month']!,
          _periodMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_user_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      periodMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_month'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final String scope;
  final int? ownerUserId;
  final int categoryId;
  final int amount;
  final String periodMonth;
  const Budget({
    required this.id,
    required this.scope,
    this.ownerUserId,
    required this.categoryId,
    required this.amount,
    required this.periodMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<int>(ownerUserId);
    }
    map['category_id'] = Variable<int>(categoryId);
    map['amount'] = Variable<int>(amount);
    map['period_month'] = Variable<String>(periodMonth);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      scope: Value(scope),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      periodMonth: Value(periodMonth),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      ownerUserId: serializer.fromJson<int?>(json['ownerUserId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      amount: serializer.fromJson<int>(json['amount']),
      periodMonth: serializer.fromJson<String>(json['periodMonth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'ownerUserId': serializer.toJson<int?>(ownerUserId),
      'categoryId': serializer.toJson<int>(categoryId),
      'amount': serializer.toJson<int>(amount),
      'periodMonth': serializer.toJson<String>(periodMonth),
    };
  }

  Budget copyWith({
    int? id,
    String? scope,
    Value<int?> ownerUserId = const Value.absent(),
    int? categoryId,
    int? amount,
    String? periodMonth,
  }) => Budget(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    periodMonth: periodMonth ?? this.periodMonth,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      periodMonth: data.periodMonth.present
          ? data.periodMonth.value
          : this.periodMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('periodMonth: $periodMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scope, ownerUserId, categoryId, amount, periodMonth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.ownerUserId == this.ownerUserId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.periodMonth == this.periodMonth);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<String> scope;
  final Value<int?> ownerUserId;
  final Value<int> categoryId;
  final Value<int> amount;
  final Value<String> periodMonth;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.periodMonth = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    this.ownerUserId = const Value.absent(),
    required int categoryId,
    required int amount,
    required String periodMonth,
  }) : scope = Value(scope),
       categoryId = Value(categoryId),
       amount = Value(amount),
       periodMonth = Value(periodMonth);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<int>? ownerUserId,
    Expression<int>? categoryId,
    Expression<int>? amount,
    Expression<String>? periodMonth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (periodMonth != null) 'period_month': periodMonth,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<int?>? ownerUserId,
    Value<int>? categoryId,
    Value<int>? amount,
    Value<String>? periodMonth,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      periodMonth: periodMonth ?? this.periodMonth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<String>(periodMonth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('periodMonth: $periodMonth')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAmountMeta = const VerificationMeta(
    'currentAmount',
  );
  @override
  late final GeneratedColumn<int> currentAmount = GeneratedColumn<int>(
    'current_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hueMeta = const VerificationMeta('hue');
  @override
  late final GeneratedColumn<int> hue = GeneratedColumn<int>(
    'hue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    ownerUserId,
    name,
    targetAmount,
    currentAmount,
    targetDate,
    walletId,
    icon,
    hue,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
        _currentAmountMeta,
        currentAmount.isAcceptableOrUnknown(
          data['current_amount']!,
          _currentAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentAmountMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('hue')) {
      context.handle(
        _hueMeta,
        hue.isAcceptableOrUnknown(data['hue']!, _hueMeta),
      );
    } else if (isInserting) {
      context.missing(_hueMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount'],
      )!,
      currentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_amount'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      hue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hue'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final int id;
  final String scope;
  final int? ownerUserId;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime? targetDate;
  final int walletId;
  final String icon;
  final int hue;
  final bool deleted;
  const SavingsGoal({
    required this.id,
    required this.scope,
    this.ownerUserId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.walletId,
    required this.icon,
    required this.hue,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<int>(ownerUserId);
    }
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<int>(targetAmount);
    map['current_amount'] = Variable<int>(currentAmount);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['wallet_id'] = Variable<int>(walletId);
    map['icon'] = Variable<String>(icon);
    map['hue'] = Variable<int>(hue);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      scope: Value(scope),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      walletId: Value(walletId),
      icon: Value(icon),
      hue: Value(hue),
      deleted: Value(deleted),
    );
  }

  factory SavingsGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      ownerUserId: serializer.fromJson<int?>(json['ownerUserId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      currentAmount: serializer.fromJson<int>(json['currentAmount']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      walletId: serializer.fromJson<int>(json['walletId']),
      icon: serializer.fromJson<String>(json['icon']),
      hue: serializer.fromJson<int>(json['hue']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'ownerUserId': serializer.toJson<int?>(ownerUserId),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'currentAmount': serializer.toJson<int>(currentAmount),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'walletId': serializer.toJson<int>(walletId),
      'icon': serializer.toJson<String>(icon),
      'hue': serializer.toJson<int>(hue),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  SavingsGoal copyWith({
    int? id,
    String? scope,
    Value<int?> ownerUserId = const Value.absent(),
    String? name,
    int? targetAmount,
    int? currentAmount,
    Value<DateTime?> targetDate = const Value.absent(),
    int? walletId,
    String? icon,
    int? hue,
    bool? deleted,
  }) => SavingsGoal(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    walletId: walletId ?? this.walletId,
    icon: icon ?? this.icon,
    hue: hue ?? this.hue,
    deleted: deleted ?? this.deleted,
  );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      icon: data.icon.present ? data.icon.value : this.icon,
      hue: data.hue.present ? data.hue.value : this.hue,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('walletId: $walletId, ')
          ..write('icon: $icon, ')
          ..write('hue: $hue, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    ownerUserId,
    name,
    targetAmount,
    currentAmount,
    targetDate,
    walletId,
    icon,
    hue,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.ownerUserId == this.ownerUserId &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.targetDate == this.targetDate &&
          other.walletId == this.walletId &&
          other.icon == this.icon &&
          other.hue == this.hue &&
          other.deleted == this.deleted);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<int> id;
  final Value<String> scope;
  final Value<int?> ownerUserId;
  final Value<String> name;
  final Value<int> targetAmount;
  final Value<int> currentAmount;
  final Value<DateTime?> targetDate;
  final Value<int> walletId;
  final Value<String> icon;
  final Value<int> hue;
  final Value<bool> deleted;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.walletId = const Value.absent(),
    this.icon = const Value.absent(),
    this.hue = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    this.ownerUserId = const Value.absent(),
    required String name,
    required int targetAmount,
    required int currentAmount,
    this.targetDate = const Value.absent(),
    required int walletId,
    required String icon,
    required int hue,
    this.deleted = const Value.absent(),
  }) : scope = Value(scope),
       name = Value(name),
       targetAmount = Value(targetAmount),
       currentAmount = Value(currentAmount),
       walletId = Value(walletId),
       icon = Value(icon),
       hue = Value(hue);
  static Insertable<SavingsGoal> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<int>? ownerUserId,
    Expression<String>? name,
    Expression<int>? targetAmount,
    Expression<int>? currentAmount,
    Expression<DateTime>? targetDate,
    Expression<int>? walletId,
    Expression<String>? icon,
    Expression<int>? hue,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (targetDate != null) 'target_date': targetDate,
      if (walletId != null) 'wallet_id': walletId,
      if (icon != null) 'icon': icon,
      if (hue != null) 'hue': hue,
      if (deleted != null) 'deleted': deleted,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<int?>? ownerUserId,
    Value<String>? name,
    Value<int>? targetAmount,
    Value<int>? currentAmount,
    Value<DateTime?>? targetDate,
    Value<int>? walletId,
    Value<String>? icon,
    Value<int>? hue,
    Value<bool>? deleted,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      walletId: walletId ?? this.walletId,
      icon: icon ?? this.icon,
      hue: hue ?? this.hue,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<int>(currentAmount.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (hue.present) {
      map['hue'] = Variable<int>(hue.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('walletId: $walletId, ')
          ..write('icon: $icon, ')
          ..write('hue: $hue, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyNameMeta = const VerificationMeta(
    'partyName',
  );
  @override
  late final GeneratedColumn<String> partyName = GeneratedColumn<String>(
    'party_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<int> paid = GeneratedColumn<int>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUserId,
    type,
    partyName,
    amount,
    paid,
    date,
    dueDate,
    status,
    note,
    walletId,
    deleted,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('party_name')) {
      context.handle(
        _partyNameMeta,
        partyName.isAcceptableOrUnknown(data['party_name']!, _partyNameMeta),
      );
    } else if (isInserting) {
      context.missing(_partyNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    } else if (isInserting) {
      context.missing(_paidMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_user_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      partyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final int id;
  final int? ownerUserId;
  final String type;
  final String partyName;
  final int amount;
  final int paid;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final String? note;
  final int? walletId;
  final bool deleted;
  final bool pendingSync;
  const Debt({
    required this.id,
    this.ownerUserId,
    required this.type,
    required this.partyName,
    required this.amount,
    required this.paid,
    required this.date,
    this.dueDate,
    required this.status,
    this.note,
    this.walletId,
    required this.deleted,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<int>(ownerUserId);
    }
    map['type'] = Variable<String>(type);
    map['party_name'] = Variable<String>(partyName);
    map['amount'] = Variable<int>(amount);
    map['paid'] = Variable<int>(paid);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<int>(walletId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      type: Value(type),
      partyName: Value(partyName),
      amount: Value(amount),
      paid: Value(paid),
      date: Value(date),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      deleted: Value(deleted),
      pendingSync: Value(pendingSync),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<int>(json['id']),
      ownerUserId: serializer.fromJson<int?>(json['ownerUserId']),
      type: serializer.fromJson<String>(json['type']),
      partyName: serializer.fromJson<String>(json['partyName']),
      amount: serializer.fromJson<int>(json['amount']),
      paid: serializer.fromJson<int>(json['paid']),
      date: serializer.fromJson<DateTime>(json['date']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      walletId: serializer.fromJson<int?>(json['walletId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ownerUserId': serializer.toJson<int?>(ownerUserId),
      'type': serializer.toJson<String>(type),
      'partyName': serializer.toJson<String>(partyName),
      'amount': serializer.toJson<int>(amount),
      'paid': serializer.toJson<int>(paid),
      'date': serializer.toJson<DateTime>(date),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'walletId': serializer.toJson<int?>(walletId),
      'deleted': serializer.toJson<bool>(deleted),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  Debt copyWith({
    int? id,
    Value<int?> ownerUserId = const Value.absent(),
    String? type,
    String? partyName,
    int? amount,
    int? paid,
    DateTime? date,
    Value<DateTime?> dueDate = const Value.absent(),
    String? status,
    Value<String?> note = const Value.absent(),
    Value<int?> walletId = const Value.absent(),
    bool? deleted,
    bool? pendingSync,
  }) => Debt(
    id: id ?? this.id,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    type: type ?? this.type,
    partyName: partyName ?? this.partyName,
    amount: amount ?? this.amount,
    paid: paid ?? this.paid,
    date: date ?? this.date,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    walletId: walletId.present ? walletId.value : this.walletId,
    deleted: deleted ?? this.deleted,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      type: data.type.present ? data.type.value : this.type,
      partyName: data.partyName.present ? data.partyName.value : this.partyName,
      amount: data.amount.present ? data.amount.value : this.amount,
      paid: data.paid.present ? data.paid.value : this.paid,
      date: data.date.present ? data.date.value : this.date,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('type: $type, ')
          ..write('partyName: $partyName, ')
          ..write('amount: $amount, ')
          ..write('paid: $paid, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('walletId: $walletId, ')
          ..write('deleted: $deleted, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUserId,
    type,
    partyName,
    amount,
    paid,
    date,
    dueDate,
    status,
    note,
    walletId,
    deleted,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.type == this.type &&
          other.partyName == this.partyName &&
          other.amount == this.amount &&
          other.paid == this.paid &&
          other.date == this.date &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.note == this.note &&
          other.walletId == this.walletId &&
          other.deleted == this.deleted &&
          other.pendingSync == this.pendingSync);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<int> id;
  final Value<int?> ownerUserId;
  final Value<String> type;
  final Value<String> partyName;
  final Value<int> amount;
  final Value<int> paid;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<String?> note;
  final Value<int?> walletId;
  final Value<bool> deleted;
  final Value<bool> pendingSync;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.type = const Value.absent(),
    this.partyName = const Value.absent(),
    this.amount = const Value.absent(),
    this.paid = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.walletId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    required String type,
    required String partyName,
    required int amount,
    required int paid,
    required DateTime date,
    this.dueDate = const Value.absent(),
    required String status,
    this.note = const Value.absent(),
    this.walletId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
  }) : type = Value(type),
       partyName = Value(partyName),
       amount = Value(amount),
       paid = Value(paid),
       date = Value(date),
       status = Value(status);
  static Insertable<Debt> custom({
    Expression<int>? id,
    Expression<int>? ownerUserId,
    Expression<String>? type,
    Expression<String>? partyName,
    Expression<int>? amount,
    Expression<int>? paid,
    Expression<DateTime>? date,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? note,
    Expression<int>? walletId,
    Expression<bool>? deleted,
    Expression<bool>? pendingSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (type != null) 'type': type,
      if (partyName != null) 'party_name': partyName,
      if (amount != null) 'amount': amount,
      if (paid != null) 'paid': paid,
      if (date != null) 'date': date,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (walletId != null) 'wallet_id': walletId,
      if (deleted != null) 'deleted': deleted,
      if (pendingSync != null) 'pending_sync': pendingSync,
    });
  }

  DebtsCompanion copyWith({
    Value<int>? id,
    Value<int?>? ownerUserId,
    Value<String>? type,
    Value<String>? partyName,
    Value<int>? amount,
    Value<int>? paid,
    Value<DateTime>? date,
    Value<DateTime?>? dueDate,
    Value<String>? status,
    Value<String?>? note,
    Value<int?>? walletId,
    Value<bool>? deleted,
    Value<bool>? pendingSync,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      type: type ?? this.type,
      partyName: partyName ?? this.partyName,
      amount: amount ?? this.amount,
      paid: paid ?? this.paid,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      note: note ?? this.note,
      walletId: walletId ?? this.walletId,
      deleted: deleted ?? this.deleted,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (partyName.present) {
      map['party_name'] = Variable<String>(partyName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (paid.present) {
      map['paid'] = Variable<int>(paid.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('type: $type, ')
          ..write('partyName: $partyName, ')
          ..write('amount: $amount, ')
          ..write('paid: $paid, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('walletId: $walletId, ')
          ..write('deleted: $deleted, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }
}

class $RecurringsTable extends Recurrings
    with TableInfo<$RecurringsTable, Recurring> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _freqMeta = const VerificationMeta('freq');
  @override
  late final GeneratedColumn<String> freq = GeneratedColumn<String>(
    'freq',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextRunDateMeta = const VerificationMeta(
    'nextRunDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextRunDate = GeneratedColumn<DateTime>(
    'next_run_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoCreateMeta = const VerificationMeta(
    'autoCreate',
  );
  @override
  late final GeneratedColumn<bool> autoCreate = GeneratedColumn<bool>(
    'auto_create',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_create" IN (0, 1))',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    walletId,
    categoryId,
    amount,
    freq,
    nextRunDate,
    endDate,
    autoCreate,
    note,
    createdBy,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recurring> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('freq')) {
      context.handle(
        _freqMeta,
        freq.isAcceptableOrUnknown(data['freq']!, _freqMeta),
      );
    } else if (isInserting) {
      context.missing(_freqMeta);
    }
    if (data.containsKey('next_run_date')) {
      context.handle(
        _nextRunDateMeta,
        nextRunDate.isAcceptableOrUnknown(
          data['next_run_date']!,
          _nextRunDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextRunDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('auto_create')) {
      context.handle(
        _autoCreateMeta,
        autoCreate.isAcceptableOrUnknown(data['auto_create']!, _autoCreateMeta),
      );
    } else if (isInserting) {
      context.missing(_autoCreateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recurring map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recurring(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      freq: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freq'],
      )!,
      nextRunDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_run_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      autoCreate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_create'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $RecurringsTable createAlias(String alias) {
    return $RecurringsTable(attachedDatabase, alias);
  }
}

class Recurring extends DataClass implements Insertable<Recurring> {
  final int id;
  final String type;
  final int walletId;
  final int categoryId;
  final int amount;
  final String freq;
  final DateTime nextRunDate;
  final DateTime? endDate;
  final bool autoCreate;
  final String? note;
  final int createdBy;
  final bool pendingSync;
  const Recurring({
    required this.id,
    required this.type,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.freq,
    required this.nextRunDate,
    this.endDate,
    required this.autoCreate,
    this.note,
    required this.createdBy,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['wallet_id'] = Variable<int>(walletId);
    map['category_id'] = Variable<int>(categoryId);
    map['amount'] = Variable<int>(amount);
    map['freq'] = Variable<String>(freq);
    map['next_run_date'] = Variable<DateTime>(nextRunDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['auto_create'] = Variable<bool>(autoCreate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_by'] = Variable<int>(createdBy);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  RecurringsCompanion toCompanion(bool nullToAbsent) {
    return RecurringsCompanion(
      id: Value(id),
      type: Value(type),
      walletId: Value(walletId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      freq: Value(freq),
      nextRunDate: Value(nextRunDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      autoCreate: Value(autoCreate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdBy: Value(createdBy),
      pendingSync: Value(pendingSync),
    );
  }

  factory Recurring.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recurring(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      walletId: serializer.fromJson<int>(json['walletId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      amount: serializer.fromJson<int>(json['amount']),
      freq: serializer.fromJson<String>(json['freq']),
      nextRunDate: serializer.fromJson<DateTime>(json['nextRunDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      autoCreate: serializer.fromJson<bool>(json['autoCreate']),
      note: serializer.fromJson<String?>(json['note']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'walletId': serializer.toJson<int>(walletId),
      'categoryId': serializer.toJson<int>(categoryId),
      'amount': serializer.toJson<int>(amount),
      'freq': serializer.toJson<String>(freq),
      'nextRunDate': serializer.toJson<DateTime>(nextRunDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'autoCreate': serializer.toJson<bool>(autoCreate),
      'note': serializer.toJson<String?>(note),
      'createdBy': serializer.toJson<int>(createdBy),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  Recurring copyWith({
    int? id,
    String? type,
    int? walletId,
    int? categoryId,
    int? amount,
    String? freq,
    DateTime? nextRunDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? autoCreate,
    Value<String?> note = const Value.absent(),
    int? createdBy,
    bool? pendingSync,
  }) => Recurring(
    id: id ?? this.id,
    type: type ?? this.type,
    walletId: walletId ?? this.walletId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    freq: freq ?? this.freq,
    nextRunDate: nextRunDate ?? this.nextRunDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    autoCreate: autoCreate ?? this.autoCreate,
    note: note.present ? note.value : this.note,
    createdBy: createdBy ?? this.createdBy,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  Recurring copyWithCompanion(RecurringsCompanion data) {
    return Recurring(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      freq: data.freq.present ? data.freq.value : this.freq,
      nextRunDate: data.nextRunDate.present
          ? data.nextRunDate.value
          : this.nextRunDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      autoCreate: data.autoCreate.present
          ? data.autoCreate.value
          : this.autoCreate,
      note: data.note.present ? data.note.value : this.note,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recurring(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('walletId: $walletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('freq: $freq, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('endDate: $endDate, ')
          ..write('autoCreate: $autoCreate, ')
          ..write('note: $note, ')
          ..write('createdBy: $createdBy, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    walletId,
    categoryId,
    amount,
    freq,
    nextRunDate,
    endDate,
    autoCreate,
    note,
    createdBy,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recurring &&
          other.id == this.id &&
          other.type == this.type &&
          other.walletId == this.walletId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.freq == this.freq &&
          other.nextRunDate == this.nextRunDate &&
          other.endDate == this.endDate &&
          other.autoCreate == this.autoCreate &&
          other.note == this.note &&
          other.createdBy == this.createdBy &&
          other.pendingSync == this.pendingSync);
}

class RecurringsCompanion extends UpdateCompanion<Recurring> {
  final Value<int> id;
  final Value<String> type;
  final Value<int> walletId;
  final Value<int> categoryId;
  final Value<int> amount;
  final Value<String> freq;
  final Value<DateTime> nextRunDate;
  final Value<DateTime?> endDate;
  final Value<bool> autoCreate;
  final Value<String?> note;
  final Value<int> createdBy;
  final Value<bool> pendingSync;
  const RecurringsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.walletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.freq = const Value.absent(),
    this.nextRunDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.autoCreate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.pendingSync = const Value.absent(),
  });
  RecurringsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required int walletId,
    required int categoryId,
    required int amount,
    required String freq,
    required DateTime nextRunDate,
    this.endDate = const Value.absent(),
    required bool autoCreate,
    this.note = const Value.absent(),
    required int createdBy,
    this.pendingSync = const Value.absent(),
  }) : type = Value(type),
       walletId = Value(walletId),
       categoryId = Value(categoryId),
       amount = Value(amount),
       freq = Value(freq),
       nextRunDate = Value(nextRunDate),
       autoCreate = Value(autoCreate),
       createdBy = Value(createdBy);
  static Insertable<Recurring> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? walletId,
    Expression<int>? categoryId,
    Expression<int>? amount,
    Expression<String>? freq,
    Expression<DateTime>? nextRunDate,
    Expression<DateTime>? endDate,
    Expression<bool>? autoCreate,
    Expression<String>? note,
    Expression<int>? createdBy,
    Expression<bool>? pendingSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (walletId != null) 'wallet_id': walletId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (freq != null) 'freq': freq,
      if (nextRunDate != null) 'next_run_date': nextRunDate,
      if (endDate != null) 'end_date': endDate,
      if (autoCreate != null) 'auto_create': autoCreate,
      if (note != null) 'note': note,
      if (createdBy != null) 'created_by': createdBy,
      if (pendingSync != null) 'pending_sync': pendingSync,
    });
  }

  RecurringsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<int>? walletId,
    Value<int>? categoryId,
    Value<int>? amount,
    Value<String>? freq,
    Value<DateTime>? nextRunDate,
    Value<DateTime?>? endDate,
    Value<bool>? autoCreate,
    Value<String?>? note,
    Value<int>? createdBy,
    Value<bool>? pendingSync,
  }) {
    return RecurringsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      freq: freq ?? this.freq,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      endDate: endDate ?? this.endDate,
      autoCreate: autoCreate ?? this.autoCreate,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (freq.present) {
      map['freq'] = Variable<String>(freq.value);
    }
    if (nextRunDate.present) {
      map['next_run_date'] = Variable<DateTime>(nextRunDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (autoCreate.present) {
      map['auto_create'] = Variable<bool>(autoCreate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('walletId: $walletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('freq: $freq, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('endDate: $endDate, ')
          ..write('autoCreate: $autoCreate, ')
          ..write('note: $note, ')
          ..write('createdBy: $createdBy, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<int> householdId = GeneratedColumn<int>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    userId,
    type,
    title,
    body,
    data,
    readAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}household_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final int id;
  final int householdId;
  final int? userId;
  final String type;
  final String title;
  final String body;
  final String? data;
  final DateTime? readAt;
  final DateTime createdAt;
  const Notification({
    required this.id,
    required this.householdId,
    this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['household_id'] = Variable<int>(householdId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      createdAt: Value(createdAt),
    );
  }

  factory Notification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<int>(json['id']),
      householdId: serializer.fromJson<int>(json['householdId']),
      userId: serializer.fromJson<int?>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      data: serializer.fromJson<String?>(json['data']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'householdId': serializer.toJson<int>(householdId),
      'userId': serializer.toJson<int?>(userId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'data': serializer.toJson<String?>(data),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notification copyWith({
    int? id,
    int? householdId,
    Value<int?> userId = const Value.absent(),
    String? type,
    String? title,
    String? body,
    Value<String?> data = const Value.absent(),
    Value<DateTime?> readAt = const Value.absent(),
    DateTime? createdAt,
  }) => Notification(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    userId: userId.present ? userId.value : this.userId,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    data: data.present ? data.value : this.data,
    readAt: readAt.present ? readAt.value : this.readAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      data: data.data.present ? data.data.value : this.data,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('data: $data, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    userId,
    type,
    title,
    body,
    data,
    readAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.data == this.data &&
          other.readAt == this.readAt &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<int> id;
  final Value<int> householdId;
  final Value<int?> userId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> data;
  final Value<DateTime?> readAt;
  final Value<DateTime> createdAt;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.data = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    required int householdId,
    this.userId = const Value.absent(),
    required String type,
    required String title,
    required String body,
    this.data = const Value.absent(),
    this.readAt = const Value.absent(),
    required DateTime createdAt,
  }) : householdId = Value(householdId),
       type = Value(type),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<Notification> custom({
    Expression<int>? id,
    Expression<int>? householdId,
    Expression<int>? userId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? data,
    Expression<DateTime>? readAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (data != null) 'data': data,
      if (readAt != null) 'read_at': readAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationsCompanion copyWith({
    Value<int>? id,
    Value<int>? householdId,
    Value<int?>? userId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? data,
    Value<DateTime?>? readAt,
    Value<DateTime>? createdAt,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<int>(householdId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('data: $data, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SessionKvTable extends SessionKv
    with TableInfo<$SessionKvTable, SessionKvData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionKvData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SessionKvData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionKvData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SessionKvTable createAlias(String alias) {
    return $SessionKvTable(attachedDatabase, alias);
  }
}

class SessionKvData extends DataClass implements Insertable<SessionKvData> {
  final String key;
  final String value;
  const SessionKvData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SessionKvCompanion toCompanion(bool nullToAbsent) {
    return SessionKvCompanion(key: Value(key), value: Value(value));
  }

  factory SessionKvData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionKvData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SessionKvData copyWith({String? key, String? value}) =>
      SessionKvData(key: key ?? this.key, value: value ?? this.value);
  SessionKvData copyWithCompanion(SessionKvCompanion data) {
    return SessionKvData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionKvData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionKvData &&
          other.key == this.key &&
          other.value == this.value);
}

class SessionKvCompanion extends UpdateCompanion<SessionKvData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SessionKvCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionKvCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SessionKvData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionKvCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SessionKvCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionKvCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $RecurringsTable recurrings = $RecurringsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $SessionKvTable sessionKv = $SessionKvTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    members,
    wallets,
    categories,
    transactions,
    budgets,
    savingsGoals,
    debts,
    recurrings,
    notifications,
    sessionKv,
  ];
}

typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      required String role,
      required int avatarHue,
      Value<String?> phone,
      Value<String?> avatarPath,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String> role,
      Value<int> avatarHue,
      Value<String?> phone,
      Value<String?> avatarPath,
    });

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avatarHue => $composableBuilder(
    column: $table.avatarHue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avatarHue => $composableBuilder(
    column: $table.avatarHue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get avatarHue =>
      $composableBuilder(column: $table.avatarHue, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
          Member,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> avatarHue = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                name: name,
                email: email,
                role: role,
                avatarHue: avatarHue,
                phone: phone,
                avatarPath: avatarPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                required String role,
                required int avatarHue,
                Value<String?> phone = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                name: name,
                email: email,
                role: role,
                avatarHue: avatarHue,
                phone: phone,
                avatarPath: avatarPath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
      Member,
      PrefetchHooks Function()
    >;
typedef $$WalletsTableCreateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      required String scope,
      Value<int?> ownerUserId,
      required String name,
      required String type,
      Value<String?> icon,
      required int initialBalance,
      required int currentBalance,
      Value<bool> deleted,
    });
typedef $$WalletsTableUpdateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      Value<String> scope,
      Value<int?> ownerUserId,
      Value<String> name,
      Value<String> type,
      Value<String?> icon,
      Value<int> initialBalance,
      Value<int> currentBalance,
      Value<bool> deleted,
    });

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          Wallet,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (Wallet, BaseReferences<_$AppDatabase, $WalletsTable, Wallet>),
          Wallet,
          PrefetchHooks Function()
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int?> ownerUserId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> initialBalance = const Value.absent(),
                Value<int> currentBalance = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => WalletsCompanion(
                id: id,
                scope: scope,
                ownerUserId: ownerUserId,
                name: name,
                type: type,
                icon: icon,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                Value<int?> ownerUserId = const Value.absent(),
                required String name,
                required String type,
                Value<String?> icon = const Value.absent(),
                required int initialBalance,
                required int currentBalance,
                Value<bool> deleted = const Value.absent(),
              }) => WalletsCompanion.insert(
                id: id,
                scope: scope,
                ownerUserId: ownerUserId,
                name: name,
                type: type,
                icon: icon,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      Wallet,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (Wallet, BaseReferences<_$AppDatabase, $WalletsTable, Wallet>),
      Wallet,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required String icon,
      required int hue,
      Value<int?> parentId,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String> icon,
      Value<int> hue,
      Value<int?> parentId,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hue => $composableBuilder(
    column: $table.hue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hue => $composableBuilder(
    column: $table.hue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get hue =>
      $composableBuilder(column: $table.hue, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> hue = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                icon: icon,
                hue: hue,
                parentId: parentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required String icon,
                required int hue,
                Value<int?> parentId = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                icon: icon,
                hue: hue,
                parentId: parentId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String clientId,
      Value<int?> serverId,
      required String type,
      required int walletId,
      Value<int?> targetWalletId,
      Value<int?> categoryId,
      required int amount,
      required DateTime date,
      Value<String?> note,
      required int recordedBy,
      Value<int?> spentBy,
      Value<String?> receiptPath,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> clientId,
      Value<int?> serverId,
      Value<String> type,
      Value<int> walletId,
      Value<int?> targetWalletId,
      Value<int?> categoryId,
      Value<int> amount,
      Value<DateTime> date,
      Value<String?> note,
      Value<int> recordedBy,
      Value<int?> spentBy,
      Value<String?> receiptPath,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWalletId => $composableBuilder(
    column: $table.targetWalletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedBy => $composableBuilder(
    column: $table.recordedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spentBy => $composableBuilder(
    column: $table.spentBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWalletId => $composableBuilder(
    column: $table.targetWalletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedBy => $composableBuilder(
    column: $table.recordedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spentBy => $composableBuilder(
    column: $table.spentBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<int> get targetWalletId => $composableBuilder(
    column: $table.targetWalletId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get recordedBy => $composableBuilder(
    column: $table.recordedBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get spentBy =>
      $composableBuilder(column: $table.spentBy, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<int?> targetWalletId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> recordedBy = const Value.absent(),
                Value<int?> spentBy = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                clientId: clientId,
                serverId: serverId,
                type: type,
                walletId: walletId,
                targetWalletId: targetWalletId,
                categoryId: categoryId,
                amount: amount,
                date: date,
                note: note,
                recordedBy: recordedBy,
                spentBy: spentBy,
                receiptPath: receiptPath,
                updatedAt: updatedAt,
                deleted: deleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<int?> serverId = const Value.absent(),
                required String type,
                required int walletId,
                Value<int?> targetWalletId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                required int amount,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                required int recordedBy,
                Value<int?> spentBy = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                clientId: clientId,
                serverId: serverId,
                type: type,
                walletId: walletId,
                targetWalletId: targetWalletId,
                categoryId: categoryId,
                amount: amount,
                date: date,
                note: note,
                recordedBy: recordedBy,
                spentBy: spentBy,
                receiptPath: receiptPath,
                updatedAt: updatedAt,
                deleted: deleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required String scope,
      Value<int?> ownerUserId,
      required int categoryId,
      required int amount,
      required String periodMonth,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<String> scope,
      Value<int?> ownerUserId,
      Value<int> categoryId,
      Value<int> amount,
      Value<String> periodMonth,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => column,
  );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int?> ownerUserId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> periodMonth = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                scope: scope,
                ownerUserId: ownerUserId,
                categoryId: categoryId,
                amount: amount,
                periodMonth: periodMonth,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                Value<int?> ownerUserId = const Value.absent(),
                required int categoryId,
                required int amount,
                required String periodMonth,
              }) => BudgetsCompanion.insert(
                id: id,
                scope: scope,
                ownerUserId: ownerUserId,
                categoryId: categoryId,
                amount: amount,
                periodMonth: periodMonth,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<int> id,
      required String scope,
      Value<int?> ownerUserId,
      required String name,
      required int targetAmount,
      required int currentAmount,
      Value<DateTime?> targetDate,
      required int walletId,
      required String icon,
      required int hue,
      Value<bool> deleted,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<int> id,
      Value<String> scope,
      Value<int?> ownerUserId,
      Value<String> name,
      Value<int> targetAmount,
      Value<int> currentAmount,
      Value<DateTime?> targetDate,
      Value<int> walletId,
      Value<String> icon,
      Value<int> hue,
      Value<bool> deleted,
    });

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hue => $composableBuilder(
    column: $table.hue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hue => $composableBuilder(
    column: $table.hue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get hue =>
      $composableBuilder(column: $table.hue, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoal,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (
            SavingsGoal,
            BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
          ),
          SavingsGoal,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int?> ownerUserId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetAmount = const Value.absent(),
                Value<int> currentAmount = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> hue = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => SavingsGoalsCompanion(
                id: id,
                scope: scope,
                ownerUserId: ownerUserId,
                name: name,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                targetDate: targetDate,
                walletId: walletId,
                icon: icon,
                hue: hue,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                Value<int?> ownerUserId = const Value.absent(),
                required String name,
                required int targetAmount,
                required int currentAmount,
                Value<DateTime?> targetDate = const Value.absent(),
                required int walletId,
                required String icon,
                required int hue,
                Value<bool> deleted = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                id: id,
                scope: scope,
                ownerUserId: ownerUserId,
                name: name,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                targetDate: targetDate,
                walletId: walletId,
                icon: icon,
                hue: hue,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoal,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (
        SavingsGoal,
        BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
      ),
      SavingsGoal,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      Value<int> id,
      Value<int?> ownerUserId,
      required String type,
      required String partyName,
      required int amount,
      required int paid,
      required DateTime date,
      Value<DateTime?> dueDate,
      required String status,
      Value<String?> note,
      Value<int?> walletId,
      Value<bool> deleted,
      Value<bool> pendingSync,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<int> id,
      Value<int?> ownerUserId,
      Value<String> type,
      Value<String> partyName,
      Value<int> amount,
      Value<int> paid,
      Value<DateTime> date,
      Value<DateTime?> dueDate,
      Value<String> status,
      Value<String?> note,
      Value<int?> walletId,
      Value<bool> deleted,
      Value<bool> pendingSync,
    });

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
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

  ColumnFilters<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyName => $composableBuilder(
    column: $table.partyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
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

  ColumnOrderings<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyName => $composableBuilder(
    column: $table.partyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get partyName =>
      $composableBuilder(column: $table.partyName, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> ownerUserId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> partyName = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> paid = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> walletId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                ownerUserId: ownerUserId,
                type: type,
                partyName: partyName,
                amount: amount,
                paid: paid,
                date: date,
                dueDate: dueDate,
                status: status,
                note: note,
                walletId: walletId,
                deleted: deleted,
                pendingSync: pendingSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> ownerUserId = const Value.absent(),
                required String type,
                required String partyName,
                required int amount,
                required int paid,
                required DateTime date,
                Value<DateTime?> dueDate = const Value.absent(),
                required String status,
                Value<String?> note = const Value.absent(),
                Value<int?> walletId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                ownerUserId: ownerUserId,
                type: type,
                partyName: partyName,
                amount: amount,
                paid: paid,
                date: date,
                dueDate: dueDate,
                status: status,
                note: note,
                walletId: walletId,
                deleted: deleted,
                pendingSync: pendingSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;
typedef $$RecurringsTableCreateCompanionBuilder =
    RecurringsCompanion Function({
      Value<int> id,
      required String type,
      required int walletId,
      required int categoryId,
      required int amount,
      required String freq,
      required DateTime nextRunDate,
      Value<DateTime?> endDate,
      required bool autoCreate,
      Value<String?> note,
      required int createdBy,
      Value<bool> pendingSync,
    });
typedef $$RecurringsTableUpdateCompanionBuilder =
    RecurringsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<int> walletId,
      Value<int> categoryId,
      Value<int> amount,
      Value<String> freq,
      Value<DateTime> nextRunDate,
      Value<DateTime?> endDate,
      Value<bool> autoCreate,
      Value<String?> note,
      Value<int> createdBy,
      Value<bool> pendingSync,
    });

class $$RecurringsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringsTable> {
  $$RecurringsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoCreate => $composableBuilder(
    column: $table.autoCreate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringsTable> {
  $$RecurringsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoCreate => $composableBuilder(
    column: $table.autoCreate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringsTable> {
  $$RecurringsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get freq =>
      $composableBuilder(column: $table.freq, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get autoCreate => $composableBuilder(
    column: $table.autoCreate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$RecurringsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringsTable,
          Recurring,
          $$RecurringsTableFilterComposer,
          $$RecurringsTableOrderingComposer,
          $$RecurringsTableAnnotationComposer,
          $$RecurringsTableCreateCompanionBuilder,
          $$RecurringsTableUpdateCompanionBuilder,
          (
            Recurring,
            BaseReferences<_$AppDatabase, $RecurringsTable, Recurring>,
          ),
          Recurring,
          PrefetchHooks Function()
        > {
  $$RecurringsTableTableManager(_$AppDatabase db, $RecurringsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> freq = const Value.absent(),
                Value<DateTime> nextRunDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> autoCreate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdBy = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
              }) => RecurringsCompanion(
                id: id,
                type: type,
                walletId: walletId,
                categoryId: categoryId,
                amount: amount,
                freq: freq,
                nextRunDate: nextRunDate,
                endDate: endDate,
                autoCreate: autoCreate,
                note: note,
                createdBy: createdBy,
                pendingSync: pendingSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required int walletId,
                required int categoryId,
                required int amount,
                required String freq,
                required DateTime nextRunDate,
                Value<DateTime?> endDate = const Value.absent(),
                required bool autoCreate,
                Value<String?> note = const Value.absent(),
                required int createdBy,
                Value<bool> pendingSync = const Value.absent(),
              }) => RecurringsCompanion.insert(
                id: id,
                type: type,
                walletId: walletId,
                categoryId: categoryId,
                amount: amount,
                freq: freq,
                nextRunDate: nextRunDate,
                endDate: endDate,
                autoCreate: autoCreate,
                note: note,
                createdBy: createdBy,
                pendingSync: pendingSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringsTable,
      Recurring,
      $$RecurringsTableFilterComposer,
      $$RecurringsTableOrderingComposer,
      $$RecurringsTableAnnotationComposer,
      $$RecurringsTableCreateCompanionBuilder,
      $$RecurringsTableUpdateCompanionBuilder,
      (Recurring, BaseReferences<_$AppDatabase, $RecurringsTable, Recurring>),
      Recurring,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      required int householdId,
      Value<int?> userId,
      required String type,
      required String title,
      required String body,
      Value<String?> data,
      Value<DateTime?> readAt,
      required DateTime createdAt,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      Value<int> householdId,
      Value<int?> userId,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String?> data,
      Value<DateTime?> readAt,
      Value<DateTime> createdAt,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
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

  ColumnFilters<int> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
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

  ColumnOrderings<int> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            Notification,
            BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
          ),
          Notification,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> householdId = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                householdId: householdId,
                userId: userId,
                type: type,
                title: title,
                body: body,
                data: data,
                readAt: readAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int householdId,
                Value<int?> userId = const Value.absent(),
                required String type,
                required String title,
                required String body,
                Value<String?> data = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                required DateTime createdAt,
              }) => NotificationsCompanion.insert(
                id: id,
                householdId: householdId,
                userId: userId,
                type: type,
                title: title,
                body: body,
                data: data,
                readAt: readAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        Notification,
        BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
      ),
      Notification,
      PrefetchHooks Function()
    >;
typedef $$SessionKvTableCreateCompanionBuilder =
    SessionKvCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SessionKvTableUpdateCompanionBuilder =
    SessionKvCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SessionKvTableFilterComposer
    extends Composer<_$AppDatabase, $SessionKvTable> {
  $$SessionKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionKvTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionKvTable> {
  $$SessionKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionKvTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionKvTable> {
  $$SessionKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SessionKvTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionKvTable,
          SessionKvData,
          $$SessionKvTableFilterComposer,
          $$SessionKvTableOrderingComposer,
          $$SessionKvTableAnnotationComposer,
          $$SessionKvTableCreateCompanionBuilder,
          $$SessionKvTableUpdateCompanionBuilder,
          (
            SessionKvData,
            BaseReferences<_$AppDatabase, $SessionKvTable, SessionKvData>,
          ),
          SessionKvData,
          PrefetchHooks Function()
        > {
  $$SessionKvTableTableManager(_$AppDatabase db, $SessionKvTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionKvCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SessionKvCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionKvTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionKvTable,
      SessionKvData,
      $$SessionKvTableFilterComposer,
      $$SessionKvTableOrderingComposer,
      $$SessionKvTableAnnotationComposer,
      $$SessionKvTableCreateCompanionBuilder,
      $$SessionKvTableUpdateCompanionBuilder,
      (
        SessionKvData,
        BaseReferences<_$AppDatabase, $SessionKvTable, SessionKvData>,
      ),
      SessionKvData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$RecurringsTableTableManager get recurrings =>
      $$RecurringsTableTableManager(_db, _db.recurrings);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$SessionKvTableTableManager get sessionKv =>
      $$SessionKvTableTableManager(_db, _db.sessionKv);
}

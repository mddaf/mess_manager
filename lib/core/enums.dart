enum MemberRole {
  admin,
  manager,
  member;

  String get nameString {
    switch (this) {
      case MemberRole.admin:
        return 'admin';
      case MemberRole.manager:
        return 'manager';
      case MemberRole.member:
        return 'member';
    }
  }

  static MemberRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return MemberRole.admin;
      case 'manager':
        return MemberRole.manager;
      case 'member':
      default:
        return MemberRole.member;
    }
  }
}

enum MealValue {
  none(0.0),
  half(0.5),
  full(1.0);

  final double value;
  const MealValue(this.value);

  static MealValue fromDouble(double val) {
    if (val >= 1.0) return MealValue.full;
    if (val >= 0.5) return MealValue.half;
    return MealValue.none;
  }

  MealValue toggleNext() {
    switch (this) {
      case MealValue.none:
        return MealValue.full;
      case MealValue.full:
        return MealValue.half;
      case MealValue.half:
        return MealValue.none;
    }
  }
}

enum SettlementStatus {
  pending,
  settled;

  static SettlementStatus fromString(String value) {
    return value.toLowerCase() == 'settled'
        ? SettlementStatus.settled
        : SettlementStatus.pending;
  }
}

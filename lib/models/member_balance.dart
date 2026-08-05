import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_balance.freezed.dart';
part 'member_balance.g.dart';

@freezed
abstract class MemberBalance with _$MemberBalance {
  const factory MemberBalance({
    required String memberId,
    required String memberName,
    required double totalMeals,
    required double totalCost,
    required double totalDeposit,
    required double balance, // totalDeposit - totalCost (+ owes mess to member, - member owes mess)
  }) = _MemberBalance;

  factory MemberBalance.fromJson(Map<String, dynamic> json) =>
      _$MemberBalanceFromJson(json);
}

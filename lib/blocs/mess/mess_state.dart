import 'package:equatable/equatable.dart';
import '../../models/mess.dart';
import '../../models/member.dart';

abstract class MessState extends Equatable {
  const MessState();

  @override
  List<Object?> get props => [];
}

class MessInitial extends MessState {}

class MessLoading extends MessState {}

class MessLoaded extends MessState {
  final Mess mess;
  final List<Member> members;

  const MessLoaded({required this.mess, this.members = const []});

  @override
  List<Object?> get props => [mess, members];
}

class MessError extends MessState {
  final String message;

  const MessError(this.message);

  @override
  List<Object?> get props => [message];
}

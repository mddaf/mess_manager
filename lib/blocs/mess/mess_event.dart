import 'package:equatable/equatable.dart';

abstract class MessEvent extends Equatable {
  const MessEvent();

  @override
  List<Object?> get props => [];
}

class CreateMessRequested extends MessEvent {
  final String name;
  final String address;
  final String userId;
  final String userName;
  final String userEmail;

  const CreateMessRequested({
    required this.name,
    required this.address,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  List<Object?> get props => [name, address, userId, userName, userEmail];
}

class JoinMessRequested extends MessEvent {
  final String inviteCode;
  final String userId;
  final String userName;
  final String userEmail;

  const JoinMessRequested({
    required this.inviteCode,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  List<Object?> get props => [inviteCode, userId, userName, userEmail];
}

class WatchMessRequested extends MessEvent {
  final String messId;

  const WatchMessRequested(this.messId);

  @override
  List<Object?> get props => [messId];
}

class ResetMessRequested extends MessEvent {
  const ResetMessRequested();
}

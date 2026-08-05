import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/mess_repository.dart';
import '../../models/mess.dart';
import '../../models/member.dart';
import 'mess_event.dart';
import 'mess_state.dart';

class MessBloc extends Bloc<MessEvent, MessState> {
  final MessRepository _messRepository;
  StreamSubscription? _messSub;
  StreamSubscription? _membersSub;

  // In-memory cache to combine mess + members before emitting
  Mess? _currentMess;
  List<Member> _currentMembers = [];

  MessBloc({required MessRepository messRepository})
      : _messRepository = messRepository,
        super(MessInitial()) {
    on<CreateMessRequested>(_onCreateMess);
    on<JoinMessRequested>(_onJoinMess);
    on<WatchMessRequested>(_onWatchMess);
    on<_MessUpdated>(_onMessUpdated);
    on<_MembersUpdated>(_onMembersUpdated);
  }

  Future<void> _onCreateMess(
    CreateMessRequested event,
    Emitter<MessState> emit,
  ) async {
    emit(MessLoading());
    try {
      final mess = await _messRepository.createMess(
        name: event.name,
        address: event.address,
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
      );
      add(WatchMessRequested(mess.id));
    } catch (e) {
      emit(MessError(e.toString()));
    }
  }

  Future<void> _onJoinMess(
    JoinMessRequested event,
    Emitter<MessState> emit,
  ) async {
    emit(MessLoading());
    try {
      final mess = await _messRepository.joinMessWithInviteCode(
        inviteCode: event.inviteCode,
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
      );
      if (mess != null) {
        add(WatchMessRequested(mess.id));
      } else {
        emit(const MessError('Invalid or expired invite code'));
      }
    } catch (e) {
      emit(MessError(e.toString()));
    }
  }

  Future<void> _onWatchMess(
    WatchMessRequested event,
    Emitter<MessState> emit,
  ) async {
    // Cancel any existing subscriptions
    await _messSub?.cancel();
    await _membersSub?.cancel();
    _currentMess = null;
    _currentMembers = [];

    emit(MessLoading());

    // Subscribe to mess document stream
    _messSub = _messRepository.watchMess(event.messId).listen(
      (mess) {
        if (mess != null) {
          add(_MessUpdated(mess));
        }
      },
      onError: (e) => add(_MembersUpdated(const [])),
    );

    // Subscribe to members sub-collection stream
    _membersSub = _messRepository.watchMembers(event.messId).listen(
      (members) {
        add(_MembersUpdated(members));
      },
      onError: (_) => add(_MembersUpdated(const [])),
    );
  }

  void _onMessUpdated(_MessUpdated event, Emitter<MessState> emit) {
    _currentMess = event.mess;
    if (_currentMess != null) {
      emit(MessLoaded(mess: _currentMess!, members: _currentMembers));
    }
  }

  void _onMembersUpdated(_MembersUpdated event, Emitter<MessState> emit) {
    _currentMembers = event.members;
    if (_currentMess != null) {
      emit(MessLoaded(mess: _currentMess!, members: _currentMembers));
    }
  }

  @override
  Future<void> close() async {
    await _messSub?.cancel();
    await _membersSub?.cancel();
    return super.close();
  }
}

// Internal events to bridge stream callbacks → bloc events
class _MessUpdated extends MessEvent {
  final Mess mess;
  const _MessUpdated(this.mess);
  @override
  List<Object?> get props => [mess];
}

class _MembersUpdated extends MessEvent {
  final List<Member> members;
  const _MembersUpdated(this.members);
  @override
  List<Object?> get props => [members];
}

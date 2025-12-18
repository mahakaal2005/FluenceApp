import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/users_repository.dart';

// Events
abstract class NotificationRecipientsEvent extends Equatable {
  const NotificationRecipientsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationRecipients extends NotificationRecipientsEvent {
  final bool forceRefresh;

  const LoadNotificationRecipients({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class ClearRecipientsCache extends NotificationRecipientsEvent {
  const ClearRecipientsCache();
}

// States
abstract class NotificationRecipientsState extends Equatable {
  const NotificationRecipientsState();

  @override
  List<Object?> get props => [];
}

class RecipientsInitial extends NotificationRecipientsState {
  const RecipientsInitial();
}

class RecipientsLoading extends NotificationRecipientsState {
  const RecipientsLoading();
}

class RecipientsLoaded extends NotificationRecipientsState {
  final List<Map<String, dynamic>> users;
  final DateTime loadedAt;

  const RecipientsLoaded({
    required this.users,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [users, loadedAt];

  bool get isCacheExpired {
    final now = DateTime.now();
    final difference = now.difference(loadedAt);
    return difference.inMinutes > 5; // Cache expires after 5 minutes
  }
}

class RecipientsError extends NotificationRecipientsState {
  final String message;

  const RecipientsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationRecipientsBloc extends Bloc<NotificationRecipientsEvent, NotificationRecipientsState> {
  final UsersRepository _usersRepository;

  NotificationRecipientsBloc({UsersRepository? usersRepository})
      : _usersRepository = usersRepository ?? UsersRepository(),
        super(const RecipientsInitial()) {
    on<LoadNotificationRecipients>(_onLoadRecipients);
    on<ClearRecipientsCache>(_onClearCache);
  }

  Future<void> _onLoadRecipients(LoadNotificationRecipients event, Emitter<NotificationRecipientsState> emit) async {
    // If we have cached data and it's not expired, return it
    if (state is RecipientsLoaded && !event.forceRefresh) {
      final loadedState = state as RecipientsLoaded;
      if (!loadedState.isCacheExpired) {
        return;
      }
    }

    emit(const RecipientsLoading());

    try {
      final users = await _usersRepository.getAllUsers(
        limit: 1000,
        role: 'user',
        status: 'active',
      );

      emit(RecipientsLoaded(
        users: users,
        loadedAt: DateTime.now(),
      ));
    } catch (e) {
      print('[ERROR] [RECIPIENTS BLOC] Error loading users: $e');
      emit(RecipientsError(e.toString()));
    }
  }

  void _onClearCache(ClearRecipientsCache event, Emitter<NotificationRecipientsState> emit) {
    emit(const RecipientsInitial());
  }

  @override
  Future<void> close() {
    _usersRepository.dispose();
    return super.close();
  }
}

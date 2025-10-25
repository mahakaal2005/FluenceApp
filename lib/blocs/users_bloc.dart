import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../repositories/users_repository.dart';

// Events
abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UsersEvent {
  final String? statusFilter;
  
  const LoadUsers({this.statusFilter});
  
  @override
  List<Object?> get props => [statusFilter];
}

class ApproveUser extends UsersEvent {
  final String applicationId;
  
  const ApproveUser(this.applicationId);
  
  @override
  List<Object?> get props => [applicationId];
}

class RejectUser extends UsersEvent {
  final String applicationId;
  final String reason;
  
  const RejectUser(this.applicationId, this.reason);
  
  @override
  List<Object?> get props => [applicationId, reason];
}

class SuspendUser extends UsersEvent {
  final String merchantId;
  
  const SuspendUser(this.merchantId);
  
  @override
  List<Object?> get props => [merchantId];
}

// States
abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<AdminUser> users;
  final String? currentFilter;
  
  const UsersLoaded(this.users, {this.currentFilter});
  
  @override
  List<Object?> get props => [users, currentFilter];
  
  // Helper getters for filtering
  List<AdminUser> get allUsers => users;
  List<AdminUser> get pendingUsers => users.where((u) => u.status == 'pending').toList();
  List<AdminUser> get approvedUsers => users.where((u) => u.status == 'approved').toList();
  List<AdminUser> get suspendedUsers => users.where((u) => u.status == 'suspended').toList();
  
  int get pendingCount => pendingUsers.length;
}

class UsersError extends UsersState {
  final String message;
  
  const UsersError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UserActionLoading extends UsersState {
  final List<AdminUser> users;
  final String actionType;
  
  const UserActionLoading(this.users, this.actionType);
  
  @override
  List<Object?> get props => [users, actionType];
}

class UserActionSuccess extends UsersState {
  final List<AdminUser> users;
  final String message;
  
  const UserActionSuccess(this.users, this.message);
  
  @override
  List<Object?> get props => [users, message];
}

// BLoC
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository _repository;

  UsersBloc({UsersRepository? repository})
      : _repository = repository ?? UsersRepository(),
        super(UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<ApproveUser>(_onApproveUser);
    on<RejectUser>(_onRejectUser);
    on<SuspendUser>(_onSuspendUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final users = await _repository.getMerchantApplications(
        status: event.statusFilter,
        limit: 100, // Get all for admin panel
      );
      emit(UsersLoaded(users, currentFilter: event.statusFilter));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onApproveUser(ApproveUser event, Emitter<UsersState> emit) async {
    if (state is UsersLoaded) {
      final currentState = state as UsersLoaded;
      emit(UserActionLoading(currentState.users, 'approve'));
      
      try {
        await _repository.approveMerchantApplication(event.applicationId);
        
        // Update the user status locally
        final updatedUsers = currentState.users.map((user) {
          if (user.id == event.applicationId) {
            return AdminUser(
              id: user.id,
              name: user.name,
              email: user.email,
              phone: user.phone,
              status: 'approved',
              joinDate: user.joinDate,
              company: user.company,
              businessType: user.businessType,
            );
          }
          return user;
        }).toList();
        
        emit(UserActionSuccess(updatedUsers, 'User approved successfully'));
        emit(UsersLoaded(updatedUsers, currentFilter: currentState.currentFilter));
      } catch (e) {
        emit(UsersError('Failed to approve user: $e'));
        emit(UsersLoaded(currentState.users, currentFilter: currentState.currentFilter));
      }
    }
  }

  Future<void> _onRejectUser(RejectUser event, Emitter<UsersState> emit) async {
    if (state is UsersLoaded) {
      final currentState = state as UsersLoaded;
      emit(UserActionLoading(currentState.users, 'reject'));
      
      try {
        await _repository.rejectMerchantApplication(event.applicationId, event.reason);
        
        // Remove the rejected user from the list
        final updatedUsers = currentState.users
            .where((user) => user.id != event.applicationId)
            .toList();
        
        emit(UserActionSuccess(updatedUsers, 'User rejected successfully'));
        emit(UsersLoaded(updatedUsers, currentFilter: currentState.currentFilter));
      } catch (e) {
        emit(UsersError('Failed to reject user: $e'));
        emit(UsersLoaded(currentState.users, currentFilter: currentState.currentFilter));
      }
    }
  }

  Future<void> _onSuspendUser(SuspendUser event, Emitter<UsersState> emit) async {
    if (state is UsersLoaded) {
      final currentState = state as UsersLoaded;
      emit(UserActionLoading(currentState.users, 'suspend'));
      
      try {
        await _repository.suspendMerchant(event.merchantId);
        
        // Update the user status locally
        final updatedUsers = currentState.users.map((user) {
          if (user.id == event.merchantId) {
            return AdminUser(
              id: user.id,
              name: user.name,
              email: user.email,
              phone: user.phone,
              status: 'suspended',
              joinDate: user.joinDate,
              company: user.company,
              businessType: user.businessType,
            );
          }
          return user;
        }).toList();
        
        emit(UserActionSuccess(updatedUsers, 'User suspended successfully'));
        emit(UsersLoaded(updatedUsers, currentFilter: currentState.currentFilter));
      } catch (e) {
        emit(UsersError('Failed to suspend user: $e'));
        emit(UsersLoaded(currentState.users, currentFilter: currentState.currentFilter));
      }
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
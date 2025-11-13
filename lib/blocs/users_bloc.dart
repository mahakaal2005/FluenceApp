import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/users_repository.dart';
import '../models/user.dart';

// Events
abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UsersEvent {
  const LoadUsers();
}

class ApproveUser extends UsersEvent {
  final String userId;

  const ApproveUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RejectUser extends UsersEvent {
  final String userId;
  final String reason;

  const RejectUser(this.userId, this.reason);

  @override
  List<Object?> get props => [userId, reason];
}

class SuspendUser extends UsersEvent {
  final String userId;

  const SuspendUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

// States
abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {
  const UsersInitial();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  final List<AdminUser> allUsers;
  final List<AdminUser> pendingUsers;
  final List<AdminUser> approvedUsers;
  final List<AdminUser> suspendedUsers;

  const UsersLoaded({
    required this.allUsers,
    required this.pendingUsers,
    required this.approvedUsers,
    required this.suspendedUsers,
  });

  @override
  List<Object?> get props => [allUsers, pendingUsers, approvedUsers, suspendedUsers];

  int get pendingCount => pendingUsers.length;
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserActionSuccess extends UsersState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository _usersRepository;

  UsersBloc({UsersRepository? usersRepository})
      : _usersRepository = usersRepository ?? UsersRepository(),
        super(const UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<ApproveUser>(_onApproveUser);
    on<RejectUser>(_onRejectUser);
    on<SuspendUser>(_onSuspendUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(const UsersLoading());

    try {
      // Fetch both regular users and merchants simultaneously
      final results = await Future.wait([
        _usersRepository.getRegularUsers(limit: 100),
        _usersRepository.getMerchantApplications(limit: 100),
      ]);

      final regularUsers = results[0];
      final merchants = results[1];

      // Combine both lists
      final allUsers = [...regularUsers, ...merchants];

      // Filter by status
      final pending = allUsers.where((u) => u.status == 'pending').toList();
      final approved = allUsers.where((u) => u.status == 'approved' || u.status == 'active').toList();
      final suspended = allUsers.where((u) => u.status == 'suspended' || u.status == 'rejected').toList();

      print('📊 [USERS] Loaded summary:');
      print('   Regular users: ${regularUsers.length}');
      print('   Merchants: ${merchants.length}');
      print('   Total: ${allUsers.length}');
      print('   Pending: ${pending.length}');
      print('   Approved/Active: ${approved.length}');
      print('   Suspended/Rejected: ${suspended.length}');

      emit(UsersLoaded(
        allUsers: allUsers,
        pendingUsers: pending,
        approvedUsers: approved,
        suspendedUsers: suspended,
      ));
    } catch (e) {
      print('❌ [USERS] Error loading users: $e');
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onApproveUser(ApproveUser event, Emitter<UsersState> emit) async {
    try {
      // Find the user to determine if it's a regular user or merchant
      final currentState = state;
      if (currentState is UsersLoaded) {
        final user = currentState.allUsers.firstWhere(
          (u) => u.id == event.userId,
          orElse: () => throw Exception('User not found'),
        );
        
        if (user.userType == 'user') {
          // Approve regular user via auth service
          await _usersRepository.approveUser(event.userId);
        } else {
          // Approve merchant application via merchant service
          await _usersRepository.approveMerchantApplication(event.userId);
        }
      }
      
      emit(const UserActionSuccess('User approved successfully'));
      add(const LoadUsers()); // Reload users
    } catch (e) {
      print('❌ [USERS] Error approving user: $e');
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onRejectUser(RejectUser event, Emitter<UsersState> emit) async {
    try {
      // Find the user to determine if it's a regular user or merchant
      final currentState = state;
      if (currentState is UsersLoaded) {
        final user = currentState.allUsers.firstWhere(
          (u) => u.id == event.userId,
          orElse: () => throw Exception('User not found'),
        );
        
        if (user.userType == 'user') {
          // Reject regular user via auth service
          await _usersRepository.rejectUser(event.userId, event.reason);
        } else {
          // Reject merchant application via merchant service
          await _usersRepository.rejectMerchantApplication(event.userId, event.reason);
        }
      }
      
      emit(const UserActionSuccess('User rejected successfully'));
      add(const LoadUsers()); // Reload users
    } catch (e) {
      print('❌ [USERS] Error rejecting user: $e');
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onSuspendUser(SuspendUser event, Emitter<UsersState> emit) async {
    try {
      // Find the user to determine if it's a regular user or merchant
      final currentState = state;
      if (currentState is UsersLoaded) {
        final user = currentState.allUsers.firstWhere(
          (u) => u.id == event.userId,
          orElse: () => throw Exception('User not found'),
        );
        
        String successMessage;
        if (user.userType == 'user') {
          // Suspend regular user via auth service
          await _usersRepository.suspendUser(event.userId);
          successMessage = 'User suspended successfully';
        } else {
          // Suspend merchant via merchant service
          await _usersRepository.suspendMerchant(event.userId);
          successMessage = 'Merchant suspended successfully';
        }
        
        emit(UserActionSuccess(successMessage));
        add(const LoadUsers()); // Reload users
      }
    } catch (e) {
      print('❌ [USERS] Error suspending user: $e');
      emit(UsersError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _usersRepository.dispose();
    return super.close();
  }
}

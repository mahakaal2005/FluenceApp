import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/transaction.dart';
import '../models/dispute.dart';
import '../models/analytics.dart';
import '../repositories/transactions_repository.dart';

// Events
abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final String? statusFilter;
  final String? typeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const LoadTransactions({
    this.statusFilter,
    this.typeFilter,
    this.startDate,
    this.endDate,
  });
  
  @override
  List<Object?> get props => [statusFilter, typeFilter, startDate, endDate];
}

class LoadTransactionAnalytics extends TransactionsEvent {}

class LoadDisputes extends TransactionsEvent {}

class ResolveDispute extends TransactionsEvent {
  final String disputeId;
  final String resolution;
  final String? notes;
  
  const ResolveDispute(this.disputeId, this.resolution, {this.notes});
  
  @override
  List<Object?> get props => [disputeId, resolution, notes];
}

class SearchTransactions extends TransactionsEvent {
  final String query;
  
  const SearchTransactions(this.query);
  
  @override
  List<Object?> get props => [query];
}

// States
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final String? currentFilter;
  final String? searchQuery;
  final Map<String, dynamic>? analytics;
  
  const TransactionsLoaded(
    this.transactions, {
    this.currentFilter,
    this.searchQuery,
    this.analytics,
  });
  
  @override
  List<Object?> get props => [transactions, currentFilter, searchQuery, analytics];
  
  // Helper getters for filtering
  List<Transaction> get filteredTransactions {
    var filtered = transactions;
    
    // Backend already filters by status, so we don't need to filter again
    // Only apply search filter here
    
    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((t) {
        return t.businessName.toLowerCase().contains(query) ||
               t.id.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }
}

class TransactionsError extends TransactionsState {
  final String message;
  
  const TransactionsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class TransactionAnalyticsLoaded extends TransactionsState {
  final Analytics analytics;
  
  const TransactionAnalyticsLoaded(this.analytics);
  
  @override
  List<Object?> get props => [analytics];
}

class DisputesLoaded extends TransactionsState {
  final List<Dispute> disputes;
  
  const DisputesLoaded(this.disputes);
  
  @override
  List<Object?> get props => [disputes];
}

class DisputeActionLoading extends TransactionsState {
  final List<Dispute> disputes;
  
  const DisputeActionLoading(this.disputes);
  
  @override
  List<Object?> get props => [disputes];
}

class DisputeActionSuccess extends TransactionsState {
  final List<Dispute> disputes;
  final String message;
  
  const DisputeActionSuccess(this.disputes, this.message);
  
  @override
  List<Object?> get props => [disputes, message];
}

// BLoC
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionsRepository _repository;

  TransactionsBloc({TransactionsRepository? repository})
      : _repository = repository ?? TransactionsRepository(),
        super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionAnalytics>(_onLoadTransactionAnalytics);
    on<LoadDisputes>(_onLoadDisputes);
    on<ResolveDispute>(_onResolveDispute);
    on<SearchTransactions>(_onSearchTransactions);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final result = await _repository.getTransactionsWithAnalytics(
        status: event.statusFilter,
        type: event.typeFilter,
        startDate: event.startDate,
        endDate: event.endDate,
        limit: 100, // Get more for admin panel
      );
      
      final transactions = result['transactions'] as List<Transaction>;
      final analytics = result['analytics'] as Map<String, dynamic>?;
      
      emit(TransactionsLoaded(
        transactions,
        currentFilter: event.statusFilter,
        analytics: analytics,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionAnalytics(LoadTransactionAnalytics event, Emitter<TransactionsState> emit) async {
    try {
      final analytics = await _repository.getTransactionAnalytics();
      emit(TransactionAnalyticsLoaded(analytics));
    } catch (e) {
      emit(TransactionsError('Failed to load analytics: $e'));
    }
  }

  Future<void> _onLoadDisputes(LoadDisputes event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final disputes = await _repository.getDisputes(limit: 100);
      emit(DisputesLoaded(disputes));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onResolveDispute(ResolveDispute event, Emitter<TransactionsState> emit) async {
    if (state is DisputesLoaded) {
      final currentState = state as DisputesLoaded;
      emit(DisputeActionLoading(currentState.disputes));
      
      try {
        await _repository.resolveDispute(event.disputeId, event.resolution, notes: event.notes);
        
        // Update the dispute status locally
        final updatedDisputes = currentState.disputes.map((dispute) {
          if (dispute.id == event.disputeId) {
            return Dispute(
              id: dispute.id,
              merchantId: dispute.merchantId,
              transactionId: dispute.transactionId,
              disputeType: dispute.disputeType,
              title: dispute.title,
              description: dispute.description,
              status: 'resolved',
              priority: dispute.priority,
              assignedTo: dispute.assignedTo,
              resolutionNotes: event.resolution,
              resolvedAt: DateTime.now(),
              createdAt: dispute.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return dispute;
        }).toList();
        
        emit(DisputeActionSuccess(updatedDisputes, 'Dispute resolved successfully'));
        emit(DisputesLoaded(updatedDisputes));
      } catch (e) {
        emit(TransactionsError('Failed to resolve dispute: $e'));
        emit(DisputesLoaded(currentState.disputes));
      }
    }
  }

  Future<void> _onSearchTransactions(SearchTransactions event, Emitter<TransactionsState> emit) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      emit(TransactionsLoaded(
        currentState.transactions,
        currentFilter: currentState.currentFilter,
        searchQuery: event.query,
      ));
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
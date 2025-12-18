import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/faq.dart';
import '../models/terms.dart';
import '../models/notification.dart';
import '../repositories/content_repository.dart';
import '../repositories/notifications_repository.dart';

// Events
abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object?> get props => [];
}

class LoadFAQs extends ContentEvent {
  const LoadFAQs();
}

class LoadTerms extends ContentEvent {
  const LoadTerms();
}

class LoadNotifications extends ContentEvent {
  final int page;
  final int limit;
  
  const LoadNotifications({this.page = 1, this.limit = 10});
  
  @override
  List<Object?> get props => [page, limit];
}

class LoadAnalytics extends ContentEvent {
  const LoadAnalytics();
}

class LoadUserCount extends ContentEvent {
  const LoadUserCount();
}

class RefreshAll extends ContentEvent {
  const RefreshAll();
}

class SendNotification extends ContentEvent {
  final String title;
  final String message;
  
  const SendNotification({required this.title, required this.message});
  
  @override
  List<Object?> get props => [title, message];
}

// States
abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentLoaded extends ContentState {
  final List<FAQ> faqs;
  final Terms? terms;
  final List<NotificationModel> notifications;
  final Map<String, dynamic> analytics;
  final int userCount;
  final bool isLoadingFAQs;
  final bool isLoadingTerms;
  final bool isLoadingNotifications;
  final bool isLoadingAnalytics;
  
  const ContentLoaded({
    this.faqs = const [],
    this.terms,
    this.notifications = const [],
    this.analytics = const {},
    this.userCount = 0,
    this.isLoadingFAQs = false,
    this.isLoadingTerms = false,
    this.isLoadingNotifications = false,
    this.isLoadingAnalytics = false,
  });
  
  @override
  List<Object?> get props => [
    faqs,
    terms,
    notifications,
    analytics,
    userCount,
    isLoadingFAQs,
    isLoadingTerms,
    isLoadingNotifications,
    isLoadingAnalytics,
  ];
  
  ContentLoaded copyWith({
    List<FAQ>? faqs,
    Terms? terms,
    List<NotificationModel>? notifications,
    Map<String, dynamic>? analytics,
    int? userCount,
    bool? isLoadingFAQs,
    bool? isLoadingTerms,
    bool? isLoadingNotifications,
    bool? isLoadingAnalytics,
  }) {
    return ContentLoaded(
      faqs: faqs ?? this.faqs,
      terms: terms ?? this.terms,
      notifications: notifications ?? this.notifications,
      analytics: analytics ?? this.analytics,
      userCount: userCount ?? this.userCount,
      isLoadingFAQs: isLoadingFAQs ?? this.isLoadingFAQs,
      isLoadingTerms: isLoadingTerms ?? this.isLoadingTerms,
      isLoadingNotifications: isLoadingNotifications ?? this.isLoadingNotifications,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
    );
  }
}

class ContentError extends ContentState {
  final String message;
  
  const ContentError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class NotificationSending extends ContentState {}

class NotificationSent extends ContentState {
  final String message;
  
  const NotificationSent(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository _contentRepository;
  final NotificationsRepository _notificationsRepository;
  final VoidCallback? onNotificationsViewed;

  ContentBloc({
    ContentRepository? contentRepository,
    NotificationsRepository? notificationsRepository,
    this.onNotificationsViewed,
  })  : _contentRepository = contentRepository ?? ContentRepository(),
        _notificationsRepository = notificationsRepository ?? NotificationsRepository(),
        super(ContentInitial()) {
    on<LoadFAQs>(_onLoadFAQs);
    on<LoadTerms>(_onLoadTerms);
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadAnalytics>(_onLoadAnalytics);
    on<LoadUserCount>(_onLoadUserCount);
    on<RefreshAll>(_onRefreshAll);
    on<SendNotification>(_onSendNotification);
  }

  Future<void> _onLoadFAQs(LoadFAQs event, Emitter<ContentState> emit) async {
    final currentState = state is ContentLoaded ? state as ContentLoaded : const ContentLoaded();
    
    emit(currentState.copyWith(isLoadingFAQs: true));
    
    try {
      final faqs = await _contentRepository.getFAQs();
      emit(currentState.copyWith(faqs: faqs, isLoadingFAQs: false));
    } catch (e) {
      emit(ContentError('Failed to load FAQs: $e'));
      emit(currentState.copyWith(isLoadingFAQs: false));
    }
  }

  Future<void> _onLoadTerms(LoadTerms event, Emitter<ContentState> emit) async {
    final currentState = state is ContentLoaded ? state as ContentLoaded : const ContentLoaded();
    
    emit(currentState.copyWith(isLoadingTerms: true));
    
    try {
      final terms = await _contentRepository.getTerms();
      emit(currentState.copyWith(terms: terms, isLoadingTerms: false));
    } catch (e) {
      print('Failed to load terms: $e');
      emit(currentState.copyWith(isLoadingTerms: false));
    }
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<ContentState> emit) async {
    final currentState = state is ContentLoaded ? state as ContentLoaded : const ContentLoaded();
    
    emit(currentState.copyWith(isLoadingNotifications: true));
    
    try {
      print('📬 Loading notifications...');
      
      // Fetch all 3 types of notifications for admin panel:
      // 1. Notifications admin sent to users (with read stats)
      // 2. Notifications admin received (new posts, new merchant applications)
      
      final sentNotificationsFuture = _notificationsRepository.getSentNotificationsWithStats(
        page: event.page,
        limit: event.limit,
      );
      
      final receivedNotificationsFuture = _notificationsRepository.getNotifications(
        page: event.page,
        limit: event.limit,
      );
      
      final results = await Future.wait([sentNotificationsFuture, receivedNotificationsFuture]);
      final sentNotifications = results[0] as List<Map<String, dynamic>>;
      final receivedNotifications = results[1] as List<NotificationModel>;
      
      print('📤 Sent notifications count: ${sentNotifications.length}');
      print('📥 Received notifications count: ${receivedNotifications.length}');
      
      if (sentNotifications.isNotEmpty) {
        print('📤 First sent notification: ${sentNotifications[0]}');
      }
      
      if (receivedNotifications.isNotEmpty) {
        print('📥 First received notification: ${receivedNotifications[0].title}');
      }
      
      // Mark all admin notifications as opened/viewed when admin views the list
      // Only marks notifications RECEIVED by admin (not sent by admin)
      // This updates the badge count to show only truly unseen admin notifications
      try {
        await _notificationsRepository.markAllAsOpened();
        
        // Update local state immediately - mark all received notifications as read
        final now = DateTime.now();
        for (var notif in receivedNotifications) {
          if (notif.status != 'sent') {
            final updatedNotif = NotificationModel(
              id: notif.id,
              type: notif.type,
              title: notif.title,
              message: notif.message,
              status: notif.status,
              readAt: now,
              createdAt: notif.createdAt,
              sentAt: notif.sentAt,
              metadata: notif.metadata,
              readCountFromBackend: notif.readCountFromBackend,
            );
            final index = receivedNotifications.indexWhere((n) => n.id == notif.id);
            if (index != -1) {
              receivedNotifications[index] = updatedNotif;
            }
          }
        }
        
        await Future.delayed(const Duration(milliseconds: 300));
        onNotificationsViewed?.call();
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('429') || errorStr.contains('too many requests')) {
          // Still update local state even if API call fails
          final now = DateTime.now();
          for (var notif in receivedNotifications) {
            if (notif.status != 'sent') {
              final updatedNotif = NotificationModel(
                id: notif.id,
                type: notif.type,
                title: notif.title,
                message: notif.message,
                status: notif.status,
                readAt: now,
                createdAt: notif.createdAt,
                sentAt: notif.sentAt,
                metadata: notif.metadata,
                readCountFromBackend: notif.readCountFromBackend,
              );
              final index = receivedNotifications.indexWhere((n) => n.id == notif.id);
              if (index != -1) {
                receivedNotifications[index] = updatedNotif;
              }
            }
          }
          await Future.delayed(const Duration(milliseconds: 300));
          onNotificationsViewed?.call();
        } else {
          print('[WARNING] [ContentBloc] Failed to mark admin notifications as opened: $e');
        }
      }
      
      // Convert sent notifications to NotificationModel
      final sentNotificationModels = sentNotifications.map((notifMap) {
        return NotificationModel(
          id: notifMap['id'] as String,
          type: notifMap['type'] as String? ?? 'in_app',
          title: notifMap['subject'] as String,
          message: notifMap['message'] as String,
          status: 'sent',
          readAt: null,
          createdAt: DateTime.parse(notifMap['created_at'] as String),
          sentAt: notifMap['sent_at'] != null ? DateTime.parse(notifMap['sent_at'] as String) : null,
          metadata: null,
          readCountFromBackend: notifMap['total_read'] as int?,
        );
      }).toList();
      
      // Merge both lists and sort by created date (newest first)
      final allNotifications = <NotificationModel>[...sentNotificationModels, ...receivedNotifications];
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Take only the requested limit
      final limitedNotifications = allNotifications.take(event.limit).toList();
      
      emit(currentState.copyWith(notifications: limitedNotifications, isLoadingNotifications: false));
    } catch (e) {
      print('[ERROR] [ContentBloc] Failed to load notifications: $e');
      emit(currentState.copyWith(isLoadingNotifications: false));
    }
  }

  Future<void> _onLoadAnalytics(LoadAnalytics event, Emitter<ContentState> emit) async {
    final currentState = state is ContentLoaded ? state as ContentLoaded : const ContentLoaded();
    
    emit(currentState.copyWith(isLoadingAnalytics: true));
    
    try {
      final analytics = await _notificationsRepository.getAnalytics();
      emit(currentState.copyWith(analytics: analytics, isLoadingAnalytics: false));
    } catch (e) {
      print('[ERROR] [ContentBloc] Failed to load analytics: $e');
      emit(currentState.copyWith(isLoadingAnalytics: false));
    }
  }

  Future<void> _onLoadUserCount(LoadUserCount event, Emitter<ContentState> emit) async {
    final currentState = state is ContentLoaded ? state as ContentLoaded : const ContentLoaded();
    
    try {
      final userCount = await _notificationsRepository.getUserCount();
      emit(currentState.copyWith(userCount: userCount));
    } catch (e) {
      print('Failed to load user count: $e');
    }
  }

  Future<void> _onRefreshAll(RefreshAll event, Emitter<ContentState> emit) async {
    add(const LoadFAQs());
    add(const LoadTerms());
    add(const LoadNotifications());
    add(const LoadAnalytics());
    add(const LoadUserCount());
  }

  Future<void> _onSendNotification(SendNotification event, Emitter<ContentState> emit) async {
    emit(NotificationSending());
    
    try {
      await _notificationsRepository.sendNotification(
        title: event.title,
        message: event.message,
        type: 'in_app',
      );
      
      emit(const NotificationSent('Notification sent successfully'));
      
      // Reload notifications and analytics after sending
      add(const LoadNotifications());
      add(const LoadAnalytics());
    } catch (e) {
      emit(ContentError('Failed to send notification: $e'));
    }
  }

  @override
  Future<void> close() {
    _contentRepository.dispose();
    _notificationsRepository.dispose();
    return super.close();
  }
}

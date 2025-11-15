import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/post.dart';
import '../repositories/posts_repository.dart';

// Events
abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosts extends PostsEvent {}

class ApprovePost extends PostsEvent {
  final String transactionId;
  final String? notes;
  
  const ApprovePost(this.transactionId, {this.notes});
  
  @override
  List<Object?> get props => [transactionId, notes];
}

class RejectPost extends PostsEvent {
  final String transactionId;
  final String reason;
  
  const RejectPost(this.transactionId, this.reason);
  
  @override
  List<Object?> get props => [transactionId, reason];
}

class LoadSocialAnalytics extends PostsEvent {}

// States
abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object?> get props => [];
}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Post> posts;
  
  const PostsLoaded(this.posts);
  
  @override
  List<Object?> get props => [posts];
  
  // Helper getters for filtering
  List<Post> get allPosts => posts;
  List<Post> get pendingPosts => posts.where((p) => p.status == PostStatus.pending).toList();
  List<Post> get approvedPosts => posts.where((p) => p.status == PostStatus.approved).toList();
  List<Post> get rejectedPosts => posts.where((p) => p.status == PostStatus.rejected).toList();
  
  int get pendingCount => pendingPosts.length;
}

class PostsError extends PostsState {
  final String message;
  
  const PostsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class PostActionLoading extends PostsState {
  final List<Post> posts;
  final String actionType;
  
  const PostActionLoading(this.posts, this.actionType);
  
  @override
  List<Object?> get props => [posts, actionType];
}

class PostActionSuccess extends PostsState {
  final List<Post> posts;
  final String message;
  
  const PostActionSuccess(this.posts, this.message);
  
  @override
  List<Object?> get props => [posts, message];
}

class SocialAnalyticsLoaded extends PostsState {
  final Map<String, dynamic> analytics;
  
  const SocialAnalyticsLoaded(this.analytics);
  
  @override
  List<Object?> get props => [analytics];
}

// BLoC
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsRepository _repository;

  PostsBloc({PostsRepository? repository})
      : _repository = repository ?? PostsRepository(),
        super(PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<ApprovePost>(_onApprovePost);
    on<RejectPost>(_onRejectPost);
    on<LoadSocialAnalytics>(_onLoadSocialAnalytics);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    try {
      // Fetch ALL posts (pending, approved, rejected) from all users
      final postsWithMetadata = await _repository.getAllSocialPostsWithMetadata(
        limit: 100, // Fetch more posts to show complete picture
        offset: 0,
      );
      
      // Check for duplicates: same user_id AND same platform_post_id
      // Mark posts as duplicates if the same user posted the same platform post ID
      final Map<String, List<Map<String, dynamic>>> duplicateMap = {};
      
      for (var postData in postsWithMetadata) {
        final userId = postData['user_id']?.toString();
        final platformPostId = postData['platform_post_id']?.toString();
        
        // Only check duplicates if both user_id and platform_post_id exist
        if (userId != null && platformPostId != null && platformPostId.isNotEmpty) {
          final key = '$userId|$platformPostId';
          if (!duplicateMap.containsKey(key)) {
            duplicateMap[key] = [];
          }
          duplicateMap[key]!.add(postData);
        }
      }
      
      // Mark posts as duplicates if there are multiple posts with same user_id + platform_post_id
      for (var entry in duplicateMap.entries) {
        if (entry.value.length > 1) {
          // Multiple posts found with same user_id + platform_post_id
          for (var postData in entry.value) {
            postData['has_duplicates'] = true;
            postData['duplicate_count'] = entry.value.length;
          }
        }
      }
      
      // Convert to UI models with raw data for duplicate detection
      final posts = postsWithMetadata.map((postData) {
        final socialPost = SocialPost.fromJson(postData);
        return Post.fromSocialPost(socialPost, rawData: postData);
      }).toList();
      
      print('📊 [POSTS_BLOC] Loaded ${posts.length} total posts');
      print('   Pending: ${posts.where((p) => p.status == PostStatus.pending).length}');
      print('   Approved: ${posts.where((p) => p.status == PostStatus.approved).length}');
      print('   Rejected: ${posts.where((p) => p.status == PostStatus.rejected).length}');
      
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> _onApprovePost(ApprovePost event, Emitter<PostsState> emit) async {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;
      emit(PostActionLoading(currentState.posts, 'approve'));
      
      try {
        await _repository.verifySocialPost(event.transactionId, notes: event.notes);
        
        // Remove the approved post from pending list
        final updatedPosts = currentState.posts
            .where((post) => post.id != event.transactionId)
            .toList();
        
        emit(PostActionSuccess(updatedPosts, 'Post approved successfully'));
        emit(PostsLoaded(updatedPosts));
      } catch (e) {
        emit(PostsError('Failed to approve post: $e'));
        emit(PostsLoaded(currentState.posts));
      }
    }
  }

  Future<void> _onRejectPost(RejectPost event, Emitter<PostsState> emit) async {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;
      emit(PostActionLoading(currentState.posts, 'reject'));
      
      try {
        await _repository.rejectSocialPost(event.transactionId, event.reason);
        
        // Remove the rejected post from pending list
        final updatedPosts = currentState.posts
            .where((post) => post.id != event.transactionId)
            .toList();
        
        emit(PostActionSuccess(updatedPosts, 'Post rejected successfully'));
        emit(PostsLoaded(updatedPosts));
      } catch (e) {
        emit(PostsError('Failed to reject post: $e'));
        emit(PostsLoaded(currentState.posts));
      }
    }
  }

  Future<void> _onLoadSocialAnalytics(LoadSocialAnalytics event, Emitter<PostsState> emit) async {
    try {
      final analytics = await _repository.getSocialAnalytics();
      emit(SocialAnalyticsLoaded(analytics));
    } catch (e) {
      emit(PostsError('Failed to load analytics: $e'));
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
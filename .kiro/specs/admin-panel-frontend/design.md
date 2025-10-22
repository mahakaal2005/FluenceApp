# Design Document

## Overview

The Fluence Pay Admin Panel is a Flutter application that provides administrative interface for managing the Fluence Pay platform. The application consists of a login screen and a main screen with 5 bottom navigation tabs (Dashboard, Users, Posts, Content, Payments). The design follows a rapid development approach with pixel-perfect Figma implementation and direct backend integration. The application uses BLoC architecture for state management and connects to 7 microservices for data operations.

### Design Principles

1. **Speed First**: Prioritize rapid delivery over perfection
2. **Figma Fidelity**: Exact pixel-perfect implementation of Figma designs
3. **Minimal Logic**: Simple connection between UI and backend APIs
4. **BLoC Pattern**: Clean separation of UI, business logic, and data layers
5. **Reusability**: Shared widgets and components across screens

### Technology Stack

- **Framework**: Flutter (latest stable)
- **State Management**: flutter_bloc ^8.1.6
- **HTTP Client**: http ^1.2.2
- **Secure Storage**: flutter_secure_storage ^9.0.0
- **JSON Serialization**: json_serializable ^6.8.0
- **Value Equality**: equatable ^2.0.5
- **Code Generation**: build_runner ^2.4.13

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Login + Reset Password Screen           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Main Screen with Bottom Navigation           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │Dashboard │  │  Users   │  │  Posts   │          │   │
│  │  │   Tab    │  │   Tab    │  │   Tab    │          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  │  ┌──────────┐  ┌──────────┐                        │   │
│  │  │ Content  │  │ Payments │                        │   │
│  │  │   Tab    │  │   Tab    │                        │   │
│  │  └──────────┘  └──────────┘                        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      BLoC Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │Dashboard │  │  Users   │  │  Posts   │   │
│  │   BLoC   │  │   BLoC   │  │   BLoC   │  │   BLoC   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐                                │
│  │ Content  │  │ Payments │                                │
│  │   BLoC   │  │   BLoC   │                                │
│  └──────────┘  └──────────┘                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Repository Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │  Users   │  │  Posts   │  │ Content  │   │
│  │Repository│  │Repository│  │Repository│  │Repository│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐                                               │
│  │ Payments │                                               │
│  │Repository│                                               │
│  └──────────┘                                               │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     API Service                              │
│                  (HTTP Client Wrapper)                       │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Backend Microservices                       │
│  Auth:4001  Cashback:4002  Merchant:4003  Notification:4004 │
│  Points:4005  Referral:4006  Social:4007                    │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── main.dart                      # App entry point
├── app.dart                       # App configuration and routing
├── blocs/                         # BLoC layer
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── dashboard/
│   │   ├── dashboard_bloc.dart
│   │   ├── dashboard_event.dart
│   │   └── dashboard_state.dart
│   ├── users/
│   │   ├── users_bloc.dart
│   │   ├── users_event.dart
│   │   └── users_state.dart
│   ├── posts/
│   │   ├── posts_bloc.dart
│   │   ├── posts_event.dart
│   │   └── posts_state.dart
│   ├── content/
│   │   ├── content_bloc.dart
│   │   ├── content_event.dart
│   │   └── content_state.dart
│   └── payments/
│       ├── payments_bloc.dart
│       ├── payments_event.dart
│       └── payments_state.dart
├── models/                        # Data models
│   ├── user.dart
│   ├── auth_response.dart
│   ├── post.dart
│   ├── faq.dart
│   ├── notification.dart
│   ├── analytics.dart
│   ├── dispute.dart
│   ├── transaction.dart
│   └── api_response.dart
├── repositories/                  # Data layer
│   ├── auth_repository.dart
│   ├── users_repository.dart
│   ├── posts_repository.dart
│   ├── content_repository.dart
│   └── payments_repository.dart
├── services/                      # API services
│   ├── api_service.dart          # HTTP client wrapper
│   └── storage_service.dart      # Secure storage wrapper
├── screens/                       # UI screens
│   ├── login_screen.dart
│   ├── reset_password_screen.dart
│   ├── main_screen.dart          # Contains bottom navigation
│   ├── dashboard_tab.dart
│   ├── users_tab.dart
│   ├── posts_tab.dart
│   ├── content_tab.dart
│   └── payments_tab.dart
├── widgets/                       # Reusable widgets
│   ├── common/
│   │   ├── loading_indicator.dart
│   │   ├── error_message.dart
│   │   └── success_message.dart
│   ├── navigation/
│   │   └── bottom_nav_bar.dart
│   └── cards/
│       ├── user_card.dart
│       ├── post_card.dart
│       ├── faq_card.dart
│       ├── dispute_card.dart
│       └── transaction_card.dart
└── utils/                         # Utilities
    ├── constants.dart            # API URLs, colors, etc.
    └── validators.dart           # Input validators
```

## Components and Interfaces

### 1. API Service

**Purpose**: Centralized HTTP client for all API requests

**Interface**:
```dart
class ApiService {
  final String baseUrl;
  final StorageService storageService;
  
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data);
  Future<void> delete(String endpoint);
  
  // Automatically adds JWT token to headers
  Future<Map<String, String>> _getHeaders();
}
```

**Configuration**:
- Base URLs for each microservice (localhost:4001-4007)
- Automatic JWT token injection from secure storage
- Error handling and response parsing
- Timeout configuration (30 seconds)

### 2. Storage Service

**Purpose**: Secure storage for JWT tokens

**Interface**:
```dart
class StorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();
}
```

**Implementation**: Uses flutter_secure_storage

### 3. Repositories

Each repository handles API calls for a specific domain:

**AuthRepository**:
```dart
class AuthRepository {
  final ApiService apiService;
  
  Future<AuthResponse> login(String idToken);
  Future<void> logout();
}
```

**UsersRepository**:
```dart
class UsersRepository {
  final ApiService apiService;
  
  Future<List<User>> getUsers({int page = 1, int limit = 10});
  Future<void> acceptUser(String userId);
  Future<void> rejectUser(String userId);
}
```

**PostsRepository**:
```dart
class PostsRepository {
  final ApiService apiService;
  
  Future<List<Post>> getPendingPosts();
  Future<void> approvePost(String transactionId, String notes);
  Future<void> rejectPost(String transactionId, String notes);
}
```

**ContentRepository**:
```dart
class ContentRepository {
  final ApiService apiService;
  
  Future<List<FAQ>> getFAQs();
  Future<FAQ> createFAQ(FAQ faq);
  Future<FAQ> updateFAQ(String id, FAQ faq);
  Future<void> deleteFAQ(String id);
  Future<List<Notification>> getNotifications({int page = 1, int limit = 10});
  Future<Map<String, dynamic>> getAnalytics();
}
```

**PaymentsRepository**:
```dart
class PaymentsRepository {
  final ApiService apiService;
  
  Future<List<Dispute>> getDisputes({int page = 1, int limit = 10});
  Future<void> resolveDispute(String disputeId, String resolution, String notes);
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 10,
    String? status,
    String? type,
  });
}
```

### 4. BLoC Pattern

Each screen has a dedicated BLoC following this pattern:

**Events**: User actions
```dart
abstract class AuthEvent extends Equatable {}

class LoginRequested extends AuthEvent {
  final String idToken;
}

class LogoutRequested extends AuthEvent {}
```

**States**: UI states
```dart
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
}
class AuthError extends AuthState {
  final String message;
}
```

**BLoC**: Business logic
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final StorageService storageService;
  
  AuthBloc({required this.authRepository, required this.storageService})
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(event.idToken);
      await storageService.saveToken(response.token);
      emit(AuthAuthenticated(user: response.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

## Data Models

### User Model
```dart
@JsonSerializable()
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  @override
  List<Object?> get props => [id, name, email, phone, role];
}
```

### AuthResponse Model
```dart
@JsonSerializable()
class AuthResponse extends Equatable {
  final User user;
  final String token;
  final bool needsProfileCompletion;
  
  const AuthResponse({
    required this.user,
    required this.token,
    required this.needsProfileCompletion,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
  
  @override
  List<Object?> get props => [user, token, needsProfileCompletion];
}
```

### SocialPost Model
```dart
@JsonSerializable()
class SocialPost extends Equatable {
  final String transactionId;
  final String userId;
  final String platform;
  final String postUrl;
  final String status;
  
  const SocialPost({
    required this.transactionId,
    required this.userId,
    required this.platform,
    required this.postUrl,
    required this.status,
  });
  
  factory SocialPost.fromJson(Map<String, dynamic> json) => _$SocialPostFromJson(json);
  Map<String, dynamic> toJson() => _$SocialPostToJson(this);
  
  @override
  List<Object?> get props => [transactionId, userId, platform, postUrl, status];
}
```

### MerchantApplication Model
```dart
@JsonSerializable()
class MerchantApplication extends Equatable {
  final String id;
  final String businessName;
  final String businessType;
  final String status;
  final String contactEmail;
  final String contactPhone;
  final DateTime submittedAt;
  final String? applicantName;
  final String? applicantEmail;
  
  const MerchantApplication({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.status,
    required this.contactEmail,
    required this.contactPhone,
    required this.submittedAt,
    this.applicantName,
    this.applicantEmail,
  });
  
  factory MerchantApplication.fromJson(Map<String, dynamic> json) => 
      _$MerchantApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$MerchantApplicationToJson(this);
  
  @override
  List<Object?> get props => [
    id, businessName, businessType, status, contactEmail, 
    contactPhone, submittedAt, applicantName, applicantEmail
  ];
}
```

### Budget Model
```dart
@JsonSerializable()
class Budget extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final String? description;
  final String status;
  final DateTime createdAt;
  
  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    this.description,
    required this.status,
    required this.createdAt,
  });
  
  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
  
  @override
  List<Object?> get props => [id, name, amount, currency, description, status, createdAt];
}
```

### Campaign Model
```dart
@JsonSerializable()
class Campaign extends Equatable {
  final String id;
  final String name;
  final String budgetId;
  final double cashbackPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? description;
  
  const Campaign({
    required this.id,
    required this.name,
    required this.budgetId,
    required this.cashbackPercentage,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.description,
  });
  
  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);
  Map<String, dynamic> toJson() => _$CampaignToJson(this);
  
  @override
  List<Object?> get props => [
    id, name, budgetId, cashbackPercentage, startDate, endDate, status, description
  ];
}
```

### Transaction Model
```dart
@JsonSerializable()
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final DateTime createdAt;
  
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
  });
  
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
  
  @override
  List<Object?> get props => [id, amount, type, status, description, createdAt];
}
```

## Screen Designs

### 1. Login + Reset Password Screen

**Figma Design**: https://www.figma.com/design/mV6gtXFSNauc8cjatw7QT5/fluence-app?node-id=613-664

**Implementation Approach**:
1. Extract design specifications from Figma (colors, fonts, spacing, layout)
2. Implement login UI matching Figma pixel-perfectly
3. Connect email and password inputs to AuthBloc
4. Handle login button tap → dispatch LoginRequested event
5. Implement "Forgot password?" link → navigate to reset password screen
6. Implement reset password screen (Figma design to be provided)
7. Show loading indicator during authentication
8. Navigate to main screen with bottom navigation on success
9. Show error message on failure

**Key Components**:
- Card with gradient background
- Email input field with icon
- Password input field with icon and visibility toggle
- "Forgot password?" link
- Sign In button with gradient
- Security features list at bottom

**BLoC Integration**:
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is AuthLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return LoginForm(); // Figma design implementation
  },
)
```

### 2. Main Screen with Bottom Navigation

**Structure**:
- Scaffold with body showing current tab
- Bottom navigation bar with 5 items
- Each tab maintains its own state

**Bottom Navigation Items**:
1. Dashboard (icon + label)
2. Users (icon + label)
3. Posts (icon + label)
4. Content (icon + label)
5. Payments (icon + label)

**Implementation**:
```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    DashboardTab(),
    UsersTab(),
    PostsTab(),
    ContentTab(),
    PaymentsTab(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.content_paste), label: 'Content'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
        ],
      ),
    );
  }
}
```

### 3. Dashboard Tab

**Figma Design**: To be provided

**Implementation Approach**:
1. Wait for Figma design link
2. Extract design specifications
3. Implement UI matching Figma
4. Fetch key metrics from multiple endpoints
5. Display data in UI components from Figma design
6. Implement pull-to-refresh

**Data Sources**:
- User statistics
- Pending posts count
- Pending disputes count
- Transaction analytics

### 4. Users Tab

**Figma Design**: To be provided

**Implementation Approach**:
1. Wait for Figma design link
2. Extract design specifications
3. Implement UI matching Figma
4. Fetch users list from backend
5. Display users in list/grid as per Figma design
6. Implement accept/reject actions
7. Refresh list after action

**Key Actions**:
- Accept user
- Reject user
- View user details

### 5. Posts Tab

**Figma Design**: To be provided

**Implementation Approach**:
1. Wait for Figma design link
2. Extract design specifications
3. Implement UI matching Figma
4. Fetch pending posts from http://localhost:4001/api/admin/pending-social-posts
5. Display posts in list/grid as per Figma design
6. Implement approve/reject actions
7. Refresh list after action

**Key Actions**:
- View post URL (open in browser)
- Approve post (PUT with verified=true)
- Reject post (PUT with verified=false)

### 6. Content Tab

**Figma Design**: To be provided

**Implementation Approach**:
1. Wait for Figma design link
2. Extract design specifications
3. Implement UI matching Figma with 3 sections: FAQ, Notifications, Analytics
4. Fetch FAQ data, notifications, and analytics
5. Display data in UI components from Figma design
6. Implement CRUD operations for FAQ
7. Display notifications list
8. Display analytics with charts

**Key Sections**:
- FAQ Management (create, edit, delete)
- Notifications (view, mark as read)
- Analytics (charts and metrics)

### 7. Payments Tab

**Figma Design**: To be provided

**Implementation Approach**:
1. Wait for Figma design link
2. Extract design specifications
3. Implement UI matching Figma
4. Fetch disputes from http://localhost:4002/api/disputes
5. Display disputes in list/grid as per Figma design
6. Implement resolve dispute action
7. Display payment transactions
8. Refresh list after action

**Key Actions**:
- View dispute details
- Resolve dispute with notes
- View payment transactions

## Navigation and Routing

### Route Configuration

```dart
final routes = {
  '/': (context) => LoginScreen(),
  '/reset-password': (context) => ResetPasswordScreen(),
  '/main': (context) => MainScreen(), // Contains bottom navigation with 5 tabs
};
```

### Bottom Navigation Bar

**Structure**:
- 5 navigation items with icons and labels
- Highlights currently active tab
- Maintains state of each tab when switching

**Implementation**:
```dart
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.post_add),
          label: 'Posts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.content_paste),
          label: 'Content',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payments',
        ),
      ],
    );
  }
}
```

### Logout Functionality

**Implementation**: Add logout button in AppBar or as a menu option in one of the tabs

```dart
IconButton(
  icon: Icon(Icons.logout),
  onPressed: () {
    context.read<AuthBloc>().add(LogoutRequested());
    Navigator.pushReplacementNamed(context, '/');
  },
)

## Error Handling

### Error Types and Handling

1. **Network Errors**:
   - Display: "Connection failed. Please check your internet."
   - Action: Retry button

2. **401 Unauthorized**:
   - Action: Clear token, redirect to login
   - Display: "Session expired. Please login again."

3. **403 Forbidden**:
   - Display: "You don't have permission to perform this action."

4. **404 Not Found**:
   - Display: "Resource not found."

5. **500 Server Error**:
   - Display: "Server error. Please try again later."

6. **Validation Errors**:
   - Display: Field-specific error messages

### Error State in BLoC

```dart
class ErrorState extends State {
  final String message;
  final String? code;
  final bool isRetryable;
  
  const ErrorState({
    required this.message,
    this.code,
    this.isRetryable = true,
  });
}
```

### Error Widget

```dart
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(message),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

## Testing Strategy

### Unit Tests

**Priority**: Medium (implement if time permits)

**Coverage**:
- Models: JSON serialization/deserialization
- Repositories: API call logic
- BLoCs: Event handling and state transitions

**Example**:
```dart
test('AuthBloc emits AuthAuthenticated when login succeeds', () async {
  when(authRepository.login(any)).thenAnswer((_) async => mockAuthResponse);
  
  final bloc = AuthBloc(authRepository: authRepository);
  
  bloc.add(LoginRequested(idToken: 'test_token'));
  
  await expectLater(
    bloc.stream,
    emitsInOrder([
      AuthLoading(),
      AuthAuthenticated(user: mockUser),
    ]),
  );
});
```

### Widget Tests

**Priority**: Low (skip for rapid delivery)

### Integration Tests

**Priority**: Low (skip for rapid delivery)

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load data only when screen is opened
2. **Pagination**: Fetch data in pages (10-20 items per page)
3. **Caching**: Cache data locally to reduce API calls
4. **Image Optimization**: Use cached_network_image for remote images
5. **List Performance**: Use ListView.builder for long lists

### Memory Management

- Dispose BLoCs when not needed
- Cancel ongoing API requests when screen is disposed
- Clear cached data periodically

## Security Considerations

### JWT Token Management

- Store token in flutter_secure_storage (encrypted)
- Never log token values
- Clear token on logout
- Validate token expiration

### API Security

- Use HTTPS in production
- Validate SSL certificates
- Implement request timeout (30 seconds)
- Sanitize user inputs

### Data Validation

- Validate all user inputs before sending to API
- Use form validators for email, phone, etc.
- Prevent SQL injection through parameterized queries (backend responsibility)

## Deployment Considerations

### Environment Configuration

```dart
class Environment {
  static const String authServiceUrl = 'http://localhost:4001';
  static const String cashbackServiceUrl = 'http://localhost:4002';
  static const String merchantServiceUrl = 'http://localhost:4003';
  static const String notificationServiceUrl = 'http://localhost:4004';
  static const String pointsServiceUrl = 'http://localhost:4005';
  static const String referralServiceUrl = 'http://localhost:4006';
  static const String socialServiceUrl = 'http://localhost:4007';
}
```

### Build Configuration

- Development: Use localhost URLs
- Production: Use production URLs (to be configured)

## Implementation Timeline

### Phase 1: Foundation (2-3 hours)
- Configure ApiService with all microservice URLs
- Implement StorageService
- Create base models (User, AuthResponse, Post, FAQ, Notification, Analytics, Dispute, Transaction)
- Implement AuthBloc and AuthRepository
- Build Login Screen from Figma design
- Build Reset Password Screen (when Figma provided)

### Phase 2: Main Screen & Bottom Navigation (1-2 hours)
- Implement MainScreen with bottom navigation
- Create navigation structure for 5 tabs
- Implement tab switching logic
- Add logout functionality

### Phase 3: Tab Implementations (5-6 hours)
- Implement Dashboard Tab (when Figma provided)
- Implement Users Tab (when Figma provided)
- Implement Posts Tab (when Figma provided)
- Implement Content Tab with FAQ, Notifications, Analytics (when Figma provided)
- Implement Payments Tab (when Figma provided)
- Create corresponding BLoCs and Repositories

### Phase 4: Polish (1-2 hours)
- Error handling refinement
- Loading states
- Success messages
- Pull-to-refresh functionality
- Final testing

**Total Estimated Time**: 9-13 hours (achievable in one day with focused work)

## Dependencies

### Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5
  http: ^1.2.2
  flutter_secure_storage: ^9.0.0
  json_annotation: ^4.9.0
  url_launcher: ^6.2.5  # For opening post URLs

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
  bloc_test: ^9.1.7  # For BLoC testing
  mockito: ^5.4.4    # For mocking
```

## Conclusion

This design provides a clear roadmap for rapid implementation of the Fluence Pay Admin Panel. The architecture is simple, maintainable, and focused on speed of delivery. By following the Figma designs pixel-perfectly and connecting directly to backend APIs, we can deliver a functional admin panel within the tight timeline while maintaining code quality and following Flutter best practices.


## Profile Screen

### Overview
The Profile Screen provides administrators with access to their account information, security settings, and logout functionality. It follows the app's design language with gold gradient accents and white card-based layout.

### Features

1. **Profile Header**
   - Large circular avatar with gradient background
   - Admin name display
   - Email address display
   - Role badge ("Administrator") with gold gradient

2. **Account Information Card**
   - Editable full name field
   - Email field (display only)
   - Editable phone number field
   - Input fields with icons and light gray background

3. **Security Card**
   - Change password action tile (navigates to change password flow)
   - Last login information display
   - Action tiles with gold gradient icons

4. **About Card**
   - Member since date
   - App version information
   - Info tiles with gray icons

5. **Logout Button**
   - Full-width red button at bottom
   - Logout icon with text
   - Confirmation dialog before logout
   - Navigates to login screen on confirm

### Navigation
- Accessible by tapping profile icon in top bar
- Back button returns to main screen
- Logout navigates to login screen (clears navigation stack)

### Design Specifications

**Colors:**
- Background: #F9FAFB
- Card background: #FFFFFF
- Primary text: #0A0A0A
- Secondary text: #717182
- Input background: #F3F3F5
- Gradient: Gold gradient (AppColors.buttonGradient)
- Logout button: #E7000B (red)

**Typography:**
- Profile name: 20px, bold
- Section titles: 16px, bold
- Field labels: 12px, semi-bold
- Field values: 14px, regular
- Button text: 16px, semi-bold
- Font family: Arial (system default)

**Layout:**
- Card border radius: 20px
- Input border radius: 14px
- Button border radius: 14px
- Card padding: 20px
- Screen padding: 16px
- Card spacing: 16px
- Avatar size: 80x80px
- Action tile icon size: 40x40px

**Shadows:**
- Card shadow: 0px 2px 6px rgba(0, 0, 0, 0.1)
- Avatar shadow: 0px 4px 10px rgba(0, 0, 0, 0.1)

### Implementation Details

**File:** `lib/screens/profile_screen.dart`

**State Management:**
- StatefulWidget with TextEditingControllers for editable fields
- Local state for form management
- No BLoC integration required for MVP (future enhancement)

**Key Methods:**
- `_logout()`: Shows confirmation dialog and navigates to login
- `_changePassword()`: Placeholder for future implementation
- `_buildProfileHeader()`: Renders avatar and basic info
- `_buildAccountInfoCard()`: Renders editable account fields
- `_buildSecurityCard()`: Renders security options
- `_buildAboutCard()`: Renders app information
- `_buildLogoutButton()`: Renders logout button

**Future Enhancements:**
- Connect to backend API for profile updates
- Implement change password functionality
- Add profile photo upload
- Add two-factor authentication toggle
- Add notification preferences
- Add theme toggle (light/dark mode)

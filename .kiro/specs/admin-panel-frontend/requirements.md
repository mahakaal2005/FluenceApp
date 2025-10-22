# Requirements Document

## Introduction

The Fluence Pay Admin Panel is a Flutter-based administrative interface for managing the Fluence Pay platform. The system consists of exactly 7 screens that integrate with 7 microservices backend. The implementation must be completed rapidly (by next day) using BLoC architecture pattern.

**CRITICAL CONSTRAINTS**:
- **Timeline**: Implementation must be completed by next day - speed is essential
- **Screen Count**: Exactly 7 screens, no more, no less
- **Design**: All screens SHALL be exact pixel-perfect copies of Figma designs provided by the user
- **Architecture**: BLoC pattern for state management
- **Backend Integration**: Direct integration with microservices using routes and endpoints from README.md
- **Approach**: Copy-paste Figma designs, then integrate backend endpoints - minimal custom logic

## Glossary

- **Admin Panel**: The Flutter application providing administrative interface
- **Auth Service**: Microservice on port 4001 for authentication
- **Cashback Budget Service**: Microservice on port 4002 for budgets/campaigns/transactions
- **Merchant Onboarding Service**: Microservice on port 4003 for merchant management
- **Notification Service**: Microservice on port 4004 for notifications
- **Points Wallet Service**: Microservice on port 4005 for points/wallet
- **Referral Service**: Microservice on port 4006 for referrals
- **Social Features Service**: Microservice on port 4007 for social features
- **JWT Token**: JSON Web Token for authentication
- **BLoC**: Business Logic Component pattern for state management
- **Figma Design**: Source of truth for all UI implementations

## Requirements

### Requirement 1: Screen Structure

**User Story:** As a product owner, I want the admin panel with login screen and 5 bottom navigation tabs, so that administrators can access all features efficiently.

#### Acceptance Criteria

1. THE Admin Panel SHALL implement Admin Login + Reset Password screen (Figma node-id=613-664)
2. THE Admin Panel SHALL implement a bottom navigation bar with exactly 5 tabs
3. THE Admin Panel SHALL implement Tab 1: Dashboard (Figma design to be provided)
4. THE Admin Panel SHALL implement Tab 2: Users Management with Accept/Reject functionality (Figma design to be provided)
5. THE Admin Panel SHALL implement Tab 3: Posts Management with Approve/Reject functionality (Figma design to be provided)
6. THE Admin Panel SHALL implement Tab 4: Content Management with FAQ, Notifications, and Analytics (Figma design to be provided)
7. THE Admin Panel SHALL implement Tab 5: Payments Management with Resolve Dispute functionality (Figma design to be provided)
8. WHEN the administrator logs in successfully, THE Admin Panel SHALL navigate to the main screen with bottom navigation
9. THE Admin Panel SHALL highlight the currently active tab in the bottom navigation

### Requirement 2: Pixel-Perfect Figma Implementation

**User Story:** As a product owner, I want all screens to exactly match Figma designs, so that the UI is consistent with the design system.

#### Acceptance Criteria

1. WHEN implementing any screen, THE Admin Panel SHALL extract all design specifications from the Figma design link
2. THE Admin Panel SHALL match colors, typography, spacing, layout, borders, shadows, and gradients exactly as specified in Figma
3. THE Admin Panel SHALL extract and use images and icons from Figma designs
4. THE Admin Panel SHALL NOT create any screen without a Figma design link

### Requirement 3: Firebase Authentication

**User Story:** As an administrator, I want to log in using Firebase authentication, so that I can access the admin panel securely.

#### Acceptance Criteria

1. WHEN the administrator opens the Admin Panel, THE Admin Panel SHALL display the login screen matching Figma design (node-id=613-664)
2. WHEN the administrator submits credentials, THE Admin Panel SHALL POST to http://localhost:4001/api/auth/firebase with Firebase idToken
3. WHEN authentication succeeds, THE Admin Panel SHALL store the JWT token using flutter_secure_storage
4. WHEN authentication succeeds, THE Admin Panel SHALL navigate to the dashboard screen
5. WHEN authentication fails, THE Admin Panel SHALL display error message
6. WHILE authenticated, THE Admin Panel SHALL include "Authorization: Bearer <token>" header in all API requests
7. WHEN any API returns 401 status, THE Admin Panel SHALL redirect to login screen

### Requirement 4: Dashboard Screen

**User Story:** As an administrator, I want to view key metrics on the dashboard, so that I can monitor platform status.

#### Acceptance Criteria

1. WHEN the administrator logs in successfully, THE Admin Panel SHALL display dashboard screen matching Figma design (to be provided)
2. THE Admin Panel SHALL fetch and display data from backend endpoints specified in README.md
3. THE Admin Panel SHALL display loading state while fetching data
4. WHEN data fetch fails, THE Admin Panel SHALL display error message

### Requirement 5: Users Management Tab

**User Story:** As an administrator, I want to manage users and accept or reject them, so that I can control platform access.

#### Acceptance Criteria

1. WHEN the administrator navigates to Users tab, THE Admin Panel SHALL display the screen matching Figma design (to be provided)
2. THE Admin Panel SHALL fetch users list from the appropriate backend endpoint
3. THE Admin Panel SHALL display each user with relevant information (name, email, status, registration date)
4. WHEN the administrator clicks accept on a user, THE Admin Panel SHALL send request to accept the user
5. WHEN the administrator clicks reject on a user, THE Admin Panel SHALL send request to reject the user
6. WHEN any operation succeeds, THE Admin Panel SHALL refresh the users list

### Requirement 6: Posts Management Tab

**User Story:** As an administrator, I want to manage posts and approve or reject them, so that I can moderate platform content.

#### Acceptance Criteria

1. WHEN the administrator navigates to Posts tab, THE Admin Panel SHALL display the screen matching Figma design (to be provided)
2. THE Admin Panel SHALL GET pending posts from http://localhost:4001/api/admin/pending-social-posts
3. THE Admin Panel SHALL display each post with transaction ID, user ID, platform, post URL, and status
4. WHEN the administrator clicks approve, THE Admin Panel SHALL PUT to http://localhost:4001/api/admin/verify-social-post/:transactionId with verified=true
5. WHEN the administrator clicks reject, THE Admin Panel SHALL PUT to http://localhost:4001/api/admin/verify-social-post/:transactionId with verified=false
6. WHEN any operation succeeds, THE Admin Panel SHALL refresh the posts list

### Requirement 7: Content Management Tab

**User Story:** As an administrator, I want to manage FAQ, notifications, and view analytics, so that I can control platform content and monitor performance.

#### Acceptance Criteria

1. WHEN the administrator navigates to Content tab, THE Admin Panel SHALL display the screen matching Figma design (to be provided)
2. THE Admin Panel SHALL provide sections for FAQ management, Notifications management, and Analytics viewing
3. THE Admin Panel SHALL fetch FAQ data from the appropriate backend endpoint
4. THE Admin Panel SHALL fetch notifications from http://localhost:4004/api/notifications
5. THE Admin Panel SHALL fetch analytics data from http://localhost:4002/api/transactions/analytics
6. THE Admin Panel SHALL allow creating, editing, and deleting FAQ entries
7. THE Admin Panel SHALL display analytics with charts and key metrics

### Requirement 8: Payments Management Tab

**User Story:** As an administrator, I want to manage payments and resolve disputes, so that I can handle payment issues effectively.

#### Acceptance Criteria

1. WHEN the administrator navigates to Payments tab, THE Admin Panel SHALL display the screen matching Figma design (to be provided)
2. THE Admin Panel SHALL GET disputes from http://localhost:4002/api/disputes
3. THE Admin Panel SHALL display each dispute with transaction ID, type, status, reason, amount, and creation date
4. WHEN the administrator clicks resolve on a dispute, THE Admin Panel SHALL display a form for entering resolution notes
5. WHEN the administrator submits resolution, THE Admin Panel SHALL POST to http://localhost:4002/api/disputes/:id/resolve
6. THE Admin Panel SHALL display payment transactions from http://localhost:4002/api/transactions with type filter
7. WHEN any operation succeeds, THE Admin Panel SHALL refresh the data

### Requirement 9: Bottom Navigation Implementation

**User Story:** As an administrator, I want to easily switch between different sections using bottom navigation, so that I can access features quickly.

#### Acceptance Criteria

1. THE Admin Panel SHALL display a bottom navigation bar with 5 items (Dashboard, Users, Posts, Content, Payments)
2. THE Admin Panel SHALL highlight the currently active tab
3. WHEN the administrator taps on a navigation item, THE Admin Panel SHALL switch to the corresponding tab
4. THE Admin Panel SHALL maintain the state of each tab when switching between them
5. THE Admin Panel SHALL use icons and labels for each navigation item as specified in Figma design

### Requirement 10: BLoC Architecture Implementation

**User Story:** As a developer, I want to use BLoC pattern for state management, so that the code is maintainable and follows Flutter best practices.

#### Acceptance Criteria

1. THE Admin Panel SHALL implement a separate BLoC for each feature (AuthBloc, DashboardBloc, UsersBloc, PostsBloc, ContentBloc, PaymentsBloc)
2. THE Admin Panel SHALL define Events for each user action (LoginEvent, FetchDataEvent, ApproveEvent, RejectEvent, etc.)
3. THE Admin Panel SHALL define States for each screen state (InitialState, LoadingState, LoadedState, ErrorState)
4. THE Admin Panel SHALL use BlocBuilder or BlocConsumer in UI to react to state changes
5. THE Admin Panel SHALL use BlocProvider to provide BLoCs to screens

### Requirement 11: Repository Pattern for API Integration

**User Story:** As a developer, I want to use Repository pattern for API calls, so that the data layer is separated from business logic.

#### Acceptance Criteria

1. THE Admin Panel SHALL implement a separate Repository for each feature (AuthRepository, UsersRepository, PostsRepository, ContentRepository, PaymentsRepository)
2. THE Admin Panel SHALL use ApiService class for all HTTP requests
3. THE Admin Panel SHALL configure ApiService with base URLs for each microservice (ports 4001-4007)
4. THE Admin Panel SHALL handle API errors and return appropriate error messages
5. THE Admin Panel SHALL parse JSON responses into model objects

### Requirement 12: Data Models

**User Story:** As a developer, I want to define data models for API responses, so that data is type-safe and easy to work with.

#### Acceptance Criteria

1. THE Admin Panel SHALL define models for User, Post, FAQ, Notification, Analytics, Dispute, Transaction
2. THE Admin Panel SHALL use json_serializable for JSON serialization/deserialization
3. THE Admin Panel SHALL implement fromJson and toJson methods for each model
4. THE Admin Panel SHALL use Equatable for value equality in models

### Requirement 13: Navigation and Routing

**User Story:** As an administrator, I want to navigate between screens easily, so that I can access all features quickly.

#### Acceptance Criteria

1. THE Admin Panel SHALL implement navigation drawer or bottom navigation for accessing all 7 screens
2. THE Admin Panel SHALL use named routes for navigation
3. THE Admin Panel SHALL protect authenticated routes and redirect to login if not authenticated
4. THE Admin Panel SHALL highlight the current active screen in navigation

### Requirement 14: Error Handling and Loading States

**User Story:** As an administrator, I want to see loading indicators and error messages, so that I understand what the app is doing.

#### Acceptance Criteria

1. WHILE any API request is in progress, THE Admin Panel SHALL display a loading indicator
2. WHEN any API request fails, THE Admin Panel SHALL display an error message
3. WHEN any operation succeeds, THE Admin Panel SHALL display a success message
4. THE Admin Panel SHALL handle network errors, timeout errors, and server errors appropriately

### Requirement 15: Rapid Development Approach

**User Story:** As a developer, I want to implement the admin panel rapidly, so that it is delivered by next day.

#### Acceptance Criteria

1. THE Admin Panel SHALL prioritize speed over perfection
2. THE Admin Panel SHALL use minimal custom logic - focus on connecting Figma UI to backend APIs
3. THE Admin Panel SHALL reuse widgets and components where possible
4. THE Admin Panel SHALL use existing packages (flutter_bloc, http, flutter_secure_storage, json_serializable) without adding unnecessary dependencies
5. THE Admin Panel SHALL implement core functionality first, defer nice-to-have features

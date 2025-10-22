# Implementation Plan

## IMPORTANT WORKFLOW

**UI-First Approach**:
1. Build ALL screen UIs first (pixel-perfect from Figma)
2. Use hardcoded test login (admin credentials) for UI testing
3. Set up complete navigation structure early
4. Connect backend APIs only after all UIs are complete and tested

**Screen Implementation Process**:
- For EACH screen, user will provide:
  1. Figma design link
  2. Screenshot/image of the screen
- Only then proceed with that screen's implementation
- Do NOT implement any screen without both Figma link AND screenshot

## Phase 1: Foundation & Navigation Setup

- [x] 1. Project Setup and Dependencies

  - [x] 1.1 Add required dependencies to pubspec.yaml
    - Verify flutter_bloc, http, flutter_secure_storage, json_serializable, equatable, url_launcher are present
    - Add any missing dependencies
    - Run flutter pub get
    - _Requirements: 15.1_

  - [x] 1.2 Create directory structure
    - Create blocs/, models/, repositories/, services/, screens/, widgets/ directories
    - Create subdirectories as per design document
    - _Requirements: 15.1_

- [x] 2. Setup Navigation Structure with Test Login
  - [x] 2.1 Create app.dart with route configuration
    - Define routes: /, /reset-password, /main
    - Set initial route to /
    - _Requirements: 13.1, 13.2_
  - [x] 2.2 Create placeholder screens for all tabs
    - Create empty DashboardTab, UsersTab, PostsTab, ContentTab, PaymentsTab widgets
    - Each should display a simple Text widget with tab name
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 1.7_
  - [x] 2.3 Create MainScreen with BottomNavigationBar
    - Implement StatefulWidget with currentIndex state
    - Create list of 5 placeholder tab widgets
    - Implement BottomNavigationBar with 5 items (icons and labels)
    - Implement tab switching on navigation item tap
    - Add logout IconButton in AppBar (just navigate to / for now)
    - _Requirements: 1.2, 1.8, 9.1, 9.2, 9.3, 9.4, 9.5, 13.1, 13.2_
  - [x] 2.4 Create test login screen
    - Create simple login screen with hardcoded credentials
    - Username: "admin@test.com", Password: "admin123"
    - On successful login, navigate to /main
    - Show error message for wrong credentials
    - This is TEMPORARY for UI testing only
    - _Requirements: 1.1, 3.1, 15.1_

- [x] 3. Test Navigation Flow
  - [x] 3.1 Run app and test login with test credentials
    - Verify login screen appears
    - Test login with correct credentials (admin@test.com / admin123)
    - Verify navigation to main screen
    - _Requirements: 3.1, 3.4, 13.3_
  - [x] 3.2 Test bottom navigation
    - Verify all 5 tabs are accessible
    - Verify tab switching works
    - Verify placeholder content shows in each tab
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  - [x] 3.3 Test logout
    - Tap logout button in AppBar
    - Verify navigation back to login screen
    - _Requirements: 13.3_

## Phase 2: Build All Screen UIs (Pixel-Perfect from Figma)

### Screen 1: Login + Reset Password

- [x] 4. Implement Login Screen UI (FIGMA PROVIDED: node-id=613-664)


  - [x] 4.1 Extract design specifications from Figma
    - Extract colors (gradient: #D4A200 to #C48828 to #D4AF37, white #FFFFFF)
    - Extract typography (Arial font, 30px bold for title, 14px for subtitle, 16px for inputs)
    - Extract spacing (23.99px gap, various padding values)
    - Extract border radius (20px card, 14px inputs/button, 24px logo)
    - Extract shadow effects (boxShadow values from Figma)
    - _Requirements: 1.1, 2.1, 2.2_

  - [x] 4.2 Build Login UI pixel-perfectly
    - Create gradient background (180deg, #D4A200 0%, #C48828 50%, #D4AF37 100%)
    - Create white card (362.32 x 567.04) with 20px border radius and shadow
    - Add logo/icon (79.99 x 79.99) with gradient and 24px border radius at top
    - Add "Admin Panel" title (Arial, 30px, bold, #0A0A0A, center)
    - Add subtitle "Sign in to manage your platform" (Arial, 14px, #717182, center)
    - Create email input (314.34 x 48, #F3F3F5 background, 14px border radius, mail icon)
    - Create password input (314.34 x 48, #F3F3F5 background, 14px border radius, lock icon, eye icon)
    - Add "Forgot password?" link (Arial, 14px, #D4A200)
    - Add "Sign In" button (314.34 x 48, gradient background, 14px border radius, shadow)
    - Add security features list with green dots (#00C950) and text (Arial, 12px, #717182)

    - _Requirements: 1.1, 2.1, 2.2, 2.3, 3.1_
  - [x] 4.3 Connect to test login logic
    - Replace hardcoded test login with this UI
    - Keep test credentials (admin@test.com / admin123) for now
    - Navigate to /main on successful login
    - Show error SnackBar on failed login
    - _Requirements: 3.1, 3.4, 3.5_

- [x] 5. Implement Reset Password Screen UI (WAITING FOR FIGMA + SCREENSHOT)
  - [x] 5.1 STOP: Request Figma link and screenshot from user
    - Ask user: "Please provide Figma link and screenshot for Reset Password screen"
    - DO NOT proceed until both are provided
    - _Requirements: 1.1, 2.4_

  - [x] 5.2 Extract design specifications from Figma (after provided)
    - Extract colors, typography, spacing, layout, border radius
    - _Requirements: 2.1, 2.2_

  - [x] 5.3 Build Reset Password UI pixel-perfectly (after provided)
    - Implement UI matching Figma exactly
    - Use extracted specifications
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 5.4 Add navigation from Login screen
    - Connect "Forgot password?" link to navigate to /reset-password
    - Add back button to return to login
    - _Requirements: 3.1, 13.2_

### Screen 2: Dashboard Tab

- [x] 6. Implement Dashboard Tab UI (WAITING FOR FIGMA + SCREENSHOT)
  - [x] 6.1 STOP: Request Figma link and screenshot from user
    - Ask user: "Please provide Figma link and screenshot for Dashboard Tab"

    - DO NOT proceed until both are provided
    - _Requirements: 1.3, 2.4_
  - [x] 6.2 Extract design specifications from Figma (after provided)
    - Extract colors, typography, spacing, layout, card designs, chart styles
    - _Requirements: 2.1, 2.2_
  - [x] 6.3 Build Dashboard UI pixel-perfectly (after provided)
    - Implement UI matching Figma exactly
    - Use mock/hardcoded data for metrics (user count, pending posts, etc.)
    - Display charts with sample data
    - _Requirements: 1.3, 2.1, 2.2, 2.3, 4.1_

  - [ ] 6.4 Replace placeholder DashboardTab widget
    - Replace empty placeholder with actual Dashboard UI
    - Test navigation to Dashboard tab
    - _Requirements: 1.3, 9.3_

### Screen 3: Users Tab

- [ ] 7. Implement Users Tab UI (WAITING FOR FIGMA + SCREENSHOT)
  - [ ] 7.1 STOP: Request Figma link and screenshot from user
    - Ask user: "Please provide Figma link and screenshot for Users Tab"
    - DO NOT proceed until both are provided
    - _Requirements: 1.4, 2.4_
  - [ ] 7.2 Extract design specifications from Figma (after provided)
    - Extract colors, typography, spacing, layout, user card designs, button styles
    - _Requirements: 2.1, 2.2_
  - [ ] 7.3 Build Users UI pixel-perfectly (after provided)
    - Implement UI matching Figma exactly
    - Use mock/hardcoded user data (list of 5-10 sample users)
    - Add Accept/Reject buttons (non-functional for now)
    - _Requirements: 1.4, 2.1, 2.2, 2.3, 5.1, 5.3_
  - [ ] 7.4 Replace placeholder UsersTab widget
    - Replace empty placeholder with actual Users UI
    - Test navigation to Users tab
    - _Requirements: 1.4, 9.3_

### Screen 4: Posts Tab

- [x] 8. Implement Posts Tab UI (WAITING FOR FIGMA + SCREENSHOT)
  - [x] 8.1 STOP: Request Figma link and screenshot from user
    - Ask user: "Please provide Figma link and screenshot for Posts Tab"
    - DO NOT proceed until both are provided
    - _Requirements: 1.5, 2.4_
  - [x] 8.2 Extract design specifications from Figma (after provided)
    - Extract colors, typography, spacing, layout, post card designs, button styles
    - _Requirements: 2.1, 2.2_

  - [x] 8.3 Build Posts UI pixel-perfectly (after provided)
    - Implement UI matching Figma exactly
    - Use mock/hardcoded post data (list of 5-10 sample posts with URLs)
    - Add Approve/Reject buttons (non-functional for now)
    - _Requirements: 1.5, 2.1, 2.2, 2.3, 6.1, 6.3_

  - [x] 8.4 Replace placeholder PostsTab widget
    - Replace empty placeholder with actual Posts UI
    - Test navigation to Posts tab
    - _Requirements: 1.5, 9.3_

### Screen 5: Content Tab

- [x] 9. Implement Content Tab UI (WAITING FOR FIGMA + SCREENSHOT)
  - [x] 9.1 STOP: Request Figma link and screenshot from user
    - Ask user: "Please provide Figma link and screenshot for Content Tab"
    - DO NOT proceed until both are provided
    - _Requirements: 1.6, 2.4_
  - [x] 9.2 Extract design specifications from Figma (after provided)
    - Extract colors, typography, spacing, layout for FAQ, Notifications, Analytics sections
    - _Requirements: 2.1, 2.2_
  - [x] 9.3 Build Content UI pixel-perfectly (after provided)
    - Implement UI matching Figma exactly
    - Create 3 sections: FAQ, Notifications, Analytics
    - Use mock/hardcoded data for FAQs (5-10 sample FAQs)
    - Use mock/hardcoded data for Notifications (5-10 sample notifications)
    - Use mock/hardcoded data for Analytics (sample charts and metrics)
    - Add Create/Edit/Delete buttons for FAQ (non-functional for now)
    - _Requirements: 1.6, 2.1, 2.2, 2.3, 7.1, 7.2_
  - [x] 9.4 Replace placeholder ContentTab widget
    - Replace empty placeholder with actual Content UI
    - Test navigation to Content tab
    - _Requirements: 1.6, 9.3_

### Screen 6: Payments Tab

- [x] 10. Implement Payments Tab UI (WAITING FOR FIGMA + SCREENSHOT)


  - [x] 10.1 STOP: Request Figma link and screenshot from user
    - Ask user: "Please provide Figma link and screenshot for Payments Tab"
    - DO NOT proceed until both are provided
    - _Requirements: 1.7, 2.4_

  - [x] 10.2 Extract design specifications from Figma (after provided)
    - Extract colors, typography, spacing, layout, dispute card designs, button styles
    - _Requirements: 2.1, 2.2_

  - [x] 10.3 Build Payments UI pixel-perfectly (after provided)
    - Implement UI matching Figma exactly
    - Use mock/hardcoded dispute data (list of 5-10 sample disputes)
    - Use mock/hardcoded transaction data (list of 10-20 sample transactions)
    - Add Resolve button for disputes (non-functional for now)
    - _Requirements: 1.7, 2.1, 2.2, 2.3, 8.1, 8.3_


  - [x] 10.4 Replace placeholder PaymentsTab widget
    - Replace empty placeholder with actual Payments UI
    - Test navigation to Payments tab
    - _Requirements: 1.7, 9.3_

### Screen 7: Profile Screen

- [x] 11. Implement Profile Screen UI
  - [x] 11.1 Design and plan Profile Screen
    - Plan sections: Profile Header, Account Info, Security, About, Logout
    - Match existing app theme (gold gradient, white cards, Arial font)
    - _Requirements: 1.8, 2.1, 2.2_
  
  - [x] 11.2 Build Profile Screen UI
    - Create profile header with avatar, name, email, role badge
    - Create account information card with editable fields (name, email, phone)
    - Create security card with change password and last login info
    - Create about card with member since and app version
    - Add prominent logout button with confirmation dialog
    - _Requirements: 1.8, 2.1, 2.2, 2.3, 13.3_
  
  - [x] 11.3 Connect profile navigation
    - Add navigation from profile icon in top bar to Profile Screen
    - Add back button to return to main screen
    - Implement logout functionality (navigate to login screen)
    - _Requirements: 1.8, 9.3, 13.3_

- [x] 11. Final UI Testing
  - [x] 11.1 Test all screens are accessible
    - Login with test credentials
    - Navigate to each of the 5 tabs
    - Verify all UIs display correctly
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 9.1, 9.2, 9.3_
  - [x] 11.2 Verify Figma design fidelity for all screens
    - Compare each screen with Figma design side-by-side
    - Verify colors, typography, spacing, layout match exactly
    - Make adjustments if needed
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 11.3 Test navigation flow
    - Test login → main screen
    - Test tab switching (all 5 tabs)
    - Test logout → login screen
    - Test forgot password → reset password → back to login
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 13.1, 13.2, 13.3_

## Phase 3: Backend Integration (After All UIs Complete)

### Setup Backend Connection

- [x] 12. Configure API Service
  - [x] 12.1 Update ApiService with microservice URLs
    - Set Auth Service URL: http://localhost:4001
    - Set Cashback Budget Service URL: http://localhost:4002
    - Set Merchant Onboarding Service URL: http://localhost:4003
    - Set Notification Service URL: http://localhost:4004
    - Set Points Wallet Service URL: http://localhost:4005
    - Set Referral Service URL: http://localhost:4006
    - Set Social Features Service URL: http://localhost:4007
    - _Requirements: 3.6, 11.2, 11.3_
  - [x] 12.2 Implement StorageService for JWT tokens
    - Use flutter_secure_storage
    - Implement saveToken, getToken, deleteToken, hasToken methods
    - _Requirements: 3.3, 11.2_
  - [x] 12.3 Add JWT token injection to ApiService
    - Modify _getHeaders to fetch token from StorageService
    - Add "Authorization: Bearer <token>" header
    - _Requirements: 3.6, 11.2_
  - [x] 12.4 Add error handling to ApiService
    - Handle 401: Clear token, redirect to login
    - Handle 403, 404, 500: Return appropriate error messages
    - Handle network errors: Return connection error message
    - _Requirements: 3.7, 13.2, 13.3, 13.4, 13.5, 14.2_

### Create Data Models

- [x] 13. Implement Data Models
  - [x] 13.1 Create User and AuthResponse models
    - User: id, name, email, phone, role
    - AuthResponse: user, token, needsProfileCompletion
    - Add json_serializable and Equatable
    - Run build_runner
    - _Requirements: 3.2, 12.1_
  - [x] 13.2 Create Post model
    - Post: transactionId, userId, platform, postUrl, status
    - Add json_serializable and Equatable
    - Run build_runner
    - _Requirements: 6.2, 12.1_
  - [x] 13.3 Create FAQ, Notification, Analytics models
    - FAQ: id, question, answer, category
    - Notification: id, type, title, message, isRead, createdAt
    - Analytics: (structure based on API response)
    - Add json_serializable and Equatable
    - Run build_runner
    - _Requirements: 7.3, 7.4, 7.5, 12.1_
  - [x] 13.4 Create Dispute and Transaction models
    - Dispute: id, transactionId, type, status, reason, amount, createdAt
    - Transaction: id, amount, type, status, description, createdAt
    - Add json_serializable and Equatable
    - Run build_runner
    - _Requirements: 8.2, 12.1_

### Implement Repositories

- [ ] 14. Create Repositories
  - [x] 14.1 Implement AuthRepository


    - login(String idToken): POST to http://localhost:4001/api/auth/firebase
    - logout(): Clear token from StorageService
    - _Requirements: 3.2, 11.1_
  - [ ] 14.2 Implement UsersRepository
    - getUsers(): Fetch from appropriate endpoint
    - acceptUser(String userId): Send accept request
    - rejectUser(String userId): Send reject request
    - _Requirements: 5.2, 5.4, 5.5, 11.1_
  - [ ] 14.3 Implement PostsRepository
    - getPendingPosts(): GET http://localhost:4001/api/admin/pending-social-posts
    - approvePost(String transactionId, String notes): PUT with verified=true
    - rejectPost(String transactionId, String notes): PUT with verified=false
    - _Requirements: 6.2, 6.4, 6.5, 11.1_
  - [ ] 14.4 Implement ContentRepository
    - getFAQs(), createFAQ(), updateFAQ(), deleteFAQ()
    - getNotifications(): GET http://localhost:4004/api/notifications
    - getAnalytics(): GET http://localhost:4002/api/transactions/analytics
    - _Requirements: 7.3, 7.4, 7.5, 7.6, 11.1_
  - [ ] 14.5 Implement PaymentsRepository
    - getDisputes(): GET http://localhost:4002/api/disputes
    - resolveDispute(String id, String resolution, String notes): POST
    - getTransactions(): GET http://localhost:4002/api/transactions
    - _Requirements: 8.2, 8.4, 8.5, 11.1_

### Implement BLoCs

- [ ] 15. Create BLoCs
  - [ ] 15.1 Implement AuthBloc
    - Events: LoginRequested, LogoutRequested
    - States: AuthInitial, AuthLoading, AuthAuthenticated, AuthError
    - Use AuthRepository and StorageService
    - _Requirements: 3.2, 3.4, 3.5, 3.7, 10.1, 10.2, 10.3_
  - [ ] 15.2 Implement DashboardBloc
    - Events: FetchDashboardData, RefreshDashboard
    - States: DashboardInitial, DashboardLoading, DashboardLoaded, DashboardError
    - Fetch data from multiple endpoints
    - _Requirements: 4.2, 10.1, 10.2, 10.3_
  - [ ] 15.3 Implement UsersBloc
    - Events: FetchUsers, AcceptUser, RejectUser, RefreshUsers
    - States: UsersInitial, UsersLoading, UsersLoaded, UsersError, UserActionSuccess
    - Use UsersRepository
    - _Requirements: 5.2, 5.4, 5.5, 10.1, 10.2, 10.3_
  - [ ] 15.4 Implement PostsBloc
    - Events: FetchPosts, ApprovePost, RejectPost, RefreshPosts
    - States: PostsInitial, PostsLoading, PostsLoaded, PostsError, PostActionSuccess
    - Use PostsRepository
    - _Requirements: 6.2, 6.4, 6.5, 10.1, 10.2, 10.3_
  - [ ] 15.5 Implement ContentBloc
    - Events: FetchFAQs, CreateFAQ, UpdateFAQ, DeleteFAQ, FetchNotifications, FetchAnalytics, RefreshContent
    - States: ContentInitial, ContentLoading, ContentLoaded, ContentError, FAQActionSuccess
    - Use ContentRepository
    - _Requirements: 7.3, 7.4, 7.5, 7.6, 10.1, 10.2, 10.3_
  - [ ] 15.6 Implement PaymentsBloc
    - Events: FetchDisputes, ResolveDispute, FetchTransactions, RefreshPayments
    - States: PaymentsInitial, PaymentsLoading, PaymentsLoaded, PaymentsError, DisputeResolved
    - Use PaymentsRepository
    - _Requirements: 8.2, 8.4, 8.5, 10.1, 10.2, 10.3_

### Connect Backend to UI

- [ ] 16. Integrate BLoCs with UI
  - [ ] 16.1 Connect AuthBloc to Login screen
    - Replace test login with real Firebase authentication
    - Add BlocProvider for AuthBloc
    - Use BlocConsumer to handle states
    - Navigate to /main on AuthAuthenticated
    - Show error on AuthError
    - _Requirements: 3.1, 3.2, 3.4, 3.5, 10.4_
  - [ ] 16.2 Connect DashboardBloc to Dashboard tab
    - Add BlocProvider for DashboardBloc
    - Replace mock data with real data from BLoC
    - Use BlocBuilder to show loading/error/data states
    - Add pull-to-refresh
    - _Requirements: 4.1, 4.2, 4.3, 10.4, 15.1, 15.2_
  - [ ] 16.3 Connect UsersBloc to Users tab
    - Add BlocProvider for UsersBloc
    - Replace mock data with real data from BLoC
    - Connect Accept/Reject buttons to dispatch events
    - Use BlocConsumer to show success messages
    - Add pull-to-refresh
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 10.4, 14.6, 15.1, 15.2_
  - [ ] 16.4 Connect PostsBloc to Posts tab
    - Add BlocProvider for PostsBloc
    - Replace mock data with real data from BLoC
    - Connect Approve/Reject buttons to dispatch events
    - Use BlocConsumer to show success messages
    - Add pull-to-refresh
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 10.4, 14.6, 15.1, 15.2_
  - [ ] 16.5 Connect ContentBloc to Content tab
    - Add BlocProvider for ContentBloc
    - Replace mock data with real data from BLoC
    - Connect FAQ CRUD buttons to dispatch events
    - Use BlocConsumer to show success messages
    - Add pull-to-refresh
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 10.4, 14.6, 15.1, 15.2_
  - [ ] 16.6 Connect PaymentsBloc to Payments tab
    - Add BlocProvider for PaymentsBloc
    - Replace mock data with real data from BLoC
    - Connect Resolve button to dispatch events
    - Use BlocConsumer to show success messages
    - Add pull-to-refresh
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 10.4, 14.6, 15.1, 15.2_

## Phase 4: Polish & Final Testing

- [ ] 17. Add Common Widgets
  - [ ] 17.1 Create LoadingIndicator widget
    - Reusable CircularProgressIndicator with consistent styling
    - _Requirements: 14.1_
  - [ ] 17.2 Create ErrorMessage widget
    - Display error with icon and retry button
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 14.2_
  - [ ] 17.3 Create SuccessMessage widget
    - Display success SnackBar with consistent styling
    - _Requirements: 14.6_

- [ ] 18. Final Integration Testing
  - [ ] 18.1 Test complete authentication flow
    - Test login with real Firebase credentials
    - Test token storage
    - Test logout
    - Test token expiration (401 handling)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  - [ ] 18.2 Test all tab functionalities with real backend
    - Test Dashboard data fetching
    - Test Users accept/reject
    - Test Posts approve/reject
    - Test Content FAQ CRUD, notifications, analytics
    - Test Payments dispute resolution
    - _Requirements: 4.1, 5.1, 6.1, 7.1, 8.1_
  - [ ] 18.3 Test error handling
    - Test network errors
    - Test API errors (401, 403, 404, 500)
    - Verify error messages display correctly
    - Test retry functionality
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 14.2_
  - [ ] 18.4 Test loading and success states
    - Verify loading indicators show during API calls
    - Verify success messages show after actions
    - Test pull-to-refresh on all tabs
    - _Requirements: 14.1, 14.6, 15.1, 15.2, 15.3_

## Notes

**CRITICAL WORKFLOW**:
1. **Phase 1**: Setup navigation with test login - verify all tabs are accessible
2. **Phase 2**: Build ALL UIs pixel-perfect from Figma with mock data - test UI only
3. **Phase 3**: Connect backend APIs - replace mock data with real data
4. **Phase 4**: Polish and final testing

**FOR EACH SCREEN**:
- User MUST provide Figma link + screenshot
- Extract design specs carefully
- Build UI pixel-perfectly
- Use mock data initially
- Test UI thoroughly before moving to next screen

**SPEED PRIORITY**:
- Focus on rapid UI implementation
- Keep backend integration simple and direct
- Skip optional features for MVP
- Test frequently during development

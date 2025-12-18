# 🚀 Fluence Pay Admin Panel

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-8.1.6-FF9800?style=for-the-badge)
![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A comprehensive Flutter-based administrative interface for managing the Fluence Pay platform**

[Features](#-features) • [Installation](#-installation) • [Architecture](#-architecture) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Key Features](#-key-features)
- [API Integration](#-api-integration)
- [Development](#-development)
- [Building for Production](#-building-for-production)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

**Fluence Pay Admin Panel** is a modern, cross-platform administrative dashboard built with Flutter that provides comprehensive management capabilities for the Fluence Pay ecosystem. The application enables administrators to manage users, merchants, transactions, social media posts, content, and analytics through an intuitive, responsive interface.

### What is Fluence Pay?

Fluence Pay is a fintech platform that combines cashback rewards, social media integration, and merchant services. The admin panel serves as the central control hub for managing all aspects of this ecosystem.

### Key Highlights

- 🎨 **Modern UI/UX**: Clean, responsive design with Material Design 3
- 🏗️ **Scalable Architecture**: BLoC pattern for maintainable state management
- 🔌 **Microservices Integration**: Seamless connection with 7 backend microservices
- 🔐 **Secure Authentication**: Firebase-based authentication with JWT token management
- 📱 **Cross-Platform**: Runs on Web, Android, and iOS from a single codebase
- ⚡ **Performance Optimized**: Efficient data fetching, caching, and state management
- 🎯 **Production Ready**: Error handling, loading states, and user feedback

---

## ✨ Features

### 🏠 Dashboard
- **Real-time Analytics**: View key metrics, statistics, and trends
- **Activity Feed**: Monitor recent user and merchant activities
- **Quick Actions**: Fast access to common administrative tasks
- **System Status**: Monitor service health and performance
- **Dual Views**: Switch between Users and Merchants dashboard perspectives

### 👥 User & Merchant Management
- **User Management**: View, search, and manage all platform users
- **Merchant Applications**: Review, approve, or reject merchant onboarding requests
- **User Profiles**: Access detailed user information and activity history
- **Status Management**: Update user and merchant account statuses

### 📱 Social Posts Management
- **Post Verification**: Review and verify social media posts from users
- **Approve/Reject**: Approve legitimate posts or reject invalid submissions
- **Post Analytics**: View engagement metrics and post performance
- **Duplicate Detection**: Identify and manage duplicate post submissions
- **Platform Support**: Manage posts from Instagram and other social platforms

### 💳 Payments & Transactions
- **Transaction Management**: View and manage all platform transactions
- **Dispute Resolution**: Handle payment disputes and chargebacks
- **Analytics**: Track transaction trends, volumes, and patterns
- **Export Functionality**: Export transaction data for reporting
- **Filtering & Search**: Advanced filtering by status, type, date range, and more

### 📝 Content Management
- **FAQ Management**: Create, edit, and delete frequently asked questions
- **Notifications**: Send and manage system-wide notifications
- **Terms & Conditions**: Upload and manage terms of service documents
- **Analytics Dashboard**: View content engagement and notification statistics
- **Recipient Management**: Manage notification recipients and groups

### 🔔 Notifications
- **Real-time Updates**: Receive instant notifications for important events
- **Unread Count**: Track unread notifications with badge indicators
- **Notification History**: View complete notification history
- **Mark as Read**: Bulk actions for managing notification status

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter** `^3.9.2` - Cross-platform UI framework
- **Dart** `^3.9.2` - Programming language

### State Management
- **flutter_bloc** `^8.1.6` - BLoC pattern implementation
- **bloc** `^8.1.4` - Core BLoC library
- **equatable** `^2.0.5` - Value equality for state objects

### Networking & API
- **http** `^1.2.2` - HTTP client for API requests
- **json_annotation** `^4.9.0` - JSON serialization annotations

### Authentication & Security
- **firebase_core** `^3.6.0` - Firebase SDK core
- **firebase_auth** `^5.3.1` - Firebase Authentication
- **flutter_secure_storage** `^9.0.0` - Secure storage for tokens

### UI & Design
- **google_fonts** `^6.2.1` - Inter font family integration
- **fl_chart** `^1.1.1` - Beautiful charts and graphs
- **Material Design 3** - Modern design system

### Utilities
- **intl** `^0.19.0` - Internationalization and date formatting
- **url_launcher** `^6.2.5` - Launch URLs and external links

### Development Tools
- **json_serializable** `^6.8.0` - Code generation for JSON
- **build_runner** `^2.4.13` - Code generation runner
- **flutter_lints** `^5.0.0` - Linting rules

---

## 🏗️ Architecture

### Architecture Pattern: BLoC (Business Logic Component)

The application follows the **BLoC pattern**, which provides:

- **Separation of Concerns**: Clear separation between UI, business logic, and data layers
- **Testability**: Business logic can be tested independently
- **Reusability**: BLoCs can be shared across multiple widgets
- **Predictable State Management**: Unidirectional data flow

### Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │   Widgets    │  │  Navigation  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↕ BLoC Events/States
┌─────────────────────────────────────────────────────────┐
│                   Business Logic Layer                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  AuthBloc    │  │ DashboardBloc│  │  PostsBloc   │  │
│  │  UsersBloc   │  │ Transactions │  │ ContentBloc │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↕ Repository Interface
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Repositories │  │  ApiService  │  │   Models     │  │
│  │   Storage    │  │   Firebase   │  │   Services   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↕ HTTP/API
┌─────────────────────────────────────────────────────────┐
│                  Backend Microservices                    │
│  Auth │ Cashback │ Merchant │ Notification │ Points │   │
│  Referral │ Social Features                              │
└─────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **BLoCs (Business Logic Components)**
- `AuthBloc`: Handles authentication state and user sessions
- `DashboardBloc`: Manages dashboard data and analytics
- `UsersBloc`: User and merchant management logic
- `PostsBloc`: Social post verification and management
- `TransactionsBloc`: Transaction and dispute management
- `ContentBloc`: FAQ, notifications, and content management
- `ActivityFeedBloc`: Recent activity tracking

#### 2. **Repositories**
- Data abstraction layer between BLoCs and API services
- Handle data transformation and error handling
- Provide clean interfaces for data operations

#### 3. **Services**
- `ApiService`: Centralized HTTP client with microservice routing
- `FirebaseService`: Firebase initialization and configuration
- `StorageService`: Secure token storage and retrieval

#### 4. **Models**
- Type-safe data models with JSON serialization
- Equatable for value comparison
- Immutable data structures

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.9.2 or higher)
  ```bash
  flutter --version
  ```
- **Dart SDK** (3.9.2 or higher)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **VS Code** or **Android Studio** (recommended IDEs)
- **Git** (for version control)

### Backend Requirements

The admin panel requires the Fluence Pay backend microservices to be running. See the [Backend Repository](https://github.com/your-org/fluence-backend) for setup instructions.

**Required Services:**
- Auth Service (Port 4001)
- Cashback Budget Service (Port 4002)
- Merchant Onboarding Service (Port 4003)
- Notification Service (Port 4004)
- Points Wallet Service (Port 4005)
- Referral Service (Port 4006)
- Social Features Service (Port 4007)

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/fluence-admin-panel.git
cd fluence-admin-panel
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (if needed)

If you modify models with JSON annotations, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase Authentication
3. Download configuration files:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`
   - **Web**: Add Firebase config to `lib/firebase_options.dart`

4. Update `lib/firebase_options.dart` with your Firebase configuration

### 5. Run the Application

#### Web
```bash
flutter run -d chrome
```

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

---

## ⚙️ Configuration

### API Configuration

The application automatically detects the platform and uses the appropriate backend URL. Configure in `lib/services/api_service.dart`:

```dart
// Remote Backend (Production/Staging)
static const String REMOTE_BACKEND_URL = 'http://your-backend-url.com';
static const bool USE_REMOTE_BACKEND = true;

// Local Development
static const String WEB_DEV_URL = 'http://localhost';
static const String ANDROID_EMULATOR_URL = 'http://10.0.2.2';
static const String ANDROID_DEVICE_URL = 'http://192.168.0.180'; // Your local IP
```

### Environment Variables

Create environment-specific configuration files if needed:

- `.env.development` - Development environment
- `.env.staging` - Staging environment
- `.env.production` - Production environment

### Platform-Specific Configuration

#### Android
- Update `android/app/build.gradle` with your package name
- Configure `AndroidManifest.xml` for network permissions

#### iOS
- Update `ios/Runner/Info.plist` with required permissions
- Configure URL schemes if needed

#### Web
- Update `web/index.html` with meta tags and Firebase config
- Configure CORS settings for API access

---

## 📁 Project Structure

```
lib/
├── app.dart                    # Main app widget and routing
├── main.dart                   # Application entry point
│
├── blocs/                      # Business Logic Components
│   ├── auth_bloc.dart
│   ├── dashboard_bloc.dart
│   ├── users_bloc.dart
│   ├── posts_bloc.dart
│   ├── transactions_bloc.dart
│   ├── content_bloc.dart
│   └── activity_feed_bloc.dart
│
├── models/                     # Data models
│   ├── user.dart
│   ├── post.dart
│   ├── transaction.dart
│   ├── notification.dart
│   ├── faq.dart
│   └── ...
│
├── repositories/               # Data layer
│   ├── auth_repository.dart
│   ├── users_repository.dart
│   ├── posts_repository.dart
│   ├── transactions_repository.dart
│   ├── content_repository.dart
│   └── ...
│
├── services/                   # External services
│   ├── api_service.dart        # HTTP client and microservice routing
│   ├── firebase_service.dart   # Firebase initialization
│   └── storage_service.dart    # Secure storage
│
├── screens/                    # UI screens
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── dashboard_tab.dart
│   ├── users_tab.dart
│   ├── posts_tab.dart
│   ├── payments_tab.dart
│   ├── content_tab.dart
│   └── web/                    # Web-specific screens
│       ├── web_dashboard_screen.dart
│       └── web_content_screen.dart
│
├── widgets/                    # Reusable widgets
│   ├── faq/
│   ├── terms/
│   └── web/
│
├── utils/                      # Utilities and helpers
│   ├── app_colors.dart
│   ├── app_constants.dart
│   ├── responsive_helper.dart
│   └── ...
│
└── constants/                  # App constants
    ├── web_design_constants.dart
    └── app_text_styles.dart
```

---

## 🎯 Key Features

### 🔐 Authentication & Security

- **Firebase Authentication**: Secure login with Firebase Auth
- **JWT Token Management**: Automatic token storage and refresh
- **Secure Storage**: Sensitive data stored using `flutter_secure_storage`
- **Session Management**: Automatic session validation and timeout handling
- **Password Reset**: Secure password reset functionality

### 📊 Dashboard Analytics

- **Real-time Metrics**: Live updates of key performance indicators
- **User Statistics**: Total users, active users, new registrations
- **Merchant Statistics**: Total merchants, pending applications, active merchants
- **Transaction Analytics**: Volume, trends, and revenue metrics
- **Post Statistics**: Pending, approved, and rejected post counts
- **Activity Feed**: Recent platform activities and events

### 👥 User Management

- **User Listing**: View all platform users with pagination
- **Search & Filter**: Advanced search and filtering capabilities
- **User Details**: Comprehensive user profile information
- **Status Management**: Activate, deactivate, or suspend user accounts
- **Activity History**: View user activity and transaction history

### 🏪 Merchant Management

- **Application Review**: Review merchant onboarding applications
- **Approval Workflow**: Approve or reject merchant applications
- **Merchant Profiles**: View and manage merchant information
- **Status Tracking**: Monitor merchant account status
- **Application History**: Track application submission and review timeline

### 📱 Social Posts Management

- **Post Verification**: Review social media posts for authenticity
- **Approve/Reject Actions**: Quick actions for post verification
- **Post Details**: View complete post information and metadata
- **Duplicate Detection**: Identify and manage duplicate submissions
- **Analytics**: Track post engagement and verification metrics
- **Platform Support**: Manage posts from multiple social platforms

### 💳 Payment Management

- **Transaction Listing**: View all platform transactions
- **Advanced Filtering**: Filter by status, type, date, amount
- **Dispute Management**: Handle payment disputes and chargebacks
- **Transaction Details**: View comprehensive transaction information
- **Export Functionality**: Export transaction data for reporting
- **Analytics**: Transaction trends and revenue analytics

### 📝 Content Management

#### FAQ Management
- **CRUD Operations**: Create, read, update, and delete FAQs
- **Category Management**: Organize FAQs by categories
- **Search Functionality**: Search through FAQ content
- **Rich Text Support**: Format FAQ content with rich text

#### Notifications
- **Send Notifications**: Create and send system-wide notifications
- **Recipient Management**: Manage notification recipients
- **Notification History**: View sent notification history
- **Read Status Tracking**: Track notification read status

#### Terms & Conditions
- **Document Upload**: Upload terms and conditions documents
- **Version Management**: Manage multiple versions of terms
- **Preview Functionality**: Preview terms before publishing

### 🎨 Responsive Design

- **Web Optimized**: Full-featured web interface with sidebar navigation
- **Mobile Responsive**: Optimized for mobile devices
- **Adaptive Layouts**: Layouts adapt to screen size
- **Touch Optimized**: Touch-friendly interface for mobile devices

---

## 🔌 API Integration

### Microservices Architecture

The admin panel integrates with 7 microservices:

| Service | Port | Purpose |
|---------|------|---------|
| **Auth Service** | 4001 | Authentication, user management, admin operations |
| **Cashback Budget Service** | 4002 | Budgets, campaigns, transactions, disputes |
| **Merchant Onboarding Service** | 4003 | Merchant applications and profiles |
| **Notification Service** | 4004 | Notifications, FAQ, terms management |
| **Points Wallet Service** | 4005 | Points and wallet management |
| **Referral Service** | 4006 | Referral system management |
| **Social Features Service** | 4007 | Social media integration and posts |

### API Service

The `ApiService` class handles:

- **Platform Detection**: Automatically detects platform (Web, Android, iOS)
- **URL Routing**: Routes requests to appropriate microservice
- **Authentication**: Adds JWT tokens to requests
- **Error Handling**: Centralized error handling and retry logic
- **Request Logging**: Debug logging for API requests

### Example API Usage

```dart
// In a repository
final response = await ApiService.post(
  ServiceType.auth,
  '/api/auth/firebase',
  body: {'idToken': firebaseToken},
);

// In a BLoC
try {
  final users = await _usersRepository.getAllUsers();
  emit(UsersLoaded(users));
} catch (e) {
  emit(UsersError(e.toString()));
}
```

### Authentication Flow

1. User logs in with Firebase
2. Firebase ID token is sent to Auth Service
3. Auth Service validates and returns JWT token
4. JWT token is stored securely
5. Token is included in all subsequent API requests
6. Token is validated and refreshed as needed

---

## 💻 Development

### Running in Development Mode

```bash
# Run with hot reload
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

### Code Generation

When you modify models with `@JsonSerializable`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Linting

```bash
# Run linter
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_bloc_test.dart
```

### Debugging

- Use Flutter DevTools for debugging
- Enable debug logging in `ApiService`
- Use `print()` statements (remove before production)
- Check network requests in browser DevTools (web)

---

## 🏗️ Building for Production

### Web Build

```bash
# Build for web
flutter build web --release

# Build with specific base href
flutter build web --release --base-href /admin/
```

### Android Build

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS Build

```bash
# Build iOS app
flutter build ios --release

# Build for App Store
flutter build ipa --release
```

### Environment Configuration

Before building for production:

1. Update `ApiService` with production backend URL
2. Configure Firebase for production
3. Update app version in `pubspec.yaml`
4. Review and update security settings
5. Test all features thoroughly

---

## 🐛 Troubleshooting

### Common Issues

#### 1. **Backend Connection Issues**

**Problem**: Cannot connect to backend services

**Solutions**:
- Verify backend services are running
- Check `ApiService` URL configuration
- Verify network connectivity
- Check firewall settings
- For Android emulator, use `10.0.2.2` instead of `localhost`

#### 2. **Firebase Authentication Errors**

**Problem**: Firebase authentication fails

**Solutions**:
- Verify Firebase configuration files are in place
- Check Firebase project settings
- Verify authentication methods are enabled in Firebase Console
- Check internet connectivity

#### 3. **Build Errors**

**Problem**: Code generation or build fails

**Solutions**:
```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Clear cache
flutter pub cache repair
```

#### 4. **Platform-Specific Issues**

**Web**:
- Check CORS settings in backend
- Verify web assets are properly configured
- Check browser console for errors

**Android**:
- Verify `google-services.json` is in `android/app/`
- Check AndroidManifest.xml permissions
- Verify minSdkVersion compatibility

**iOS**:
- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Check Info.plist permissions
- Verify CocoaPods dependencies: `cd ios && pod install`

### Getting Help

- Check [Flutter Documentation](https://docs.flutter.dev/)
- Review [BLoC Documentation](https://bloclibrary.dev/)
- Check backend service logs
- Review GitHub Issues
- Contact the development team

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Contribution Process

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow the existing code style
   - Write clear commit messages
   - Add tests if applicable
4. **Run tests and linting**
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**
   ```bash
   git commit -m "Add: Description of your feature"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use BLoC pattern for state management

### Commit Message Format

```
Type: Brief description

Detailed explanation if needed
```

**Types**: `Add`, `Fix`, `Update`, `Remove`, `Refactor`, `Docs`, `Test`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **BLoC Library** - For state management patterns
- **Firebase** - For authentication services
- **Backend Team** - For the robust microservices architecture

---

## 📞 Contact & Support

- **Repository**: [GitHub Repository](https://github.com/your-org/fluence-admin-panel)
- **Issues**: [GitHub Issues](https://github.com/your-org/fluence-admin-panel/issues)
- **Documentation**: [Full Documentation](https://docs.fluencepay.com/admin)
- **Backend Docs**: [Backend Repository](https://github.com/your-org/fluence-backend)

---

<div align="center">

**Built with ❤️ using Flutter**

[⬆ Back to Top](#-fluence-pay-admin-panel)

</div>

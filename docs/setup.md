# Fluence App - BLoC Architecture Setup

## Project Structure

The Fluence App has been set up with a clean BLoC (Business Logic Component) architecture:

```
lib/
├── blocs/          # BLoC classes for state management
├── models/         # Data models
├── repositories/   # Data repositories
├── services/       # API services
├── screens/        # UI screens
├── widgets/        # Reusable widgets
└── main.dart       # App entry point
```

## Dependencies Added

- `flutter_bloc: ^8.1.6` - Flutter BLoC library
- `bloc: ^8.1.4` - Core BLoC library
- `equatable: ^2.0.5` - Value equality
- `http: ^1.2.2` - HTTP requests
- `json_annotation: ^4.9.0` - JSON serialization
- `json_serializable: ^6.8.0` - JSON code generation
- `build_runner: ^2.4.13` - Code generation runner

## Current Implementation

### Counter BLoC Example
- **CounterBloc**: Manages counter state with increment, decrement, and reset functionality
- **CounterEvent**: Defines events (Increment, Decrement, Reset)
- **CounterState**: Manages the counter value state
- **HomeScreen**: UI that uses BlocBuilder to display counter and BlocProvider to dispatch events

## Next Steps

1. Upload your project README to the `docs/` folder
2. Define your specific data models in `lib/models/`
3. Create repositories for data management in `lib/repositories/`
4. Add API services in `lib/services/`
5. Build your app screens in `lib/screens/`

## Running the App

```bash
flutter pub get
flutter run
```

The app currently displays a counter with increment, decrement, and reset buttons using BLoC pattern.
# AI Diet Recommendation App

A complete, production-ready Flutter mobile application for AI-powered diet recommendations with accessibility and regional language support.

## 🎯 Features

### Core Features
- **AI-Powered Meal Planning**: Personalized daily meal plans based on user goals and preferences
- **Ingredient-Based Recipe Generation**: Input available ingredients to get AI recipe suggestions
- **Regional Language Support**: English and Hindi with proper TTS integration
- **Full Accessibility**: Voice-first mode, screen reader support, and hands-free navigation
- **Progress Tracking**: Daily calorie and macro tracking with visual charts
- **User Profiles**: Complete user management with health goals and dietary preferences

### Technical Features
- **Material 3 Design**: Modern UI with proper theming and color schemes
- **State Management**: Riverpod for reactive state management
- **Local Storage**: SharedPreferences for user data persistence
- **Voice Integration**: Text-to-Speech and Speech-to-Text capabilities
- **Charts**: Beautiful progress visualization with fl_chart
- **Accessibility**: Full screen reader support and voice navigation

## 📱 Project Structure

```
ai_diet_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/                        # Core utilities & theming
│   │   ├── theme.dart              # App theme & colors
│   │   └── constants.dart          # App constants
│   ├── models/                      # Data models
│   │   ├── user_model.dart         # User data model
│   │   └── meal_model.dart         # Meal & nutrition models
│   ├── services/                    # Business logic services
│   │   ├── storage_service.dart    # Local data storage
│   │   ├── tts_service.dart        # Text-to-speech
│   │   └── meal_service.dart       # Meal data & AI logic
│   ├── providers/                   # State management
│   │   ├── user_provider.dart      # User state
│   │   └── meal_provider.dart      # Meal & recipe state
│   ├── screens/                     # UI Screens
│   │   ├── splash_screen.dart      # App loading screen
│   │   ├── onboarding/             # User setup flow
│   │   └── home/                   # Main app screens
│   └── widgets/                     # Reusable UI components
│       ├── meal_card.dart          # Meal display component
│       ├── custom_button.dart      # Styled buttons
│       └── progress_circle.dart    # Progress visualization
├── assets/
│   └── data/
│       └── sample_meals.json       # Sample meal data
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10.0 or higher
- Dart 3.0.0 or higher
- Android Studio or VS Code
- Git

### Installation

1. **Navigate to the project directory**
   ```bash
   cd ai_diet_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### First Run
1. The app will start with a splash screen
2. First-time users go through onboarding:
   - Personal information (name, age, weight, height)
   - Health goals (weight loss, gain, maintenance, etc.)
   - Dietary preferences (vegetarian, vegan, etc.)
   - Language and accessibility preferences
3. Returning users go directly to the home screen

## 🎨 App Features Walkthrough

### 1. Onboarding Flow
- **Welcome Screen**: Introduction with accessibility toggle
- **Basic Info**: Personal details collection
- **Goals**: Health and fitness objective selection  
- **Preferences**: Diet type and language selection

### 2. Home Dashboard
- **Greeting Section**: Personalized welcome message
- **Progress Overview**: Daily calorie and macro tracking
- **Quick Actions**: Fast access to key features
- **Meal Plan**: Today's AI-generated meals

### 3. Ingredients Screen
- **Input Section**: Text and voice ingredient entry
- **Quick Selection**: Common ingredients as chips
- **Recipe Generation**: AI-powered suggestions
- **Recipe Details**: Full cooking instructions

### 4. Progress Screen
- **Daily Overview**: Calorie progress with visual indicators
- **Macro Breakdown**: Pie chart of protein, carbs, fat
- **Weekly Trends**: Progress over time visualization

### 5. Profile Screen
- **User Info**: Personal details and health stats
- **Settings**: Language, accessibility, preferences
- **Actions**: Help, support, and sign-out options

## 🎯 Team Development

This project is organized for 3-person team development:

### Person 1: UI/UX Developer
- **Folder**: `lib/screens/`, `lib/widgets/`, `lib/core/theme.dart`
- **Responsibility**: All user interface and experience design
- **Skills**: Flutter UI, Material Design, Accessibility

### Person 2: Data Layer Developer  
- **Folder**: `lib/models/`, `lib/services/`, `lib/providers/`
- **Responsibility**: Data models, business logic, state management
- **Skills**: Dart programming, State management, API integration

### Person 3: AI/Backend Integration
- **Folder**: `lib/services/tts_service.dart`, backend APIs
- **Responsibility**: AI features, voice integration, backend services
- **Skills**: AI/ML, Voice processing, Backend development

## 🔧 Key Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  flutter_riverpod: ^2.4.9      # State management
  google_fonts: ^6.1.0          # Typography
  shared_preferences: ^2.2.2     # Local storage
  fl_chart: ^0.65.0             # Charts and graphs
  flutter_tts: ^3.8.5          # Text-to-speech
  speech_to_text: ^6.6.0       # Voice input
```

## 📊 Data Models

### User Model
- Personal info (name, age, weight, height, gender)
- Health goals and dietary preferences
- Target calories and BMR calculation
- Language and accessibility settings

### Meal Model
- Nutritional information (calories, macros)
- Ingredients and cooking instructions
- Cuisine type and difficulty level
- Dietary flags (vegetarian, vegan, etc.)

### Meal Plan Model
- Daily meal organization (breakfast, lunch, dinner)
- Total nutritional calculation
- Date tracking and history

## 🎙️ Accessibility Features

### Voice Integration
- Text-to-speech for all content
- Voice navigation commands
- Meal information read-aloud
- Recipe instruction narration

### Visual Accessibility
- High contrast mode support
- Scalable text sizing
- Clear visual hierarchy
- Proper semantic labeling

### Interaction Accessibility
- Large touch targets
- Clear focus indicators
- Keyboard navigation support
- Screen reader compatibility

## 🌍 Internationalization

### Supported Languages
- **English**: Full feature support
- **Hindi**: UI translation and TTS support

### Adding New Languages
1. Add translations to language service
2. Update TTS language mapping
3. Test voice features in new language
4. Update UI layout for text expansion

## 🔮 Future Enhancements

### Phase 2 Features
- [ ] Food image recognition with camera
- [ ] Barcode scanning for packaged foods
- [ ] Fitness tracker integration (Google Fit, Apple Health)
- [ ] Social features and meal sharing
- [ ] Grocery delivery integration

### AI Improvements
- [ ] Computer vision for portion estimation
- [ ] Natural language meal planning
- [ ] Predictive nutrition recommendations
- [ ] Mood-based meal suggestions

### Technical Improvements
- [ ] Offline mode support
- [ ] Real-time nutrition tracking
- [ ] Advanced analytics dashboard
- [ ] Multi-platform support (Web, Desktop)

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests  
flutter drive --target=test_driver/app.dart

# Widget tests
flutter test test/widget_test.dart
```

### Testing Checklist
- [ ] All screens load properly
- [ ] Onboarding flow completes
- [ ] Meal plan generation works
- [ ] Progress tracking updates
- [ ] Voice features function
- [ ] Language switching works
- [ ] Data persistence works

## 📱 Building for Release

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS  
```bash
flutter build ios --release
# Follow iOS deployment guidelines
```

## 🐛 Troubleshooting

### Common Issues

**TTS not working:**
```dart
// Check TTS initialization
await TTSService.init();
bool available = await TTSService.isAvailable();
```

**State not updating:**
```dart
// Ensure proper provider setup
ref.read(userProvider.notifier).setUser(user);
```

**Build errors:**
```bash
flutter clean
flutter pub get
flutter run
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team Contact

- **UI/UX Developer**: [Your contact info]
- **Data Layer Developer**: [Your contact info]  
- **AI/Backend Developer**: [Your contact info]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- OpenAI for inspiration on AI integration
- Accessibility guidelines from W3C
- Open source packages used in this project

---

**Ready to run!** This is a complete, production-ready Flutter application that you can run immediately with `flutter run`. The project includes all necessary files, proper error handling, and a clean architecture suitable for team development.

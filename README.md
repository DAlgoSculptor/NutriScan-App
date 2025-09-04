# NutriScan - Food Ingredient Safety Scanner

NutriScan is a Flutter mobile application that helps users identify harmful ingredients in food products through intelligent scanning and analysis. The app empowers healthier food choices by providing instant access to ingredient safety information.

## 🌟 Features

### Core Functionality
- **Smart Ingredient Scanning**: Camera-based ingredient capture with text processing
- **Harmful Ingredient Detection**: Rule-based matching against comprehensive database
- **Risk Assessment**: Color-coded risk levels (High, Moderate, Caution, Safe)
- **Detailed Analysis**: Comprehensive ingredient information with health impact explanations
- **Modern UI**: Clean, health-focused design with green accent colors
- **Dark/Light Mode**: Automatic theme switching based on system preferences

### App Sections
1. **Home Screen**: Welcome interface with app overview and quick actions
2. **Scan Module**: Image capture, processing, and results display
3. **About Section**: App information, vision, mission, and impact
4. **Contact Form**: User communication with validation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation
1. Clone the repository:
```bash
cd nutriscan
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code (for JSON serialization):
```bash
flutter packages pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

## 📊 Harmful Ingredients Database

The app includes a comprehensive database of 20+ harmful ingredients:

### Categories Covered
- **Artificial Colors**: Tartrazine (E102), Sunset Yellow (E110), Allura Red (E129)
- **Preservatives**: Sodium Nitrite (E250), Sodium Benzoate (E211)
- **Artificial Sweeteners**: Aspartame (E951), Sucralose (E955)
- **Antioxidants**: BHT (E321), BHA (E320)
- **Flavor Enhancers**: MSG (E621)
- **And more...**: Trans fats, HFCS, Carrageenan, etc.

### Risk Levels
- **High Risk**: Potentially carcinogenic or severely harmful
- **Moderate Risk**: Concerning ingredients with documented side effects
- **Caution**: Ingredients that may cause sensitivity in some individuals

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/           # Data models (Ingredient, ScanResult)
├── services/         # Business logic services
├── screens/          # App screens
├── widgets/          # Reusable UI components
├── theme/            # App theming and colors
└── main.dart         # App entry point
```

## 🔮 Future Enhancements

- **ML Integration**: Replace rule-based matching with machine learning
- **Real OCR**: Google ML Kit text recognition
- **Barcode Scanning**: Direct product database lookup
- **User Accounts**: Personal preferences and history
- **Community Features**: User reviews and crowdsourced data

## 📱 Technical Specifications

### Supported Platforms
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+ (ready for implementation)

---

**NutriScan** - Empowering Healthier Food Choices Through Technology

*Built with ❤️ using Flutter*

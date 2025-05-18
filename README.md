# Logistics Demo

A Flutter application for logistics tracking and management with a modern UI and localization support.

## Features

- Real-time shipment tracking
- Multi-language support
- Responsive design (Mobile & Web)
- Dashboard with activity overview
- Shipment management (Create, Edit, Delete)
- Status updates and tracking history
- Modern UI with dark theme

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone [repository-url]
cd logistics_demo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── constants/         # App constants and configurations
├── features/         # Feature-based modules
│   ├── auth/        # Authentication related screens and widgets
│   ├── dashboard/   # Dashboard related screens and widgets
│   └── shipment/    # Shipment management related screens and widgets
├── l10n/            # Localization files
├── services/        # Business logic and services
├── theme/           # Theme configuration
├── util/            # Utility functions
└── widgets/         # Reusable widgets

```

## Localization

The app supports multiple languages. Localization files are stored in `lib/l10n/` directory.

To add a new language:
1. Create a new ARB file in `lib/l10n/`
2. Run `flutter gen-l10n` to generate the localization code

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

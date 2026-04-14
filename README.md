# Memory Miles — Flutter Android App

A Flutter conversion of the Memory Miles MERN travel story journaling app.

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & auth wrapper
├── models/
│   ├── user.dart                      # User model
│   └── travel_story.dart              # TravelStory model
├── services/
│   └── api_service.dart               # All API calls (REST)
├── providers/
│   ├── auth_provider.dart             # Auth state (login/signup/logout)
│   └── story_provider.dart            # Stories state (CRUD)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart          # Login screen
│   │   └── signup_screen.dart         # Signup screen
│   ├── home/
│   │   └── home_screen.dart           # Home (story grid + search)
│   └── story/
│       ├── add_edit_story_screen.dart # Add / Edit story
│       └── view_story_screen.dart     # View full story
├── widgets/
│   └── story_card.dart                # Reusable story card widget
└── utils/
    ├── constants.dart                 # API base URL config
    └── theme.dart                     # App colors & theme
```

## ⚙️ Setup Instructions

### 1. Install Flutter
Follow https://docs.flutter.dev/get-started/install

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Configure your backend URL

Open `lib/utils/constants.dart` and update the base URL:

```dart
// For Android Emulator (localhost on your machine):
static const String baseUrl = 'http://10.0.2.2:3000/api';

// For physical Android device (replace with your computer's local IP):
static const String baseUrl = 'http://192.168.1.XX:3000/api';
```

> 💡 Find your local IP on Windows: `ipconfig` | on Mac/Linux: `ifconfig`

### 4. Start your Node.js backend
```bash
cd backend
npm install
npm start
```

Make sure your backend's CORS allows requests from the app. In `backend/index.js`, 
update the CORS origin to also allow your device IP or use `*` during development:

```js
app.use(cors({
  origin: "*",  // for development
  credentials: true,
}))
```

### 5. Run the app
```bash
# On Android emulator:
flutter run

# Build APK for device:
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

## ✨ Features

| Feature | Status |
|---|---|
| User Signup / Login / Logout | ✅ |
| Auto-login (token persistence) | ✅ |
| View all travel stories (grid) | ✅ |
| Add new travel story | ✅ |
| Edit existing story | ✅ |
| Delete story | ✅ |
| Toggle favorite | ✅ |
| Search stories | ✅ |
| Upload cover image | ✅ |
| View story detail | ✅ |
| Pull to refresh | ✅ |
| Empty state UI | ✅ |

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `http` | HTTP requests |
| `shared_preferences` | JWT token storage |
| `image_picker` | Pick images from gallery |
| `intl` | Date formatting |
| `cached_network_image` | Efficient image loading |

## 🔧 Notes

- Your **backend (Node.js + Express + MongoDB) stays unchanged** — the Flutter app just consumes your existing REST API.
- JWT token is stored in `SharedPreferences` for persistent login.
- The app uses `10.0.2.2` as the default host which maps to `localhost` on Android Emulator.
- For physical devices, replace with your machine's local IP address.

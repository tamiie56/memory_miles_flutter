# Memory Miles — Flutter Travel Diary App

A full-stack travel story journaling app built with Flutter (Android + Web) and a Node.js/Express backend deployed on Render.

## 🚀 Live Backend
```
https://memory-miles-backend.onrender.com/api
```

> ⚠️ Free tier on Render may cause a **~50 second cold start delay** on first request after inactivity.

## 📱 Download APK
Get the latest release from [Releases](https://github.com/tamiie56/memory_miles_flutter/releases).

---

## 📁 Project Structure

```
memory_miles_flutter/
├── lib/                                    # Flutter frontend
│   ├── main.dart                           # App entry point & auth wrapper
│   ├── models/
│   │   ├── user.dart                       # User model
│   │   └── travel_story.dart              # TravelStory model
│   ├── services/
│   │   ├── api_service.dart               # All REST API calls
│   │   ├── token_storage.dart             # JWT token storage (mobile)
│   │   └── token_storage_web.dart         # JWT token storage (web)
│   ├── providers/
│   │   ├── auth_provider.dart             # Auth state (login/signup/logout)
│   │   └── story_provider.dart            # Stories state (CRUD)
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart          # Login screen
│   │   │   ├── signup_screen.dart         # Signup screen
│   │   │   ├── forgot_password_screen.dart # Forgot password
│   │   │   └── reset_password_screen.dart  # Reset password
│   │   ├── home/
│   │   │   └── home_screen.dart           # Home (story grid + search)
│   │   └── story/
│   │       ├── add_edit_story_screen.dart # Add / Edit story
│   │       └── view_story_screen.dart     # View full story + media gallery
│   ├── widgets/
│   │   └── story_card.dart                # Reusable story card widget
│   └── utils/
│       ├── constants.dart                 # API base URL config
│       └── theme.dart                     # App colors & theme
│
├── backend/                               # Node.js backend
│   ├── controllers/
│   │   ├── auth.controller.js             # signup, signin, forgot/reset password
│   │   ├── travelStory.controller.js      # Story CRUD + image upload
│   │   └── user.controller.js             # User logic
│   ├── models/
│   │   ├── user.model.js                  # User schema (with reset token fields)
│   │   └── travelStory.model.js           # TravelStory schema
│   ├── routes/
│   │   ├── auth.route.js                  # /api/auth/*
│   │   ├── user.route.js                  # /api/user/*
│   │   └── travelStory.route.js           # /api/travelStory/*
│   ├── utils/
│   │   ├── verifyUser.js                  # JWT middleware
│   │   ├── error.js                       # Error handler
│   │   └── sendEmail.js                   # Nodemailer email utility
│   ├── multer.js                          # Cloudinary storage config
│   └── index.js                           # Express app entry point
│
├── android/                               # Android config
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

---

## ✨ Features

| Feature | Status |
|---|---|
| User Signup / Login / Logout | ✅ |
| Auto-login (JWT token persistence) | ✅ |
| Forgot Password (email reset link) | ✅ |
| Reset Password | ✅ |
| View all travel stories (staggered grid) | ✅ |
| Add new travel story | ✅ |
| Edit existing story | ✅ |
| Delete story | ✅ |
| Toggle favorite | ✅ |
| Search stories by title/content | ✅ |
| Filter stories by date range | ✅ |
| Multiple image upload (Cloudinary) | ✅ |
| Video upload (Cloudinary, max 30s recommended) | ✅ |
| Location search (OpenStreetMap Nominatim) | ✅ |
| Story detail view with swipeable media gallery | ✅ |
| Video player in story view (Chewie) | ✅ |
| Pull to refresh | ✅ |
| Flutter Web support | ✅ |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Android + Web) |
| Backend | Node.js, Express.js v5 |
| Database | MongoDB (Mongoose) |
| Cloud Storage | Cloudinary (images + videos) |
| Authentication | JWT (cookie + Authorization header) |
| Email | Nodemailer (Gmail App Password) |
| Location Search | OpenStreetMap Nominatim API |
| Deployment | Render (free tier) |

---

## 🔌 API Endpoints

### Auth
```
POST   /api/auth/signup
POST   /api/auth/signin
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
```

### User
```
POST   /api/user/signout
GET    /api/user/getusers
```

### Travel Stories
```
POST   /api/travelStory/add
GET    /api/travelStory/get-all
POST   /api/travelStory/edit-story/:id
DELETE /api/travelStory/delete-story/:id
PUT    /api/travelStory/update-is-favorite/:id
GET    /api/travelStory/search?query=
GET    /api/travelStory/filter?startDate=&endDate=
POST   /api/travelStory/image-upload
DELETE /api/travelStory/delete-image
```

---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK
- Node.js
- MongoDB Atlas account
- Cloudinary account
- Gmail account (for password reset emails)

### 1. Clone the repo
```bash
git clone https://github.com/tamiie56/memory_miles_flutter.git
cd memory_miles_flutter
```

### 2. Backend setup
```bash
cd backend
npm install
```

Create a `.env` file in the `backend/` folder:
```env
MONGO_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_gmail_app_password
CLIENT_URL=http://localhost:8080
```

> 💡 `EMAIL_PASS` is a Gmail **App Password**, not your regular password.
> Generate one: Google Account → Security → 2-Step Verification → App Passwords

Start the backend:
```bash
npm run dev
```

### 3. Flutter setup
```bash
flutter pub get
```

Open `lib/utils/constants.dart` and configure the base URL:

```dart
class AppConstants {
  // Local development (comment out for production)
  // static const String baseUrl = 'http://localhost:3000/api';
  // static const String uploadBaseUrl = 'http://localhost:3000';

  // Production
  static const String baseUrl = 'https://memory-miles-backend.onrender.com/api';
  static const String uploadBaseUrl = 'https://memory-miles-backend.onrender.com';
}
```

### 4. Run the app

```bash
# Flutter Web (local dev — fixed port required for password reset)
flutter run -d chrome --web-port=8080

# Android APK
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

> 💡 `--web-port=8080` is required so the password reset email link works correctly with `CLIENT_URL`.

---

## 📦 Dependencies

### Flutter
| Package | Purpose |
|---|---|
| `provider` | State management |
| `http` | HTTP requests |
| `dio` | Alternative HTTP client |
| `shared_preferences` | JWT token storage (mobile) |
| `image_picker` | Pick images from gallery |
| `file_picker` | Pick files on web |
| `video_player` | Video playback |
| `chewie` | Video player UI |
| `cached_network_image` | Efficient image loading |
| `flutter_staggered_grid_view` | Story grid layout |
| `intl` | Date formatting |
| `fluttertoast` | Toast notifications |
| `cupertino_icons` | iOS-style icons |

### Backend
| Package | Purpose |
|---|---|
| `express` | Web framework |
| `mongoose` | MongoDB ODM |
| `bcryptjs` | Password hashing |
| `jsonwebtoken` | JWT auth |
| `cloudinary` | Cloud media storage |
| `multer` + `multer-storage-cloudinary` | File upload |
| `nodemailer` | Send reset password emails |
| `dotenv` | Environment variables |
| `cookie-parser` | Cookie handling |
| `cors` | Cross-origin requests |
| `nodemon` | Dev auto-restart |

---

## 🔧 Notes

- JWT token is stored in `SharedPreferences` on mobile and `localStorage` on web.
- `verifyUser.js` supports both cookie and `Authorization: Bearer <token>` header.
- Cloudinary `resource_type` is auto-detected — both images and videos are supported.
- For password reset to work on Flutter Web, `CLIENT_URL` in `.env` must match the Flutter Web app URL (e.g. `http://localhost:8080`).

# Memory Miles — Flutter Travel Diary App

A full-stack travel story journaling app built with Flutter (Android + Web) and a Node.js/Express backend deployed on Render.

## Live Backend
```
https://memory-miles-backend.onrender.com/api
```

## Download APK
Get the latest release from [Releases](https://github.com/tamiie56/memory_miles_flutter/releases).

---

## Project Structure

```
memory_miles_flutter/
├── lib/                                         # Flutter frontend
│   ├── main.dart                                # App entry point & auth wrapper
│   ├── models/
│   │   ├── user.dart                            # User model (with profilePicture)
│   │   └── travel_story.dart                   # TravelStory model
│   ├── services/
│   │   ├── api_service.dart                    # All REST API calls
│   │   ├── token_storage.dart                  # JWT token storage (mobile)
│   │   └── token_storage_web.dart              # JWT token storage (web)
│   ├── providers/
│   │   ├── auth_provider.dart                  # Auth state (login/signup/logout/profile)
│   │   ├── story_provider.dart                 # Stories state (CRUD + activity stats)
│   │   └── theme_provider.dart                 # Dark/light theme state
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart               # Login screen
│   │   │   ├── signup_screen.dart              # Signup screen
│   │   │   ├── forgot_password_screen.dart     # Forgot password (OTP flow)
│   │   │   ├── otp_verification_screen.dart    # OTP entry screen
│   │   │   └── reset_password_screen.dart      # Reset password screen
│   │   ├── home/
│   │   │   └── home_screen.dart                # Home (story grid + search)
│   │   ├── profile/
│   │   │   └── profile_sidebar.dart            # Profile sidebar drawer
│   │   └── story/
│   │       ├── add_edit_story_screen.dart      # Add / Edit story
│   │       └── view_story_screen.dart          # View full story + media gallery
│   ├── widgets/
│   │   └── story_card.dart                     # Reusable story card widget
│   └── utils/
│       ├── constants.dart                      # API base URL config
│       └── theme.dart                          # App colors & light/dark theme
│
├── backend/                                    # Node.js backend
│   ├── controllers/
│   │   ├── auth.controller.js                  # signup, signin, OTP forgot/reset password
│   │   ├── travelStory.controller.js           # Story CRUD + media upload
│   │   └── user.controller.js                  # Profile, password, picture update
│   ├── models/
│   │   ├── user.model.js                       # User schema (otp, resetToken, profilePicture)
│   │   └── travelStory.model.js                # TravelStory schema
│   ├── routes/
│   │   ├── auth.route.js                       # /api/auth/*
│   │   ├── user.route.js                       # /api/user/*
│   │   └── travelStory.route.js                # /api/travelStory/*
│   ├── utils/
│   │   ├── verifyUser.js                       # JWT middleware
│   │   ├── error.js                            # Error handler
│   │   └── sendEmail.js                        # Resend (production) / Nodemailer (local)
│   ├── multer.js                               # Cloudinary storage config
│   └── index.js                                # Express app entry point
│
├── android/                                    # Android config
├── assets/
│   └── logo.png                                # App launcher icon
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

---

## Features

| Feature | Status |
|---|---|
| User Signup / Login / Logout | Done |
| Auto-login (JWT token persistence) | Done |
| Forgot Password via OTP | Done |
| OTP Verification | Done |
| Reset Password | Done |
| Profile Sidebar | Done |
| Edit Username / Email / Password | Done |
| Profile Picture Upload (Cloudinary) | Done |
| Dark / Light Mode Toggle | Done |
| Activity Stats (Created, Deleted, Edited, Liked) | Done |
| View all travel stories (staggered grid) | Done |
| Add new travel story | Done |
| Edit existing story | Done |
| Delete story | Done |
| Toggle favorite | Done |
| Search stories by title/content | Done |
| Filter stories by date range | Done |
| Multiple image upload (Cloudinary) | Done |
| Video upload (Cloudinary, max 30s recommended) | Done |
| Location search (OpenStreetMap Nominatim) | Done |
| Story detail view with swipeable media gallery | Done |
| Video player in story view (Chewie) | Done |
| Pull to refresh | Done |
| Flutter Web support | Done |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Android + Web) |
| Backend | Node.js, Express.js v5 |
| Database | MongoDB (Mongoose) |
| Cloud Storage | Cloudinary (images + videos) |
| Authentication | JWT (cookie + Authorization header) |
| Email (Production) | Resend API |
| Email (Local Dev) | Nodemailer (Gmail App Password) |
| Location Search | OpenStreetMap Nominatim API |
| Deployment | Render (free tier) |
| Uptime Monitoring | UptimeRobot |

---

## API Endpoints

### Auth
```
POST   /api/auth/signup
POST   /api/auth/signin
POST   /api/auth/forgot-password
POST   /api/auth/verify-otp
POST   /api/auth/reset-password
```

### User
```
POST   /api/user/signout
GET    /api/user/getusers
PUT    /api/user/update-profile
PUT    /api/user/update-password
POST   /api/user/update-profile-picture
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

## Setup Instructions

### Prerequisites
- Flutter SDK
- Node.js
- MongoDB Atlas account
- Cloudinary account
- Resend account (for production email)
- Gmail account + App Password (for local email)

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
RESEND_API_KEY=your_resend_api_key
```

`EMAIL_USER` and `EMAIL_PASS` are used for local development only. In production, `RESEND_API_KEY` is used automatically when present.

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
# Flutter Web (local dev)
flutter run -d chrome --web-port=8080

# Android APK
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

---

## Dependencies

### Flutter
| Package | Purpose |
|---|---|
| `provider` | State management |
| `http` | HTTP requests |
| `dio` | Primary HTTP client (IPv4 forced for Android) |
| `shared_preferences` | JWT token storage (mobile) |
| `image_picker` | Pick images from gallery |
| `file_picker` | Pick files on web |
| `video_player` | Video playback |
| `chewie` | Video player UI |
| `cached_network_image` | Efficient image loading |
| `flutter_staggered_grid_view` | Story grid layout |
| `intl` | Date formatting |
| `fluttertoast` | Toast notifications |
| `flutter_launcher_icons` | Custom app launcher icon |
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
| `resend` | Production email delivery |
| `nodemailer` | Local development email |
| `dotenv` | Environment variables |
| `cookie-parser` | Cookie handling |
| `cors` | Cross-origin requests |
| `nodemon` | Dev auto-restart |

---

## Notes

- JWT token is stored in `SharedPreferences` on mobile and `localStorage` on web.
- `verifyUser.js` supports both cookie and `Authorization: Bearer <token>` header.
- Cloudinary `resource_type` is auto-detected — both images and videos are supported.
- In production, `RESEND_API_KEY` is used for email. Locally, Gmail SMTP via Nodemailer is used.
- Server uptime is maintained via UptimeRobot monitoring (pings every 5 minutes).
- `dio` is used instead of `http` on Android to force IPv4 connections.

 
# 🚀 Flutter Setup & Run Guide

This guide explains how to install Flutter, set up your environment, and run the project on Android, iOS, or Web.

---

## ✅ 1. Install Flutter

Download Flutter SDK:

➡ https://flutter.dev/docs/get-started/install

Choose your operating system:

### **Windows**
1. Download Flutter ZIP  
2. Extract to: `C:\src\flutter`
3. Add to PATH:
   - Press **Win + R**, type `SystemPropertiesAdvanced`
   - Click **Environment Variables**
   - Edit **Path**
   - Add: `C:\src\flutter\bin`

### **macOS**
```bash
brew install --cask flutter


## Quick Start

### 1. Clone and Install

```bash
git clone https://github.com/yourusername/rent_a_home.git
cd rent_a_home
flutter pub get
```

### 2. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable these services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Messaging

3. Add Firebase to your app:
   - **Android**: Download `google-services.json` and place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and place in `ios/Runner/`
   - **Web**: Update `lib/firebase_options.dart` with your config

4. Deploy storage rules:
```bash
firebase deploy --only storage
```

5. Configure CORS (for web):
```powershell
.\setup_firebase_storage.ps1
```

### 3. Run the App

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

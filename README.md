# Routine - AI-Powered Nutrition Tracking

A beautiful iOS app for tracking meals, calories, and water intake with AI food recognition.

## Features

- **Sign in with Apple** - Secure authentication
- **AI Food Recognition** - Scan meals with your camera
- **Real-time Sync** - Data syncs across all your devices
- **Nutrition Tracking** - Calories, protein, carbs, and fat
- **Water Intake** - Track daily hydration
- **Meal Photos** - Visual food diary

## Tech Stack

- **SwiftUI** - Modern declarative UI
- **Firebase** - Backend services
  - Authentication (Sign in with Apple)
  - Firestore (Real-time database)
  - Storage (Food photos)
  - Analytics & Crashlytics
- **MVVM Architecture** - Clean separation of concerns

## Firebase Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "Routine" (or your preferred name)
4. Follow the setup wizard

### 2. Register iOS App

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.yourcompany.Routine` (or your actual bundle ID)
3. Download `GoogleService-Info.plist`
4. Add the file to your Xcode project (drag into Routine/ folder)
5. Make sure "Copy items if needed" is checked

**Note:** `GoogleService-Info.plist` is gitignored for security. A template is available at `GoogleService-Info.plist.template` for reference.

### 3. Add Firebase SDK via Swift Package Manager

1. In Xcode: File → Add Package Dependencies
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Click "Add Package"
4. Select these products:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseFirestoreSwift
   - FirebaseStorage
   - FirebaseAnalytics
   - FirebaseCrashlytics

### 4. Enable Sign in with Apple

**In Firebase Console:**
1. Go to Authentication → Sign-in method
2. Enable "Apple" provider
3. Add your Apple Developer Team ID
4. Configure Service ID and Key (from Apple Developer portal)

**In Xcode:**
1. Select project → Signing & Capabilities
2. Click "+ Capability"
3. Add "Sign in with Apple"

**In Apple Developer Portal:**
1. Go to Certificates, Identifiers & Profiles
2. Create a Service ID for Sign in with Apple
3. Configure return URL: `https://routine-xxxxx.firebaseapp.com/__/auth/handler`
4. Create and download private key

### 5. Set Up Firestore Database

1. In Firebase Console, go to Firestore Database
2. Click "Create database"
3. Start in **Test mode** (for development)
4. Choose a location

**Security Rules** (for production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /foodEntries/{entryId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    match /waterEntries/{entryId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 6. Set Up Firebase Storage

1. In Firebase Console, go to Storage
2. Click "Get started"
3. Start in **Test mode** (for development)

**Security Rules** (for production):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{userId}/food/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 7. Uncomment Firebase Code

Once Firebase SDK is added, uncomment the Firebase imports and code in:

**Routine/RoutineApp.swift:**
```swift
import FirebaseCore

// In init():
FirebaseApp.configure()
```

## Security Notes

- `GoogleService-Info.plist` is **gitignored** and should never be committed to public repositories
- This file contains your Firebase project configuration and API keys
- While the API key in this file is a public identifier (not a secret), it's best practice to keep it private
- Firebase security comes from **Security Rules** in Firestore and Storage, not from hiding this file
- For production apps, configure Security Rules to restrict access to authenticated users only (examples provided above)

**Routine/Services/FirebaseManager.swift:**
- Uncomment the Firebase implementation
- Remove the stub class

**Routine/Services/AuthService.swift:**
- Uncomment the Firebase Auth implementation
- Remove the stub class

**Routine/Services/FirestoreService.swift:**
- Replace stub methods with actual Firestore calls

**Routine/Services/StorageService.swift:**
- Replace stub methods with actual Storage calls

## Project Structure

```
Routine/
├── RoutineApp.swift
├── ContentView.swift
├── Models/
│   ├── User.swift
│   ├── FoodEntry.swift
│   ├── WaterEntry.swift
│   └── DailySummary.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── FoodLogViewModel.swift
│   └── WaterViewModel.swift
├── Views/
│   └── Auth/
│       └── LoginView.swift
├── Services/
│   ├── FirebaseManager.swift
│   ├── AuthService.swift
│   ├── FirestoreService.swift
│   ├── StorageService.swift
│   └── FoodRecognitionService.swift
└── GoogleService-Info.plist (you add this)
```

## Running the App

### Without Firebase (Demo Mode)
The app runs with mock data for UI development and testing.

### With Firebase (Full Features)
1. Complete all setup steps above
2. Uncomment Firebase code
3. Build and run on device or simulator
4. Sign in with Apple (requires physical device for full test)

## Food Recognition Options

The app includes a mock AI food recognition service. For production, integrate one of:

1. **Firebase ML Kit** - On-device image labeling
2. **Google Cloud Vision API** - Via Firebase Functions
3. **Edamam Food Database** - Nutrition data API
4. **Nutritionix API** - Food database with NLP
5. **Clarifai** - Food recognition API

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Developer Account (for Sign in with Apple)

## License

MIT License - feel free to use this project as a starting point for your own apps.

## Support

For issues with:
- **Firebase Setup**: Check Firebase documentation
- **Sign in with Apple**: Verify Apple Developer configuration
- **App Code**: Open an issue on GitHub

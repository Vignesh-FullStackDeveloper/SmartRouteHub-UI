# Setup Instructions

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- Google Maps API Key

## Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Google Maps:**
   
   **Android:**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key
   
   **iOS:**
   - Open `ios/Runner/AppDelegate.swift`
   - Add your Google Maps API key in the configuration
   
   **Web:**
   - Open `web/index.html`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key

3. **Firebase Setup (Optional for notifications):**
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase in your project

4. **Run the app:**
   ```bash
   flutter run
   ```

## Testing the App

### Admin Login
- Use any organization code (e.g., "GHS001" or "SES002")
- Email/Phone: any value
- Password: any value (6+ characters)
- Click "Login as Admin"

### Driver Login
- Select or enter organization code
- Enter phone number
- Click "Send OTP"
- Enter OTP: `123456` (dummy OTP)
- Click "Login as Driver"

### Parent Login
- Select or enter organization code
- Choose Phone + OTP or Email + Password
- For OTP: Use `123456`
- For Password: any value (6+ characters)
- Click "Login as Parent"

## Project Structure

See individual README files in each module folder for detailed documentation:
- `lib/core/README.md`
- `lib/models/README.md`
- `lib/services/README.md`
- `lib/blocs/README.md`
- `lib/widgets/README.md`
- `lib/ui/README.md`

## Notes

- All services use mock/dummy data
- No backend connection required
- Google Maps will show default location if API key is not configured
- Firebase notifications are placeholder implementations


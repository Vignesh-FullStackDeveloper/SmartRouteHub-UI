# Google Maps API Key Setup

## Current Status
⚠️ **Warning**: The app is currently running with a placeholder Google Maps API key. Maps will show a warning but the app will still function.

## To Enable Google Maps:

### Step 1: Get Your API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Maps JavaScript API**:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Maps JavaScript API"
   - Click "Enable"

4. Create credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy your API key

### Step 2: Configure the API Key

#### For Web (Chrome/Web):
1. Open `web/index.html`
2. Find this line:
   ```html
   var googleMapsApiKey = "YOUR_GOOGLE_MAPS_API_KEY";
   ```
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:
   ```html
   var googleMapsApiKey = "AIzaSyYourActualKeyHere";
   ```

#### For Android:
1. Open `android/app/src/main/AndroidManifest.xml`
2. Find the `meta-data` tag with `android:name="com.google.android.geo.API_KEY"`
3. Replace the value with your API key

#### For iOS:
1. Open `ios/Runner/AppDelegate.swift` (or `.m` file)
2. Add your API key in the appropriate location

### Step 3: Restart the App
After adding your API key, restart the Flutter app:
```bash
flutter run -d chrome
```

## Important Notes:
- **Free Tier**: Google Maps API has a free tier with $200 credit per month
- **Restrictions**: You can restrict your API key to specific domains/APIs for security
- **Testing**: For development, you can use the app without a key, but maps won't display

## Current Behavior:
- ✅ App runs normally
- ✅ All features work except map display
- ⚠️ Console shows "InvalidKey" warning (this is expected)
- ⚠️ Maps will not load until a valid key is added

## Need Help?
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Get API Key Guide](https://developers.google.com/maps/documentation/javascript/get-api-key)


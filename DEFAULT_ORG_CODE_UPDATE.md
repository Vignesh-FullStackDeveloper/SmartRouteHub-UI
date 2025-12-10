# Default Organization Code Updated ✅

## Changes Made

### 1. **AppConstants** ✅
- Added `defaultOrganizationCode = '009'` constant
- Centralized default organization code configuration

### 2. **Login Screen** ✅
- Updated to use `AppConstants.defaultOrganizationCode` instead of hardcoded 'org_1'
- Default organization code field now shows '009'
- Updated dummy credentials hint to show correct org code

## Configuration

The default organization code is now set in:
```dart
lib/core/constants/app_constants.dart

static const String defaultOrganizationCode = '009';
```

## Usage

The login screen will now:
- Pre-fill organization code with '009'
- Use '009' as default when no organization is selected
- Show '009' in the dummy credentials hint

## To Change Default Organization Code

Simply update the constant in `app_constants.dart`:
```dart
static const String defaultOrganizationCode = 'YOUR_CODE';
```

All references will automatically use the new value.


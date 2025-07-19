# App Icon Setup for MULI11 Calculator

## Steps to Add Your Custom App Icon

### 1. Prepare Your Icon Image
- Save your app icon image as `app_icon.png` in the `assets/` folder
- Make sure it's at least 1024x1024 pixels
- Use PNG format for best quality
- The image should be square and have transparent or solid background

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate App Icons
```bash
flutter pub run flutter_launcher_icons:main
```

### 4. Update App Name (Optional)
To change the app name from "multi_calculator" to "MULI11 Calculator":

#### For Android:
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="MULI11 Calculator"
    ...
>
```

#### For iOS:
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>MULI11 Calculator</string>
```

### 5. Build and Test
```bash
flutter clean
flutter pub get
flutter run
```

## Icon Design Description
Your icon should represent the four calculator functions:
- **Top-Left (Blue)**: Mathematical symbols (+, -, ×, %)
- **Top-Right (Red)**: Calendar icon for age calculator
- **Bottom-Left (Teal/Green)**: Data storage/device icon for data converter
- **Bottom-Right (Orange)**: Roman numeral "XII" → "12" for numeral converter

## File Structure
```
assets/
  └── app_icon.png  (Your custom icon here)
flutter_launcher_icons.yaml  (Configuration file)
pubspec.yaml  (Updated with dependencies)
```

## Troubleshooting
- If icons don't update, try: `flutter clean && flutter pub get`
- Make sure the image path in `flutter_launcher_icons.yaml` is correct
- Ensure the image is high resolution (1024x1024 or larger) 
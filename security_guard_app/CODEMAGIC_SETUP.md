# Codemagic iOS Build Setup Guide

## Overview
Codemagic allows you to build iOS apps without owning a Mac. It provides macOS cloud machines to compile your Flutter app.

## Step 1: Sign Up for Codemagic

1. Go to https://codemagic.io/
2. Click "Sign up for free"
3. Sign up with your GitHub account
4. Free tier includes: 500 build minutes/month

## Step 2: Connect Your Repository

1. In Codemagic dashboard, click "Add application"
2. Select "GitHub" as your git provider
3. Choose your repository: `guardcore-api`
4. Select the branch: `main`

## Step 3: Select Flutter Project

1. Codemagic will detect your Flutter project
2. Select `security_guard_app` as the project root
3. Click "Finish: Add application"

## Step 4: Configure iOS Build (Two Options)

### Option A: Simple Debug Build (No Apple Developer Account Needed)
**Use the `ios-debug` workflow** - This builds the app but doesn't sign it. Good for testing build success.

1. In your app settings, go to "Start new build"
2. Select workflow: `ios-debug`
3. Click "Start new build"
4. Wait 10-15 minutes for the build

### Option B: Release Build with App Store Distribution (Requires Apple Developer Account)
**Use the `ios-release` workflow** - This creates a signed .ipa file ready for App Store.

**Requirements:**
- Apple Developer Account ($99/year)
- App Store Connect API Key

**Setup Steps:**

#### 4.1 Create App Store Connect API Key
1. Go to https://appstoreconnect.apple.com
2. Navigate to Users and Access > Keys
3. Click "+" to create a new key
4. Give it a name: "Codemagic Build"
5. Download the `.p8` file
6. Note down:
   - Issuer ID
   - Key ID
   - Keep the .p8 file content

#### 4.2 Add Credentials to Codemagic
1. In Codemagic, go to your app settings
2. Navigate to "Environment variables"
3. Add these variables as **secure** (encrypted):
   - `APP_STORE_CONNECT_ISSUER_ID` = Your Issuer ID
   - `APP_STORE_CONNECT_KEY_IDENTIFIER` = Your Key ID
   - `APP_STORE_CONNECT_PRIVATE_KEY` = Paste .p8 file content
   - `CERTIFICATE_PRIVATE_KEY` = (Leave empty for now, Codemagic auto-generates)

#### 4.3 Register Your App in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" > "+" > "New App"
3. Fill in:
   - Platform: iOS
   - Name: GuardCore Security
   - Primary Language: English
   - Bundle ID: Create new (e.g., `com.guardcore.securityapp`)
   - SKU: GUARDCORE001

#### 4.4 Update Flutter App Bundle ID
1. Open `security_guard_app/ios/Runner.xcodeproj/project.pbxproj`
2. Or easier: Edit `security_guard_app/ios/Runner/Info.plist`
3. Match the Bundle ID with what you created in App Store Connect

#### 4.5 Start iOS Release Build
1. In Codemagic, click "Start new build"
2. Select workflow: `ios-release`
3. Click "Start new build"
4. Wait 15-20 minutes

## Step 5: Configure Android Build (Already Working)

Your Android build already works locally. To automate it on Codemagic:

### 5.1 Upload Keystore to Codemagic
1. Find your keystore file: `security_guard_app/android/app/upload-keystore.jks`
2. In Codemagic, go to "Code signing identities" > "Android"
3. Upload your keystore file
4. Enter:
   - Keystore alias: `upload`
   - Keystore password: (from key.properties)
   - Key password: (from key.properties)
5. Save as: `guardcore_keystore`

### 5.2 Run Android Build
1. Click "Start new build"
2. Select workflow: `android-release`
3. This will generate both APK and AAB files

## Step 6: Download & Test Your Builds

After successful build:
1. Go to "Builds" tab
2. Click on the completed build
3. Download artifacts:
   - iOS: `.ipa` file (install via TestFlight or Xcode)
   - Android: `.apk` or `.aab` file

## Recommended Workflow for Free Tier

Since you have 500 minutes/month:
- Use `ios-debug` workflow first to test (5-10 minutes)
- Only use `ios-release` when ready to publish (longer build time)
- Android builds are faster (5-7 minutes)

## Build on Every Push (CI/CD)

To auto-build when you push to GitHub:
1. In app settings, go to "Build triggers"
2. Enable "Trigger on push"
3. Select branch: `main`
4. Select workflow: `ios-debug` or `android-release`

Now every `git push` will trigger a build!

## Troubleshooting

### Build Fails: "No such file 'Podfile'"
- The Podfile is in `ios/` folder
- Make sure project root is set to `security_guard_app/`

### Build Fails: "Code signing error"
- Check your App Store Connect API credentials
- Verify Bundle ID matches between Xcode and App Store Connect
- Ensure you have an active Apple Developer membership

### Build Timeout
- Free tier has 60 min max per build
- iOS builds usually take 15-20 minutes
- Upgrade to paid plan if needed

## Cost

**Free Tier:**
- 500 build minutes/month
- ~25 iOS builds OR ~60 Android builds
- Perfect for development

**Paid Tier:**
- $95/month for unlimited builds
- Faster machines (M1 Mac)
- Priority build queue

## Next Steps After Setup

1. Start with `ios-debug` workflow to verify your project builds
2. If successful, proceed to create Apple Developer account
3. Set up `ios-release` workflow for App Store builds
4. Enable auto-build on push for continuous integration

## Support

- Codemagic Docs: https://docs.codemagic.io/
- Flutter iOS Setup: https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
- Slack Support: https://codemagic.io/slack

---

**Ready to start?** Just visit https://codemagic.io and sign up!

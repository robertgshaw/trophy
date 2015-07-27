Trophy
======

A mobile app for sharing interesting photos with private groups.

======
### Setup Instructions:

1. Create a local copy of the Trophy repo
   ```
   git clone https://github.com/JakeFromTrophy/TrophyApp.git
   ```

2. Install cocoapods (http://guides.cocoapods.org/using/getting-started.html)
   ```
   cd trophy && sudo gem install cocoapods
   ```

3. Install the pod files required by **Podfile**
   ```
   pod install
   ```

4. Download the Parse frameworks and into a subfolder in the project folder, **[LOCAL_REPO]/Parse**. You should be adding five frameworks:
   - Bolts.framework
   - Parse.framework
   - ParseCrashReporting.framework
   - ParseFacebookUtils.framework
   - ParseUI.framework
   
   You can find the frameworks here: https://parse.com/apps/quickstart#parse_data/mobile/ios/native/existing

5. Open the **Trophy.xcworkspace** file in Xcode. Build and run!
# TrophyApp

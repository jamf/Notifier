Copyright 2020 DATA JAR LTD

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

# Notifier
NOTIFIER.PNG

Notifier is a Swift app which can post macOS alert or banner notifications on 10.10+ clients.

On macOS 10.10-10.14 the depreceated [NSUserNotifications](https://developer.apple.com/documentation/foundation/nsusernotification) API is used, for 10.15+ the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications) are used.

This project was originally intened for use with [jamJAR](https://github.com/dataJAR/jamJAR)

# Usage
## Basic Usage
```
-$ ./Notifier.app/Contents/MacOS/Notifier 
OVERVIEW: Notifier: Sends banner or alert notifications.

USAGE: notifier --type <alert/banner> --message <some message> <options>

OPTIONS:
  --message               message text - REQUIRED if not passing --remove all
  --messageaction         The action to be performed when the message is clicked. Either pass 'logout' or path to item to open on click. Can be a .app, file, URL etc. With non-.app items being opened in their default handler
  --messagebutton         alert type only. Sets the message buttons text
  --messagebuttonaction   alert type only. The action to be performed when the message button is clicked. Either pass 'logout' or path to item to open on click. Can be a .app, file, URL etc. With non-.app items being opened in their default handler. Requires '--messagebutton' to be passed
  --remove                "prior" or "all". If passing "prior", the full message will be required too. Including all passed flags
  --sound                 sound to play. Pass "default" for the default macOS sound, else the name of a sound in /Library/Sounds or /System/Library/Sounds. If the sound cannot be found, macOS will use the "default" sound
  --subtitle              message subtitle
  --title                 message title
  --type                  alert or banner - REQUIRED
  --verbose               Enables logging of actions. Check console for  'Notifier Log:' messages
  --help                  Display available options

SEE ALSO: https://github.com/dataJAR/Notifier
```

## Example Usage


# Deployment

## PKG

## macOS 10.15+

# How it works

# Rebranding
If you find the Notifier logo to garish &/or want to rename the notifications as they show in Notification Centre, then you can follow the below rebrand guidelines. 

`NOTE: It's likely that these will change regularly, PR's accepted to correct &/or clarify any of the below or any or this README.`

### Requirements
1. Apple Xcode
2. A macOS developer account signed into Xcode
3. A copy of this project downloaded, & the Notifier.xcodeproj file loaded into Xcode

### Re-signing
Notifier is made up of 3 applications, the enclosing Notifier.app & the sub apps with one used to post Alert notifications & another Banner notifications.

As such, all three will need to be re-signed with your developer cerificate & it worth making sure this is all compileable before proceeding.

See [this guide](https://help.apple.com/xcode/mac/current/#/dev23aab79b4), for where to change the signing identity per app.

Those steps will need to be repeated for each of the 3 apps, & they are highlighted in the Xcode screenshot below:

APPS-HIGHLIGHTED

### Renaming
The name which is shown within Notification Centre is the name of the applications themselves capitalised, so to change them follow the below. This will need tp be repeated for both the Alert & Banner applications.

1. Select the app that you're looking to rename in Xcodes project navigator. RENAME1
2. Slowly double click, or press enter to make the field editable & change the name as needed, presssing enter when done. RENAME2
3. Approve the changes in the drop down. RENAME3
4. Click the disclosure triangle need to the app target you renamed above, change the folder name to the same as the application name. RENAME4
5. Repeat steps 2-4 for the other application as wanted, note: you cannot name both applications the same. RENAME5
6. With the applications renamed, from Xcodes menubar click "Projects" > "Schemes" > "Manage Schemes" RENAME6
7. For each renamed app, select the scheme & rename. RENAME7
8. Repeat 7 until all the renamed apps have had their schemes renamed. RENAME8
9. With the apps renamed, we need to add them back to the main Notifier.app. Click the Notifier target in Xcodes project navigator, then in Xcodes project editor click "Build Phases" & expand "Dependencies". If you renamed both the Alert & Banner applications then this will be empty, if you've renamed just one then that will be missing only. RENAME9
10. Click the + button, select the missing renamed Alert & Banner applications as required & click "Add". RENAME1O
11. Still within the "Build Phases" tab of the main Notifier.app scroll down to the "Copy Files" steps, this will be empty where the Alert or Banner application was renamed earlier. RENAME11
12. Click the + button to add the wanted application, it's important that you pay attention to the "subpath" value. As one is called "alerts" & is for the Alert application, the other "banner" & is for the Banner application. RENAME12
13. Now build the project to test, if the build fails please review the above & attempt again.

### Changing Icons
The application icons for the Alert & Banner applications can be changed to fit with your requirements. 

At a minimum, you'll need a PNG of 1024 x 1024 for this.

But if you'd like to supply all the sizes offered, then you'll want PNG's in the below sizes:

• 1024 x 1024

• 512 x 512

• 256 x 256

• 128 x 128

• 64 x 64

• 32 x 32

• 16 x 16

Below is the process, 
1. Select the application that you're looking to change the icon in Xcodes project navigator, click the disclosure triangle for the application, click the sub folder, click "Assets.xcassets" & lastly click "AppIcon". ICON1
2. Either replace each icon with icons of the correct size (a :warning: will be shown if the wrong size PNG is supplied), or delete all & just supply the last "AppStore -2x" ICON2
3. Repeat for which of the Alert or Banner applications are to have their icons changed, the main Notifier.app icon doesn't need to be changed as will not be shown to customers when notifications are posted. But could be changed as per the above too if wanted.
4. Now build the project to test, if the build fails please review the above & attempt again.
5. If you now test your new icons on a macOS device on which Notifier has run before, you'll likely see the previous icon. So tes in a VM or try to [reset Notification Centre](https://stackoverflow.com/questions/11856766/osx-notification-center-icon). 


# FAQS
##
**Q1:** Why start at version 2?

**A1:** At dataJAR, we already had a v1 "Notifier" app deployed.
##
**Q2:** How can you post both banner & alert notifications?

**A2:** The 
##
**Q3:** How can you post both banner & alert notifications?

**A3:** Banner or Notifications?


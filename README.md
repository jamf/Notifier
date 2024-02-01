Copyright 2024 DATA JAR LTD

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

# Notifier
<p align="center"><img width="256" alt="Alert" src="https://github.com/dataJAR/Notifier/assets/2464974/d8d2cca1-250c-4601-a1d5-1fea2330ba14">

Notifier is a Swift app which can post alert or banner notifications on macOS 10.15+ clients.

Notifications are delivered via the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)

This project was originally intended for use with [jamJAR](https://github.com/dataJAR/jamJAR)

# Usage
## Basic Usage
```
./Notifier.app/Contents/MacOS/Notifier
OVERVIEW: Notifier 3.0: Posts alert or banner notifications.

USAGE: --type <alert/banner> --message <some message> <options>
       --type <alert/banner> --remove prior <some message> <options>
       --type <alert/banner> --remove all
       --rebrand <path to image>

OPTIONS:
  --type <type>           alert or banner - REQUIRED.

  --message <message>     The notifications message.

  --messageaction <messageaction>
                          The action to be performed under the users account
                          when the message is clicked.

                          • Passing 'logout' will prompt the user to logout.
                          • If passed a single item, this will be launched via:
                          /usr/bin/open
                          • More complex commands can be passed, but the 1st
                          argument needs to be a binaries path.

                          For example: "/usr/bin/open" will work, "open" will
                          not.

  --sound <sound>         sound to play when notification is delivered. Pass
                          "default" for the default macOS sound, else the name
                          of a sound in /Library/Sounds or
                          /System/Library/Sounds.

                          If the sound cannot be found, macOS will use the
                          "default" sound.

  --subtitle <subtitle>   The notifications subtitle.

  --title <title>         The notifications title.

  --messagebutton <messagebutton>
                          alert type only.

                          Adds a button to the message, with the label being
                          what is passed.

  --messagebuttonaction <messagebuttonaction>
                          alert type only.

                          The action to be performed under the users account
                          when the optional message button is clicked.

                          • Passing 'logout' will prompt the user to logout.
                          • If passed a single item, this will be launched via:
                          /usr/bin/open
                          • More complex commands can be passed, but the 1st
                          argument needs to be a binaries path.

                          For example: "/usr/bin/open" will work, "open" will
                          not.

  --rebrand <rebrand>     Requires root privileges.

                          Rebrands Notifier using the image passed.

  --remove <remove>       "prior" or "all". If passing "prior", the full
                          message will be required too. Including all passed
                          flags.

  --verbose               Enables logging of actions. Check console for 
                          'Notifier' messages.

  --help                  Show help information.
```

When looking at the above, --messagebutton & --messagebuttonaction refer to the button for Alert notifications as shown in the green box.

Other verbs apply to the main message area, the red box.
<p align="center"><img width="370" alt="Alert" src="https://github.com/dataJAR/Notifier/assets/2464974/cd9525be-358d-4eb7-b60b-3c22c6cf9d14">

## Example Usage
**Example 1** This example shows a basic banner notification.
<p align="center"><src="https://github.com/dataJAR/Notifier/assets/2464974/ac6b777c-ee47-4bc2-b7a5-7953e75fced7">

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message"`
##
**Example 2** This example shows a basic alert notification.
<p align="center"><img src="/../assets/images/Example3.gif"></p>


`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message" --messagebutton "Logout" --messagebuttonaction "Logout"`
##
**Example 3** This example shows both alert & banner notifications, (sleep used for the example gif, not needed in use but below for completeness sake).
<p align="center"><img src="/../assets/images/Example6.gif"></p>


`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "Please Logout" --messagebutton "Logout"  --title "Logout"`

`sleep 2`

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message" --title "Notification ;)"`
##
**Example 4** This example shows removal of a prior notification, (sleep used for the example gif, not needed in use but below for completeness sake).

<p align="center"><img src="/../assets/images/Example5.gif"></p>

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message 'Look at me!!'`

`sleep 5` 

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message" --messagebutton "Logout"`

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message 'Look at me!!' --remove prior`
##
**Example 5** This example shows removal of all alert notifications, for banner alerts this will remove from Notification Center. Sleep used for the example gif, not needed in use but below for completeness sake.
<p align="center"><img src="/../assets/images/Example7.gif"></p>

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message" --messagebutton "Logout"`

`sleep 2`

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message2" --messagebutton "Logout"`

`sleep 2`

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message3" --messagebutton "Logout"` 

`/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --remove all`

# Deployment

## PKG
PKG's will be supplied for every release, & can be found in the [releases](https://github.com/dataJAR/Notifier/releases) section

This will place the Notifier.app within /Applications/Utilities/, removing /Applications/Utilities/Notifier.app if found prior.

## macOS 10.15+
If running Notifier on macOS 10.15+, you'll want to deploy the supplied profile (https://github.com/dataJAR/Notifier/blob/master/profile/Allow%20Notifier%20Notifications.mobileconfig) to UAMDM devices.

This will allow Notifier to post Notifications without prompting the user to allow & needs to be deployed when a device is running 10.15+ & not before.

# How it works
When using the deprecated [NSUserNotifications API](https://developer.apple.com/documentation/foundation/nsusernotification), the notification type (alert or banner), is defined by the [NSUserNotificationAlertStyle](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) key in the Applications info.plist.

For the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications), the user can choose the notification type or an admin can define this in a [profile](#macos-10.15+).

Notifier follows the above rules, by actually being not one but three applications.

An enclosing Notifier.app & two sub apps, with one used to post Alert notifications & another Banner notifications. As per the below:

```
Notifier.app/Contents/Resources/
                               alert/Notifier - Alerts.app
                               banner/Notifier - Notifications.app
```

These sub applications contain code for both the [NSUserNotifications API](https://developer.apple.com/documentation/foundation/nsusernotification) & [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications), as well as the relevant [NSUserNotificationAlertStyle](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) key in the Applications info.plist for the [NSUserNotifications API](https://developer.apple.com/documentation/foundation/nsusernotification).

The apps themselves seamlessly transition between the [NSUserNotifications API](https://developer.apple.com/documentation/foundation/nsusernotification) when running on macOS 10.10-10.14, & the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications) when running on 10.15+ via the [@available declaration attribute](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html).

So why the Notifier.app?

This is to give a single app to call, the Notifier.app will also check the parsed args & then pass to the required sub application.

Notifier.app also checks tha Notification Center is running, & runs the sub apps in the user context. As well as having an enclosing Notifier.app allows for some of the rebrand options below without adjusting any code.

# Rebranding
If you find the Notifier logo too garish &/or want to rename the notifications as they show in Notification Center, then you can follow the below rebrand guidelines. 

`NOTE: It's likely that these will change regularly, PR's accepted to correct &/or clarify any of the below or any or this README.`

### Requirements
1. Apple Xcode
2. A macOS developer account signed into Xcode
3. A copy of this project downloaded, & the Notifier.xcodeproj file loaded into Xcode

### Re-signing
Notifier is made up of three applications, the enclosing Notifier.app & the sub apps with one used to post Alert notifications & another Banner notifications.

As such, all three will need to be re-signed with your developer certificate & it is worth making sure this is all compile-able before proceeding.

See [this guide](https://help.apple.com/xcode/mac/current/#/dev23aab79b4), for where to change the signing identity per app.

*(Note: You may also need to change the signing in "Build Settings" as well as "Signing and Capabilities" for each app.)*

Those steps will need to be repeated for each of the three apps, & they are highlighted in the Xcode screenshot below:

<p align="center"><img src="/../assets/images/Apps-Highlighted.png" height="400"></p>

### Renaming
The name which is shown within Notification Center is the name of the applications themselves capitalised, so to change them follow the below. This will need to be repeated for both the Alert & Banner applications.

1. Select the app that you're looking to rename in Xcode's project navigator. 
<p align="center"><img src="/../assets/images/Rename1.png" height="400"></p>
2. Slowly double click, or press enter to make the field editable & change the name as needed, presssing enter when done.
<p align="center"><img src="/../assets/images/Rename2.png" height="400"></p>
3. Approve the changes in the drop down.
<p align="center"><img src="/../assets/images/Rename3.png" height="400"></p>
4. Click the disclosure triangle next to the app target you renamed above, change the folder name to the same as the application name.
<p align="center"><img src="/../assets/images/Rename4.png" height="400"></p>
5. Repeat steps 2-4 for the other application as wanted, note: you cannot name both applications the same.
<p align="center"><img src="/../assets/images/Rename5.png" height="400"></p>
6. With the applications renamed, from Xcode's menubar click "Product" > "Schemes" > "Manage Schemes".
<p align="center"><img src="/../assets/images/Rename6.png" height="400"></p>
7. For each renamed app, select the scheme & rename.
<p align="center"><img src="/../assets/images/Rename7.png" height="400"></p>
8. Repeat 7 until all the renamed apps have had their schemes renamed.
<p align="center"><img src="/../assets/images/Rename8.png" height="400"></p>
9. With the apps renamed, we need to add them back to the main Notifier.app. Click the Notifier target in Xcode's project navigator, then in Xcode's project editor click "Build Phases" & expand "Dependencies". If you renamed both the Alert & Banner applications then this will be empty, if you've renamed just one then that will be missing only.
<p align="center"><img src="/../assets/images/Rename9.png" height="400"></p>
10. Click the + button, select the missing renamed Alert & Banner applications as required & click "Add".
<p align="center"><img src="/../assets/images/Rename10.png" height="400"></p>
11. Still within the "Build Phases" tab of the main Notifier.app scroll down to the "Copy Files" steps, this will be empty where the Alert or Banner application was renamed earlier.
<p align="center"><img src="/../assets/images/Rename11.png" height="400"></p>
12. Click the + button to add the wanted application, it's important that you pay attention to the "subpath" value. As one is called "alerts" & is for the Alert application, the other "banner" & is for the Banner application.
<p align="center"><img src="/../assets/images/Rename12.png" height="400"></p>
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
1. Select the application that you're looking to change the icon in Xcode's project navigator, click the disclosure triangle for the application, click the sub folder, click "Assets.xcassets" & lastly click "AppIcon".
<p align="center"><img src="/../assets/images/Icon1.png" height="400"></p>
2. Either replace each icon with icons of the correct size (a :warning: will be shown if the wrong size PNG is supplied), or delete all & just supply the last "AppStore -2x".
<p align="center"><img src="/../assets/images/Icon2.png" height="400"></p>
3. Repeat for which of the Alert or Banner applications are to have their icons changed, the main Notifier.app icon doesn't need to be changed as will not be shown to customers when notifications are posted. But could be changed as per the above too if wanted.<br />
4. Now build the project to test, if the build fails please review the above & attempt again.<br />
5. If you now test your new icons on a macOS device on which Notifier has run before, you'll likely see the previous icon. So test in a VM or try to reset Notification Center as per the Resetting Notifications Center steps below.

# Miscellaneous

## Resetting Notifications Center
The below _should_ rest Notifications Center, but please test & submit a PR with a better method as applicable.

1. `rm -rf $(getconf DARWIN_USER_DIR)/com.apple.notificationcenter/*`
2. Logout & then log back in, or:
* For macOS 10.16+: `killall "NotificationCenter"`
3. Test the Notifier once more

# FAQs

**Q1:** Why start at version 2?

**A1:** At dataJAR, we already had a v1 "Notifier" app deployed.
##
**Q2:** How can you post both banner & alert notifications?

**A2:** See [How it works](#how-it-works)
##
**Q3:** The users are being prompted to allow.. help!

**A3:** This can be due to a few things:

1. Was the notifications profile installed? If not, install.
1. Was the notifications profile installed when running macOS 10.10-10.14? If it was, re-install when running 10.15+.
1. Is the device under UAMDM? If not, check with your MDM vendor on making the device UAMDM. Then try again & maybe reinstall the profile once under UAMDM.
1. Did you change the Bundle ID of either the Alert or Banner applications? If so you'll need to amend the notifications profile accordingly.
##
**Q4:** Is that logo magen...

**A4:** No, it's a shade of pink...
##
**Q5:** Banner or Notifications?

**A5:** The temporary notifications are referred to as "banner" notifications in Apple's documentation, but it seems that most folks call them "Notifications" with the persistent notifications being referred to as alerts by folks as well as within Apple's documentation.
##
**Q6:** I'm seeing alerts when expecting banner notifications, & vice versa

**A6:** Check step 12 of [Renaming](#renaming), it's likely the wrong app is in the wrong folder.
##
**Q7:** --remove prior, didn't clear my last message.

**A7:** Make sure you pass EXACTLY the same message to be cleared.
##
**Q8:** I've rebranded, but the old icon is being shown..

**A8:** Please reset Notification Center as per the [Resetting Notifications Center](#resetting-notifications-center), then try again.
##
**Q9:** I'm struggling with rebranding &/or would like some changes for my organisation that are bespoke to us.

**A9:** We should be able to help, please visit our [website](https://datajar.co.uk) & fill out the contact form or join us in the [#datajar](https://macadmins.slack.com/archives/C016TM14R7A) channel on the [macadmins.org slack](https://macadmins.org) & we can arrange a quote as needed.
##
**Q10:** The [NSUserNotifications API](https://developer.apple.com/documentation/foundation/nsusernotification) was deprecated in 10.14, why not use the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications) for 10.14+ instead of 10.15+?

**A10:** Simply, macOS 10.14 didn't support managing the notification type via a [profile](#macos-10.15+), where 10.15+ does.
##
**Q11:** Some functionality is missing.. why is this?

**A11:** Notifier supports 10.10+, multiple API's & notification types. One of the main drivers was for consistency across the vast OS versions & differing API's, so if one API doesn't support a function.. it'll not be added to keep a consistent KISS approach.

# Alternatives
The below projects can be used instead of Notifier & were very much instrumental in Notifiers creation

## Alert Notifications
[Yo](https://github.com/sheagcraig/yo)

## Banner Notifications
[Terminal Notifier](https://github.com/julienXX/terminal-notifier)


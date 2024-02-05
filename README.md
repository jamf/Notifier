> Copyright 2024 DATA JAR LTD
>
>Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
>
>Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

# Notifier
<p align="center"><img width="256" alt="Alert" src="https://github.com/dataJAR/Notifier/assets/2464974/d8d2cca1-250c-4601-a1d5-1fea2330ba14">

Notifier is a Swift app which can post alert or banner notifications on macOS 10.15+ clients.

Notifications are delivered via the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)

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

## Example Usage
**Example 1** This example shows a basic banner notification.
<p align="center"><img width="370" alt="Alert" src=https://github.com/dataJAR/Notifier/assets/2464974/722ce659-c762-415a-8c33-8cc234ecc996">

```
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message"
```
##
**Example 2** This example shows a basic alert notification.
<p align="center"><img width="370" alt="Alert" src=https://github.com/dataJAR/Notifier/assets/2464974/2343c69f-a7f0-43a1-be6f-b655909004cc">

```
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message" --messagebutton "Logout" --messagebuttonaction "Logout"
```
##
**Example 3** This example shows both alert & banner notifications, (sleep used for the example gif, not needed in use but below for completeness sake).
<p align="center"><img width="370" alt="Alert" src=https://github.com/dataJAR/Notifier/assets/2464974/06b522b8-7ed8-4ee7-bc04-4676cc715bf0">

```
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "Please Logout" --messagebutton "Logout"  --title "Logout";
/bin/sleep 2;
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "👋" --title "Notification"
```
##
**Example 4** This example shows removal of all alert notifications, for banner alerts this will remove from Notification Center. Sleep used for the example gif, not needed in use but below for completeness sake.
<p align="center"><img width="370" alt="Alert" src=https://github.com/dataJAR/Notifier/assets/2464974/874dad84-0a1c-4145-8f93-df2ce4923762">

```
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message 'Look at me!!';
/bin/sleep 2; 
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message" --messagebutton "Logout";
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message 'Look at me!!' --remove prior
```
##
**Example 5** This example shows Notifier 3.0+'s `--rebrand` argument in use, this allows for rebranding of Notifier without having to venture into Xcode etc.
<p align="center"><img width="370" alt="Alert" src=https://github.com/dataJAR/Notifier/assets/2464974/bb6cf9c6-2dbd-4751-99a1-1a6a64c1fca1">

```
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type alert --message "message";
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message";
/bin/sleep 2;
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --rebrand /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ErasingIcon.icns;
/bin/sleep 2;
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message";
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --rebrand /System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/Contents/Resources/AppIcon.icns;
/bin/sleep 2;
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message";
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --rebrand /Applications/Utilities/Notifier.app/Contents/Resources/AppIcon.icns;
/bin/sleep 2;
/Applications/Utilities/Notifier.app/Contents/MacOS/Notifier --type banner --message "message"
```

# Deployment

## PPPC
It's recommended that the below profile is recommended to be deployed before Notfier itself. 
(https://github.com/dataJAR/Notifier/blob/master/profile/Allow%20Notifier%20Notifications.mobileconfig) to UAMDM devices.

This will allow Notifier to post Notifications without prompting the user to allow.

## PKG
PKG's will be supplied for every release, & can be found in the [releases](https://github.com/dataJAR/Notifier/releases) section


# How it works
The main Notifier.app parses arguments passed to it (via [Argument Parser](https://apple.github.io/swift-argument-parser/documentation/argumentparser/), and then posts the parsed argument to the two notifying applications included with the the /Contents/Helpers folder of Notifier.app:

```
/Applications/Utilities/Notifier.app/Contents/Helpers/
                                                      Notifier - Alerts.app
                                                      Notifier - Notifications.app
```
Additionally the Notifier.app also checks tha Notification Center is running, & runs the notifying apps in the user context.

The notifying apps (/Applications/Utilities/Notifier.app/Contents/Helpers/Notifier - Alerts.app and /Applications/Utilities/Notifier.app/Contents/Helpers/Notifier - Notifications.app) both post notifications via the [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications).

# Miscellaneous

## Resetting Notifications Center
The below _should_ reset Notifications Center, but please test & submit a PR with a better method as applicable.

1. `/bin/rm -rf $(getconf DARWIN_USER_DIR)/com.apple.notificationcenter/*`
2. Logout & then log back in, or:
* For macOS 10.15+: `/usr/bin/killall "NotificationCenter"`
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


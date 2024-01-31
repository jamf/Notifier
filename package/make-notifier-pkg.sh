#!/bin/bash
set -e

##########################################################################################
#
# In accessing and using this Product, you confirm that you accept the terms of our
# Product Licence in full and agree to comply with the terms of such Licence.
#
# https://datajar.co.uk/product-licence/
#
##########################################################################################
#
# CHANGE LOG
# 1.0 - Created
#
##########################################################################################
#

# This script creates Notifier-<version>.okg within this repos package dir.
#
# Needs to be ran as root/sudo, and requires the following arguments to be passed to it:
#
#   1 - Name of a "Developer ID Installer" identity within the running users keychain:
#       https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates/
#   2 - Name of an App-specific password within the running users keychain, to be used for notarization
#       https://support.apple.com/en-us/102654
#   3 - pkg receipt identifier
#
##########################################################################################
################################### Global Variables #####################################
##########################################################################################

# Extension of the script (.py, .sh etc)..
scriptExtension=${0##*.}

# Overall name of the family of software we are installing, with extension removed
swTitle="$(/usr/bin/basename "$0" ."$scriptExtension")"

# Script Version
ver="1.0"

# Full path to the dir this script is in
scriptDir="$(/usr/bin/dirname "$0")"

# Path to Notifier.app
notifierPath="${scriptDir}/ROOT/Applications/Utilities/Notifier.app"

# Developer ID Installer identity
developerIDInstaller="${1}"

# App specific password for notarization
appPassword="${2}"

# pkg identifier
pkgIdentifier="${3}"

##########################################################################################
#################################### Start functions #####################################
##########################################################################################

setup()
{
    # Make sure we're root
    if [ "$(id -u)" != "0" ]
    then
        /bin/echo "ERROR: This script must be run as root"
        exit 1
    fi

    # Make sure that there is a Notifier.app in the package folder
    if [ ! -e "${notifierPath}" ]
    then
        /bin/echo "ERROR: Notifier.app not found at: ${notifierPath}, exiting..."
        exit 1
    fi

    # Get the value of $1, error if doesn't exist
    if [ -z "${developerIDInstaller}" ]
    then
        /bin/echo "ERROR: no argument passed to script..."
        /bin/echo
        exit 1
    # If we have been passed an value to $1
    else
        # Make sure that we have a "Developer ID Installer: ${developerIDInstaller}" identity in the users keychain
        if [ -z "$(/usr/bin/security find-identity -v 'login.keychain' -s -p basic -s "Developer ID Installer: ${developerIDInstaller}" 2>&1 | /usr/bin/awk '/Developer ID Installer: ${developerIDInstaller}/{ print $0 }')" ]
        then
            # Error if we cannot find Developer ID Installer: ${developerIDInstaller} in the keychain
            /bin/echo "ERROR: no \"Developer ID Installer: Data JAR Ltd\" identity found in login.keychain, exiting..."
            exit 1
        fi
    fi

    # Get the value of $2, error if doesn't exist
    if [ -z "${appPassword}" ]
    then
        /bin/echo "ERROR: missing argument $2..."
        /bin/echo
        exit 1
    # If we have been passed an value to $2
    else
        # Make sure that $appPassword exists in the user keychain
        if [ -z "$(/usr/bin/security find-generic-password login.keychain -D "application password" -G "${appPassword}")" ]
        then
            # Error if we cannot find appPassword in the keychain
            /bin/echo "ERROR: password: ${appPassword} not found in login.keychain, exiting..."
            exit 1
        fi
    fi

    # Get the value of $3, error if doesn't exist
    if [ -z "${pkgIdentifier}" ]
    then
        /bin/echo "ERROR: missing argument $3..."
        /bin/echo
        exit 1
    fi
}


start()
{
    # Logging start
    /bin/echo "Running ${swTitle} ${ver}..."
}


finish()
{

    # Logging finish
    /bin/echo "Finished: $(/bin/date)"

}


getNotifierVersion()
{

    # Queries Notifier.app for version
    /bin/echo "Getting notifier version from ${notifierPath}/Contents/Info.plist..."
    notifierVersion=$(/usr/bin/defaults "${notifierPath}"/Contents/Info.plist CFBundleShortVersionString)
    /bin/echo "notifier version: ${notifierVersion}..."

}


getMinOSVersion()
{
    # Queries Notifier.app for min os version
    /bin/echo "Getting min os version from ${notifierPath}/Contents/Info.plist..."
    minOS=$(/usr/bin/defaults "${notifierPath}"/Contents/Info.plist LSMinimumSystemVersion)
    /bin/echo "minOS: ${minOS}..."

}


createPKG()
{
    # Creates notifier.pkg in ${scriptDir}
    /bin/echo "Creating ${scriptDir}/notifier-${notifierVersion}.pkg"
    /usr/bin/pkgbuild --identifier "${pkgIdentifier}" --root "${scriptDir}"/ROOT/ --scripts "${scriptDir}"/scripts/ --sign "Developer ID Installer: ${developerIDInstaller}" --install-location '/' --version "${notifierVersion}" --min-os-version "${minOS}" "${scriptDir}"/gen-pkg-datajar-notifier-"${notifierVersion}".pkg

}


notarizePKG()
{

    # Notarizes the PKG created within the createPKG function
    /bin/echo "Notarizing ${scriptDir}/gen-pkg-datajar-notifier-${notifierVersion}.pkg..."
    /usr/bin/xcrun notarytool submit "${scriptDir}"/gen-pkg-datajar-notifier-"${notifierVersion}".pkg --keychain-profile "${appPassword}" --wait

}

##########################################################################################
#################################### End functions #######################################
##########################################################################################

setup "$@"
start
getNotifierVersion
getMinOSVersion
setPermissions
createPKG
notarizePKG
finish

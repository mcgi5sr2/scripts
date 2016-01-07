#!/bin/bash

# Colorize and add text parameters
grn=$(tput setaf 2)             #  green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
SYNC="$2"
THREADS="$3"
CLEAN="$4"
LOG="$5"
CHANGELOG="$6"
RELEASE="$7"

# Time of build startup
res1=$(date +%s.%N)

# Sync with latest sources
if [ "$SYNC" == "sync" ]
then
   echo -e "${bldblu}Syncing latest sources ${txtrst}"
   repo sync -j"$THREADS"
fi

# Setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

# Setup ccache
#export USE_CCACHE=1
#export CCACHE_DIR="/home/ezio/Android/ccache"
#/usr/bin/ccache -M 50G

# Start compilation with or without log
if [ "$RELEASE" == "release" ]
then
   echo -e "${bldblu}Creating a LAST_BUILD_PROP file: when you'll build again new a public (release) version of the rom, the automated Slimcenter changelog creation will track changes from the version you are building now${txtrst}"
   export IS_RELEASED_BUILD=true
else
   echo -e "${bldblu}Not creating a LAST_BUILD_PROP file: when you'll build again new a public (release) version of the rom, the automated Slimcenter changelog creation will track changes from the last release version you built, not this one${txtrst}"
   export IS_RELEASED_BUILD=
fi

#Using Changelog
if [ "$CHANGELOG" == "changelog" ]
then
	echo -e "Initiating Changelog Script"
	. scripts/Other_scripts/generate_changelog.sh
else
	echo -e "No Changelog generated"
fi
 
# For building recovery
export BUILDING_RECOVERY=true

# Prebuilt chromium
<<<<<<< HEAD
export USE_PREBUILT_CHROMIUM=0
=======
# export USE_PREBUILT_CHROMIUM=1
>>>>>>> 44f81d5692d252152dedee8fff7620ebece2dcca

# Fix common out folder not being a common
export ANDROID_FIXUP_COMMON_OUT=true

# Lunch device
echo -e "${bldblu}Lunching device... ${txtrst}"
lunch "omni_$DEVICE-userdebug"

# Clean out folder
if [ "$CLEAN" == "clean" ]
then
   echo -e "${bldblu}Cleaning up the OUT folder with make clobber ${txtrst}"
   make clobber;
else
  echo -e "${bldblu}No make clobber so just make installclean ${txtrst}"
  make installclean;
fi

# Remove previous build info
# echo -e "${bldblu}Removing previous build.prop ${txtrst}"
# rm $OUT/system/build.prop;

# Start compilation with or without log
if [ "$LOG" == "log" ]
then
   echo -e "${bldblu}Compiling for $DEVICE and saving a build log file ${txtrst}"
   make bacon -j"$THREADS" 2>&1 | tee build.log;
else
   echo -e "${bldblu}Compiling for $DEVICE without saving a build log file ${txtrst}"
   make bacon -j"$THREADS";
fi

# Get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

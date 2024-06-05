#!/bin/bash

# Add set -e to exit immediately if any command returns a non-zero status
set -e

# Function to perform cleanup tasks
cleanup_function() {
    # Add cleanup tasks here, if needed
    echo "Cleaning up..."
}

# Trap errors and call cleanup_function
trap 'echo "Error: Script failed"; cleanup_function' ERR

LONG=sideloaded:,rootless:,trollstore
OPTS=$(getopt -a weather --longoptions $LONG -- "$@")
libcephei_URL="https://cdn.discordapp.com/attachments/755439561454256132/1184388888475738243/libcephei.zip?ex=658bcb1b&is=6579561b&hm=24bf1a932b1a91dda5826435bddef3114febc54c11c8e6a995c800d7db644e67&"
PROJECT_PATH=$(pwd)

echo "Current working directory: $PROJECT_PATH"

while :
do
  case "$1" in
    --sideloaded )
      echo -e '\033[1m\033[32mBuilding BHTwitter project for sideloaded.\033[0m'

      make clean
      rm -rf .theos
      make SIDELOADED=1

      echo -e '\033[1m\033[32mMake command succeeded.\033[0m'

      IPA_PATH="./packages/com.atebits.Tweetie2.ipa"
      if [ ! -e $IPA_PATH ]; then
        echo -e '\033[1m\033[0;31mIPA file not found at $IPA_PATH.\033[0m'
        exit 1
      fi

      echo -e '\033[1m\033[32mDownloading libcephei SDK.\033[0m'
      temp_dir=$(mktemp -d)
      echo "Temp directory created: $temp_dir"
      curl -L -o "$temp_dir/libcephei.zip" "$libcephei_URL" || {
        echo -e '\033[1m\033[31mError: Failed to download libcephei SDK.\033[0m'
        exit 1
      }
      echo "libcephei SDK downloaded successfully."
      unzip -o "$temp_dir/libcephei.zip" -d ./packages || {
        echo -e '\033[1m\033[31mError: Failed to extract libcephei SDK.\033[0m'
        exit 1
      }
      echo "libcephei SDK extracted successfully."
      rm -rf "$temp_dir"
      rm -rf ./packages/__MACOSX

      echo -e '\033[1m\033[32mBuilding the IPA.\033[0m'
      if ! command -v azule &> /dev/null; then
        echo -e '\033[1m\033[31mError: azule command not found. Please make sure it\'s installed and available in PATH.\033[0m'
        exit 1
      fi
      azule -i "$IPA_PATH" -o "$PROJECT_PATH/packages" -n BHTwitter-sideloaded -r -f "$PROJECT_PATH/.theos/obj/debug/keychainfix.dylib" "$PROJECT_PATH/.theos/obj/debug/libbhFLEX.dylib" "$PROJECT_PATH/.theos/obj/debug/BHTwitter.dylib" "$PROJECT_PATH/packages/Cephei.framework" "$PROJECT_PATH/packages/CepheiUI.framework" "$PROJECT_PATH/packages/CepheiPrefs.framework" "$PROJECT_PATH/layout/Library/Application Support/BHT/BHTwitter.bundle" || {
        echo -e '\033[1m\033[31mError: Failed to build the IPA.\033[0m'
        exit 1
      }

      echo -e '\033[1m\033[32mDone, thanks for using BHTwitter.\033[0m'
      break
      ;;
    # Other cases go here...
  esac
done

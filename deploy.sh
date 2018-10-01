#!/bin/bash

if [[ $(uname) != "Darwin" ]]; then
  echo "This script is intended to be used in macOS, thus aborting."
  exit 1
fi

if ! [[ -d /Applications/Vivaldi.app/ ]]; then
  echo "You need to install Vivaldi to utilize this script."
  exit 1
fi

version=$(defaults read /Applications/Vivaldi.app/Contents/Info CFBundleShortVersionString)
dir="/Applications/Vivaldi.app/Contents/Versions/${version}/Vivaldi Framework.framework/Resources/vivaldi"

for file in *.css; do
  is_deployed=$(grep -c "<link rel=\"stylesheet\" href=\"style/${file}\" />" "${dir}/browser.html")

  if [[ ${is_deployed} -ge 2 ]]; then
    echo "Something went wrong; ${file} is read more then once. Check out browser.html."
    exit 1
  fi

  cp "${file}" "${dir}/style"

  if [[ ${is_deployed} -eq 0 ]]; then
    perl -pi -e "s/<\/head>/  <link rel=\"stylesheet\" href=\"style\/${file}\" \/>\n  <\/head>/" "$dir/browser.html"
  fi

  echo "${file} is successfully deployed."
done

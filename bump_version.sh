#!/usr/bin/env bash

# bump_version.sh (show|major|minor|patch|prerelease|build)

# The nix commands used in this file require the installation of Nix: https://nixos.org

set -o nounset
set -o errexit
set -o pipefail

FLAKE_FILE=flake.nix
FLAKE_LOCK_FILE=flake.lock
VERSION_FILE=src/awssh/_version.py

HELP_INFORMATION="bump_version.sh (show|major|minor|patch|prerelease|build|finalize)"

old_version=$(sed -n "s/^__version__ = \"\(.*\)\"$/\1/p" $VERSION_FILE)
# Comment out periods so they are interpreted as periods and don't
# just match any character
old_version_regex=${old_version//\./\\\.}

if [ $# -ne 1 ]; then
  echo "$HELP_INFORMATION"
else
  case $1 in
    major | minor | patch | prerelease | build)
      new_version=$(python -c "import semver; print(semver.bump_$1('$old_version'))")
      echo Changing version from "$old_version" to "$new_version"
      # A temp file is used to provide compatability with macOS development
      # as a result of macOS using the BSD version of sed
      tmp_file=/tmp/version.$$
      tmp_flake=/tmp/flake.tmp
      sed "s/$old_version_regex/$new_version/" $VERSION_FILE > $tmp_file
      mv $tmp_file $VERSION_FILE
      sed "s/$old_version_regex/$new_version/" $FLAKE_FILE > $tmp_flake
      mv $tmp_flake $FLAKE_FILE
      # Run flake update to update the flake.lock file
      nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update
      git add $FLAKE_FILE $FLAKE_LOCK_FILE $VERSION_FILE
      git commit -m"Bump version from $old_version to $new_version"
      git push
      ;;
    finalize)
      new_version=$(python -c "import semver; print(semver.finalize_version('$old_version'))")
      echo Changing version from "$old_version" to "$new_version"
      # A temp file is used to provide compatability with macOS development
      # as a result of macOS using the BSD version of sed
      tmp_file=/tmp/version.$$
      tmp_flake=/tmp/flake.tmp
      sed "s/$old_version_regex/$new_version/" $VERSION_FILE > $tmp_file
      mv $tmp_file $VERSION_FILE
      sed "s/$old_version_regex/$new_version/" $FLAKE_FILE > $tmp_flake
      mv $tmp_flake $FLAKE_FILE
      git add $FLAKE_FILE $VERSION_FILE
      git commit -m"Finalize version from $old_version to $new_version"
      git push
      ;;
    show)
      echo "$old_version"
      ;;
    *)
      echo "$HELP_INFORMATION"
      ;;
  esac
fi

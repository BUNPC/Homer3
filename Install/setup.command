#!/bin/sh
# script for execution of deployed applications
#
# Sets up the MATLAB Runtime environment for the current $ARCH and executes 
# the specified command.
#
exe_name=$0
current_dir=$(pwd)
script_dir=$(dirname $0)
if [ $script_dir = '.' ]; then
    script_dir="$current_dir"
fi
echo "Current folder: " $script_dir
err=0;
if [ "$script_dir" = "$HOME/Downloads/homer3_install" ]; then
    echo "Installation folder is correct..."
else
    echo "Wrong installation folder...Please move homer3_install to Downloads and rerun setup from there"
    touch $script_dir.error
    err=1;
fi

if [ $err = 1 ]; then
    if [ -d ~/Downloads/homer3_install ]; then
        echo ~/Downloads/homer3_install exists .... Deleting ~/Downloads/homer3_install
        rm -rf ~/Downloads/homer3_install;
    else
        echo ~/Downloads/homer3_install does not exist ... will create it
    fi
    echo cp -r $script_dir ~/Downloads/homer3_install;
    cp -r $script_dir ~/Downloads/homer3_install;
fi
rm -rf ~/libs; mkdir ~/libs
if [ ! -L "~/libs/mcr" ]; then ln -s /Applications/MATLAB/MATLAB_Runtime/v93 ~/libs/mcr; fi
libsdir=~/libs/mcr
exe_dir=~/Downloads/homer3_install
echo "------------------------------------------"
if [ "x$libsdir" = "x" ]; then
  echo Usage:
  echo    $0 \<deployedMCRroot\> args
else
  echo Setting up environment variables
  MCRROOT="$libsdir"
  echo ---
  DYLD_LIBRARY_PATH=.:${MCRROOT}/runtime/maci64 ;
  DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${MCRROOT}/bin/maci64 ;
  DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${MCRROOT}/sys/os/maci64;
  export DYLD_LIBRARY_PATH;
  echo DYLD_LIBRARY_PATH is ${DYLD_LIBRARY_PATH};
  shift 1
  args=
  while [ $# -gt 0 ]; do
      token=$libsdir
      args="${args} \"${token}\"" 
      shift
  done
  eval "\"${exe_dir}/setup.app/Contents/MacOS/setup\"" $args
fi
osascript -e 'tell application "Terminal" to quit' &

exit

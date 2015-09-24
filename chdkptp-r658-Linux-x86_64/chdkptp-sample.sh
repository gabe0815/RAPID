#!/bin/sh
# copy this file to chdkptp.sh and ajust for your configuration
# to use the GUI build from a binary package that includes both CLI and GUI change to chdkptp_gui
CHDKPTP_EXE=chdkptp_gui
# path where chdkptp is installed
CHDKPTP_DIR=/home/user/applications/chdkptp-r658-Linux-x86_64
# LD_LIBRARY_PATH for shared libraries
# only need if you have compiled IUP support and have NOT installed the libraries to system directories 
export LD_LIBRARY_PATH=/home/user/applications/chdkptp-r658-Linux-x86_64/iup-3.14_Linux319_64_lib:/home/user/applications/chdkptp-r658-Linux-x86_64/cd-5.8.2_Linux319_64_lib
export LUA_PATH="$CHDKPTP_DIR/lua/?.lua"
"$CHDKPTP_DIR/$CHDKPTP_EXE" "$@"

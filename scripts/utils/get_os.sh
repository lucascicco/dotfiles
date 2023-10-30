#!/bin/bash

# Detect the platform (similar to $OSTYPE)
function get_os {
  OS=$(uname)
  case $OS in
  'Linux')
    OS='linux'
    ;;
  'FreeBSD')
    OS='freeBSD'
    ;;
  'WindowsNT')
    OS='windows'
    ;;
  'Darwin')
    OS='macos'
    ;;
  'SunOS')
    OS='solaris'
    ;;
  'AIX') ;;
  *) ;;
  esac
  echo "$OS"
}

get_os

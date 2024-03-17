#!/bin/bash

function get_current_os_in_lowercase() {
  local -r current_os=$(uname)
  echo "${current_os}" | tr '[:upper:]' '[:lower:]'
}

#!/bin/bash

function get_current_os_in_lowercase() {
  echo "$(uname)" | tr '[:upper:]' '[:lower:]'
}

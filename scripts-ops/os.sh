#!/bin/bash
## Function to export password.
function os {
  echo -n "Enter your password: "
  read -s OS_PASSWORD_1
  echo ""
  echo -n "Confirm your password: "
  read -s OS_PASSWORD_2
  echo ""
  if [[ $OS_PASSWORD_1 == $OS_PASSWORD_2 ]]; then
    export OS_PASSWORD=$OS_PASSWORD_1
    echo "Password loaded in \$OS_PASSWORD environment variable."
  else
    echo "Password mismatch"
  fi
}
os

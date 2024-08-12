#!/usr/bin/env sh

# Check if requirements.txt file exists
if [ -f requirements.txt ]; then
  # Read the file line by line
  while IFS= read -r line; do
    echo Installing "$line"
    # Install each dependency using luarocks
    luarocks install --tree ./.lua_modules "$line"
  done <requirements.txt
else
  echo "requirements.txt file not found."
fi

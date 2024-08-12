#!/usr/bin/env sh

if [ -f requirements.txt ]; then
  while IFS= read -r line; do
    echo Installing "$line"
    luarocks install --tree ./.lua_modules "$line"
  done <requirements.txt
else
  echo "requirements.txt file not found."
fi

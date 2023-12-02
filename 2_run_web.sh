#!/bin/bash

#!/usr/bin/env bash
# requires jq - https://stedolan.github.io/jq/

function ver_highest() {
  if [[ $# -lt 2 ]]; then
    echo "usage: ver_highest v1 v2 [v3...]"
    return 1
  fi
  awk -v OFS="\n" '$1=$1' <<< "$*" | sort -V | tail -n1
}

# make sure npm is not already running
if pgrep npm; then
  >&2 echo "npm is already running, aborting"
  exit 2
fi

# make sure we have internet connectivity
TEST_HOST=registry.npmjs.org
c=0
while [ $c -lt 10 ]; do
  (( c++ ))
  RESULT=$(dig $TEST_HOST A $TEST_HOST AAAA +short +time=2 +tries=2)
  if [ -n "$RESULT" ]; then
    break
  fi
  sleep 1
done
if [ -z "$RESULT" ]; then
  >&2 echo "no connectivity to $TEST_HOST, aborting"
  exit
fi

# update n + node
n-update -y
latest_node=$(n --latest)
cur_node=$(node --version)
[[ $cur_node =~ ([0-9\.]+) ]] && node_ver=${BASH_REMATCH[1]}
if [ "${node_ver}" != "${latest_node}" ]; then
  echo "upgrading node to ${latest_node}"
  bundled_npm_ver=$(curl -s https://nodejs.org/dist/index.tab | awk 'NR == 2 { print $4 }')
  highest_npm_ver=$(ver_highest "${bundled_npm_ver}" "$(npm -v)")
  if [ "${bundled_npm_ver}" != "${highest_npm_ver}" ]; then
    echo "WARNING: bundled npm is older than installed version [${bundled_npm_ver} < $(npm -v)]"
    echo "         after bundle install, the latest npm version will be reinstalled"
  fi
  n latest
else
  echo "latest node version: ${node_ver} (already installed)"
fi
n prune

# update npm
latest_tag=$(curl -s -o- https://api.github.com/repos/npm/cli/releases/latest | jq -r .tag_name)
[[ $latest_tag =~ ([0-9\.]+) ]] && latest_npm_ver=${BASH_REMATCH[1]}
if [ "${latest_npm_ver}" != "$(npm -v)" ]; then
  echo "upgrading npm to ${latest_npm_ver}"
#   npm install npm@latest -g
    echo "Not updating node"
else
  echo "latest npm version: ${latest_npm_ver} (already installed)"
fi

# update global packages
echo "upgrading global packages"
npm update -g
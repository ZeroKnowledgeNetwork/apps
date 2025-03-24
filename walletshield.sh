#!/bin/bash

USAGE="USAGE: ${0} <network_id> [platform]\n\n[platform] is one of:\n  linux-x64 (default)\n  linux-arm64\n  windows-x64\n  macos"
test -z "${1}" && echo -e "${USAGE}" && exit 1
url="https://test.net.zknet.io/${1}"
dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
os="${2:-"linux-x64"}"
app="${dir}/${1}-walletshield-${os}"
cnf="${dir}/${1}-client.toml"

get() {
  curl --fail --progress-bar -o "${2}" "${1}"
  if [ $? -ne 0 ]; then
    echo "ERROR: failed to retrieve $(basename "${2}")."
    echo "Please check the network_id and platform, then try again."
    echo -e "\n${USAGE}"
    exit 1
  fi
}

# Retrieve walletshield executable if not exists
if [ ! -f "${app}" ]; then
  echo "Retrieving walletshield executable..."
  get "${url}/walletshield-${os}" "${app}"
  chmod u+x "${app}"
fi

# Retrieve deployed network configuration
echo "Retrieving deployed network configuration..."
get "${url}/client.toml" "${cnf}"

# Run walletshield with the retrieved configuration
"${app}" -config "${cnf}" -listen :7070

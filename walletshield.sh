#!/bin/bash

test -z "${1}" && echo "USAGE: ${0} <network_id>" && exit 1
url="https://test.net.0kn.io/${1}"
dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
app="${dir}/${1}-walletshield"
cnf="${dir}/${1}-client.toml"

get() {
  curl --fail --progress-bar -o "${2}" "${1}"
  if [ $? -ne 0 ]; then
    echo "ERROR: failed to retrieve $(basename "${2}")."
    echo "Please check the network_id and try again."
    exit 1
  fi
}

# Retrieve walletshield executable if not exists
if [ ! -f "${app}" ]; then
  echo "Retrieving walletshield executable..."
  get "${url}/walletshield" "${app}"
  chmod u+x "${app}"
fi

# Retrieve deployed network configuration
echo "Retrieving deployed network configuration..."
get "${url}/client.toml" "${cnf}"

# Run walletshield with the retrieved configuration
"${app}" -config "${cnf}" -listen :7070

#!/usr/bin/env bash
set -euo pipefail

mkdir -p zkeys
cd zkeys
wget -O - https://raw.githubusercontent.com/sui-foundation/zklogin-ceremony-contributions/main/download-main-zkey.sh | bash

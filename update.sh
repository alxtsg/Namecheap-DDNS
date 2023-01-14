#!/bin/sh
#
# Script for updating DNS records on Namecheap.
# Author: Alex Tsang <alextsang@live.com>
# License: The 3-Clause BSD License

# Strict mode.
set -e
set -u

scriptDirectory="$(cd "$(dirname "$0")"; pwd)"
domainsDirectory="${scriptDirectory}/configs"
logsDirectory="${scriptDirectory}/logs"

apiURL="https://dynamicdns.park-your-domain.com/update"

configurations=$(ls "${domainsDirectory}")
for configuration in ${configurations}; do
  filePath="${domainsDirectory}/${configuration}"
  # Ignore anything other than regular files, such as directories.
  if [ ! -f "${filePath}" ]; then
    continue
  fi

  domain=
  password=
  host=
  log=

  . "${filePath}"

  url="${apiURL}?domain=${domain}&password=${password}&host=${host}"

  (
    # Log update time.
    date -u '+%Y-%m-%dT%H:%M:%SZ'

    if [ -n "$(command -v ftp)" ]; then
      ftp -M -o - -U '' "${url}"
    elif [ -n "$(command -v wget)" ]; then
      wget -q -O - --user-agent='' "${url}"
    else
      echo 'Neither ftp nor wget is found.'
    fi

    # New line.
    echo ''
  ) >> "${logsDirectory}/${log}"
done

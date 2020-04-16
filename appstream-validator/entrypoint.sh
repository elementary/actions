#!/bin/bash
set -e

# Validate Appdata
appstream-util validate-relax --nonet "$(find data -name "*appdata*")"

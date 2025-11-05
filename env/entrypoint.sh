#!/usr/bin/env bash
set -euo pipefail

# Run the given command inside the sugar environment
exec micromamba run -n sugar "$@"



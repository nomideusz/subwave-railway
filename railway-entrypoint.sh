#!/bin/sh
# The controller reads PORT too (its own API port, default 7701), so Railway's
# PORT would make it fight Caddy for the public port. Hand it to Caddy only.
export CADDY_HTTP_PORT="${PORT:-80}"
unset PORT
exec /usr/local/bin/subwave-supervisor "$@"

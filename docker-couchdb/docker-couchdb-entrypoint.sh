#!/bin/bash

# Modeled on:
#
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

# Exit on error
set -e

# Enable background job
set -m

if [ "$1" = 'couchdb' ]; then
    # Apply our admin user/password and put local.ini in the correct location
    python /docker-couchdb-temp/apply_secrets.py

    # Background start the script that will configure/create our databases
    python /docker-couchdb-temp/create_databases.py &

    # Start the CouchDB script
    exec tini -- /docker-entrypoint.sh "$@"
fi

exec "$@"

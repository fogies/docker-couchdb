import configparser
import os
import yaml

if __name__ == '__main__':
    # Get our admin secrets
    with open('/docker-couchdb-secrets/secrets.yml') as f:
        secrets = yaml.load(f)

    user = secrets['admin']['user']
    password = secrets['admin']['password']

    # Get the local configuration file we'll modify
    local = configparser.ConfigParser()
    local.read('/docker-couchdb-temp/local.ini')

    # Add our admin secrets
    local['admins'] = {}
    local['admins'][user] = password

    # Store it where CouchDB expects it
    os.makedirs('/opt/couchdb/etc', exist_ok=True)
    with open('/opt/couchdb/etc/local.ini', 'w') as f:
        local.write(f)

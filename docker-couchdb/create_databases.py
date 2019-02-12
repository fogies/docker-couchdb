import json
import requests
import requests.adapters
import requests.packages.urllib3.util.retry
import yaml


# Based on:
# https://www.peterbe.com/plog/best-practice-with-retries-with-requests
# https://urllib3.readthedocs.io/en/latest/reference/urllib3.util.html
def requests_retry_session(
        retries=50,
        backoff_factor=0.5,
        status_forcelist=(500, 502, 504),
        session=None,
):
    session = session or requests.Session()
    retry = requests.packages.urllib3.util.retry.Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
    )
    adapter = requests.adapters.HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)

    return session


def main():
    # URL for accessing the CouchDB
    COUCHDB_URL = 'http://localhost:5984'

    # Get our admin secrets
    with open('/docker-couchdb-secrets/secrets.yml') as f:
        secrets = yaml.load(f)

    user = secrets['admin']['user']
    password = secrets['admin']['password']

    # Create a session that will retry as needed
    session = requests_retry_session()

    # This will retry until CouchDB comes online
    response = session.get(COUCHDB_URL)
    if response.status_code == 200:
        print(
            'create_databases.py connected to CouchDB\n' +
            json.dumps(
                response.json(),
                indent=2
            )
        )
    else:
        print('create_databases.py failed to connect to CouchDB')
        return

    # Authenticate
    response = session.post(
        COUCHDB_URL + '/_session',
        data={
            'name': user,
            'password': password
        }
    )
    if response.status_code == 200:
        print('create_databases.py authenticated to CouchDB')

    # Check if the databases exist, create them if they don't
    for database_current in ['_users', '_replicator', '_global_changes']:
        response = session.head(COUCHDB_URL + '/' + database_current)
        if response.status_code == 200:
            print('Database ' + database_current + ' exists')
        else:
            response = session.put(COUCHDB_URL + '/' + database_current)
            if response.status_code == 201:
                print('Database ' + database_current + ' created')
            else:
                print('Database ' + database_current + ' creation failed: ' + str(response.status_code))


if __name__ == '__main__':
    main()

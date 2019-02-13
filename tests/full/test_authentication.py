import base.docker.docker_commands
import nose.tools
import requests
import yaml


class TestAuthentication:
    @classmethod
    def setup_class(cls):
        pass

    def test_admin_with_authentication(self):
        # Get our test admin secrets
        with open('tests/test-secrets/secrets.yml') as f:
            secrets = yaml.load(f)

        user = secrets['admin']['user']
        password = secrets['admin']['password']

        # Perform simple administrative tasks with authentication
        session = requests.Session()

        # Authenticate
        response = session.post(
            'http://{}:{}/_session'.format(
                base.docker.docker_commands.machine_ip(),
                80
            ),
            data={
                'name': user,
                'password': password
            }
        )
        nose.tools.assert_equals(
            response.status_code,
            200
        )

        # Confirm database does not already exist
        response = session.head(
            'http://{}:{}/{}'.format(
                base.docker.docker_commands.machine_ip(),
                80,
                'test_admin_with_authentication'
            )
        )
        if response.status_code == 404:
            # Create the database
            response = session.put(
                'http://{}:{}/{}'.format(
                    base.docker.docker_commands.machine_ip(),
                    80,
                    'test_admin_with_authentication'
                )
            )
            nose.tools.assert_equals(
                response.status_code,
                201
            )

        # Delete the database
        response = session.delete(
            'http://{}:{}/{}'.format(
                base.docker.docker_commands.machine_ip(),
                80,
                'test_admin_with_authentication'
            )
        )
        nose.tools.assert_equals(
            response.status_code,
            200
        )

        # Confirm the database is deleted
        response = session.head(
            'http://{}:{}/{}'.format(
                base.docker.docker_commands.machine_ip(),
                80,
                'test_admin_with_authentication'
            )
        )
        nose.tools.assert_equals(
            response.status_code,
            404
        )

    def test_admin_without_authentication(self):
        # Perform simple administrative tasks without authentication
        session = requests.Session()

        # Check whether the database exists (it should not)
        response = session.head(
            'http://{}:{}/{}'.format(
                base.docker.docker_commands.machine_ip(),
                80,
                'test_admin_with_authentication'
            )
        )
        if response.status_code == 200:
            # Fail at deleting the database
            response = session.delete(
                'http://{}:{}/{}'.format(
                    base.docker.docker_commands.machine_ip(),
                    80,
                    'test_admin_with_authentication'
                )
            )
            nose.tools.assert_equals(
                response.status_code,
                401
            )
        elif response.status_code == 404:
            # Fail at creating the database
            response = session.put(
                'http://{}:{}/{}'.format(
                    base.docker.docker_commands.machine_ip(),
                    80,
                    'test_admin_with_authentication'
                )
            )
            nose.tools.assert_equals(
                response.status_code,
                401
            )

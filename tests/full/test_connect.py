import base.docker
import nose.tools
import requests


class TestConnect:
    def test_connect_to_couchdb(self):
        response = requests.get(
            'http://{}:{}'.format(
                base.docker.machine_ip(),
                80
            )
        )

        nose.tools.assert_equals(
            response.status_code,
            200
        )

#
# This file compiled from Dockerfile.in.
#

FROM couchdb:2.3.0

#
# Environment configurations to get everything to play well
#

# Unicode command line
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Use bash instead of sh, fix stdin tty messages
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
#
# Install the packages we need for getting things done
#
# Based on: https://hub.docker.com/_/buildpack-deps/
#

RUN apt-get -qq clean && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        # From jessie-curl
        # https://github.com/docker-library/buildpack-deps/blob/a0a59c61102e8b079d568db69368fb89421f75f2/jessie/curl/Dockerfile
		ca-certificates \
		curl \
		wget \

        # From jessie-scm
        # https://github.com/docker-library/buildpack-deps/blob/1845b3f918f69b4c97912b0d4d68a5658458e84f/jessie/scm/Dockerfile
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		procps \

        # From jessie
        # https://github.com/docker-library/buildpack-deps/blob/e7534be05255522954f50542ebf9c5f06485838d/jessie/Dockerfile
		autoconf \
		automake \
		bzip2 \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgeoip-dev \
		libglib2.0-dev \
		libjpeg-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		# libmysqlclient-dev \
		libncurses-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		xz-utils \
		zlib1g-dev \

        # Our common dependencies
        dos2unix \
    && \
    apt-get -qq clean
#
# Install Python
#
# Uses pyenv.
#

ENV PYTHON_VERSION 3.6.6
ENV PYTHON_PIP_VERSION 18.0

# Install desired Python version using pyenv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN set -ex \
    && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && pyenv update \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pyenv rehash

RUN set -ex \
    && python -m pip install --upgrade pip==$PYTHON_PIP_VERSION

################################################################################
# Install Python packages.
################################################################################
COPY requirements3.txt /docker-couchdb-temp/requirements3.txt
RUN dos2unix /docker-couchdb-temp/requirements3.txt && \
    pip install -r /docker-couchdb-temp/requirements3.txt

################################################################################
# Configure our secrets in CouchDB's local.ini.
################################################################################
COPY docker-couchdb/local.ini /docker-couchdb-temp/local.ini
RUN dos2unix /docker-couchdb-temp/local.ini

COPY docker-couchdb/apply_secrets.py /docker-couchdb-temp/apply_secrets.py
RUN dos2unix /docker-couchdb-temp/apply_secrets.py

################################################################################
# Daemon that creates the databases needed for CouchDB to run.
################################################################################
COPY docker-couchdb/create_databases.py /docker-couchdb-temp/create_databases.py
RUN dos2unix /docker-couchdb-temp/create_databases.py && \
    chmod +x /docker-couchdb-temp/create_databases.py

################################################################################
# Set up our entrypoint script, which wraps the script from our base.
################################################################################
COPY docker-couchdb/docker-couchdb-entrypoint.sh /docker-couchdb-entrypoint.sh
RUN dos2unix /docker-couchdb-entrypoint.sh && \
    chmod +x /docker-couchdb-entrypoint.sh

ENTRYPOINT ["/docker-couchdb-entrypoint.sh"]
CMD ["couchdb"]

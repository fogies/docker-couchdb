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


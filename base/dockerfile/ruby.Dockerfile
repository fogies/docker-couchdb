#
# Install Ruby
#

RUN wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz && \
    mkdir /usr/src/ruby-install && \
    tar -xzC /usr/src/ruby-install --strip-components=1 -f ruby-install-0.7.0.tar.gz && \
    rm ruby-install-0.7.0.tar.gz && \
    cd /usr/src/ruby-install && \
    make install && \
    rm -rf /usr/src/ruby-install

RUN wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz && \
    mkdir /usr/src/chruby && \
    tar -xzC /usr/src/chruby --strip-components=1 -f chruby-0.3.9.tar.gz && \
    rm chruby-0.3.9.tar.gz && \
    cd /usr/src/chruby && \
    make install && \
    rm -rf /usr/src/chruby

# Pre-install of Ruby 2.5.1 with Bundler 1.16.5
RUN apt-get -qq clean && \
    apt-get -qq update && \
    ruby-install --system --no-reinstall ruby 2.5.1 && \
    gem install bundler --version "1.16.5"

# Removed for incompatibility with modern OpenSSL
# # Legacy pre-install of Ruby 2.3.3 with Bundler 1.13.6
# RUN ruby-install --no-reinstall ruby 2.3.3 && \
#     source /usr/local/share/chruby/chruby.sh && \
#     chruby ruby-2.3.3 && \
#     gem install bundler --version "1.13.6"


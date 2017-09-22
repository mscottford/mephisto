FROM pblaszczyk/debian-etch

# prevent apt-get errors about `dialog` and `readline` not being available
ARG DEBIAN_FRONTEND=noninteractive

# Install postgres 7.4
RUN apt-get update && apt-get install -y postgresql postgresql-dev

# Install build tools needed to build ruby
RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  make \
  zlibc \
  zlib1g \
  zlib1g-dev \
  libssl-dev

ENV RUBY_MAJOR 1.8
ENV RUBY_VERSION 1.8.7-p374

# Set $PATH so that non-login shells will see the Ruby binaries
ENV PATH $PATH:/opt/rubies/ruby-$RUBY_VERSION/bin

# Install MRI Ruby
RUN curl -SLO "http://ftp.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
  && tar -zxvf "ruby-$RUBY_VERSION.tar.gz" \
  && cd "ruby-$RUBY_VERSION" \
  && ./configure --disable-install-doc \
  && make \
  && make install \
  && cd .. \
  && rm -r "ruby-$RUBY_VERSION" "ruby-$RUBY_VERSION.tar.gz" \
  && echo 'gem: --no-document' > /usr/local/etc/gemrc


ENV RUBYGEMS_MAJOR 1.8
ENV RUBYGEMS_VERSION 1.8.29

# Install rubygems and bundler
RUN curl -SLO "http://production.cf.rubygems.org/rubygems/rubygems-$RUBYGEMS_VERSION.tgz" \
  && tar -zxf "rubygems-$RUBYGEMS_VERSION.tgz" \
  && cd "rubygems-$RUBYGEMS_VERSION" \
  && ruby setup.rb \
  && cd .. \
  && rm -r "rubygems-$RUBYGEMS_VERSION" "rubygems-$RUBYGEMS_VERSION.tgz" \
  && echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Define working directory
WORKDIR /app

RUN gem install postgres -v '0.7.9.2008.01.28'
RUN gem install rake -v '0.8.7'
RUN gem install rails -v '2.2.2'
RUN gem install rdoc -v '3.9.5'

ADD . ./

EXPOSE 3000

CMD "./script/server -b 0.0.0.0"

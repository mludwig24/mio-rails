FROM rails:4.1
MAINTAINER Jack M.  <jack.m@iigins.com>

## Default to the same info as orchardup/postgresql docker.
ENV MIO_DB_HOST localhost
ENV MIO_DB_USERNAME docker
ENV MIO_DB_PASSWORD docker
ENV MIO_DB_DATABASE docker
ENV SECRET_KEY_BASE FIXME-No-Default
ENV RAILS_ENV production

RUN apt-get update && apt-get install -qqy --no-install-recommends \
	nodejs \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
RUN bundle install --system

ADD . /usr/src/app
RUN bin/rake assets:precompile

EXPOSE 8080
CMD ["unicorn_rails", "-c", "config/unicorn.rb"]

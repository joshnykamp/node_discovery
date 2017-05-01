FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

#ENV ELIXIR_VERSION "v1.4.0-rc.0@fbfb41d"

RUN apt-get update --fix-missing

# Set the locale
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER root

RUN apt-get install -y wget git # curl

# erlang / elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb -O /tmp/erlang-solutions_1.0_all.deb
RUN dpkg -i /tmp/erlang-solutions_1.0_all.deb
RUN rm /tmp/erlang-solutions_1.0_all.deb

RUN apt-get update
RUN apt-get install -y esl-erlang=1:19.2
RUN apt-get install -y elixir=1.4.0-1

# for custom elixir versions (note, need to get get CI to a higher version to do this)
#RUN set -xe \
	#&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION#*@}.tar.gz" \
	#&& ELIXIR_DOWNLOAD_SHA256="a62bac17020401406ad3f0bda485319bc5c52317e0fc26a2c9f8295ad5aff823" \
	#&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	#&& echo "$ELIXIR_DOWNLOAD_SHA256 elixir-src.tar.gz" | sha256sum -c - \
	#&& mkdir -p /usr/src/elixir-src \
	#&& tar -xzf elixir-src.tar.gz -C /usr/src/elixir-src --strip-components=1 \
	#&& rm elixir-src.tar.gz \
	#&& cd /usr/src/elixir-src \
	#&& make -j$(nproc) \
	#&& make install \
	#&& rm -rf /usr/src/elixir-src

# phoenix deps
RUN apt-get install -y nodejs-legacy
RUN apt-get install -y npm
RUN apt-get install -y inotify-tools


# emergency editors
RUN apt-get install -y vim emacs-nox
# fish shell
RUN apt-get install -y fish

RUN mix local.hex --force
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

WORKDIR /docker/mount

RUN mix local.rebar --force

ADD . /app
WORKDIR /app

RUN mix deps.get
RUN mix compile

CMD ./run.sh

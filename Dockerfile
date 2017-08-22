FROM elixir:1.5.1

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2017-08-22

RUN apt-get update && apt-get install -y inotify-tools

RUN mix local.hex --force && mix local.rebar --force

COPY mix.* /app/
COPY config /app/config
RUN cd /app && mix deps.get && mix deps.compile

COPY . /app

WORKDIR /app

CMD iex -S mix

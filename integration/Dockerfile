FROM elixir:1.6.1

RUN apt-get update && apt-get install -y inotify-tools

WORKDIR "/opt/app"

RUN mix local.hex --force && mix local.rebar --force

# NOTE integration project has no config files to COPY
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . ./

CMD ["mix", "test"]

# NOTE dependencies should be fetched before this step,
# so they are committed to mix.lock.
set -e

mix deps.get

echo $(hostname -I)
echo $SERVICE_NAME
echo $ERLANG_COOKIE
elixir --name $SERVICE_NAME@$(hostname -I) --cookie $ERLANG_COOKIE -S mix run --no-halt

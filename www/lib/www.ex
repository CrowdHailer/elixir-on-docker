defmodule WWW do
  use Raxx.Server

  @external_resource "lib/www.apib"
  use Raxx.ApiBlueprint, "./www.apib"
  use Raxx.Static, "./public"
end

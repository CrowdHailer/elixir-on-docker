defmodule WWW do
  
  @external_resource "lib/www.apib"
  use Raxx.ApiBlueprint, "./www.apib"
  use Raxx.Static, "./public"
  use Raxx.Logger
end

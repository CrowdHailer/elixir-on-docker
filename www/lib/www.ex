defmodule WWW do
  use Raxx.Server
  # use Raxx.Router, [
  #   {%{method: :GET, path: []}, WWW.HomePage},
  #   {%{method: :POST, path: []}, WWW.PublishMessage},
  #   {%{method: :GET, path: ["updates"]}, WWW.SubscribeToMessages},
  # ]
  @external_resource "lib/www.apib"
  use Raxx.Blueprint, "./www.apib"
  use Raxx.Static, "./public"
end

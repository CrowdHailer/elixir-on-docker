defmodule WaterCooler.WWW do
  @external_resource "./www.apib"

  use Raxx.Blueprint, "./www.apib"
  use Raxx.Static, "./public"
end

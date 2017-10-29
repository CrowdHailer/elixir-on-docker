defmodule WWWTest do
  use ExUnit.Case
  doctest WWW

  test "greets the world" do
    assert WWW.hello() == :world
  end
end

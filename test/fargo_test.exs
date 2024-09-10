defmodule FargoTest do
  use ExUnit.Case
  doctest Fargo

  test "greets the world" do
    assert Fargo.hello() == :world
  end
end

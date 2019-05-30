defmodule LogicTest do
  use ExUnit.Case
  doctest Logic

  test "greets the world" do
    assert Logic.hello() == :world
  end
end

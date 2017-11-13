defmodule SimpleRepoNeo4jTest do
  use ExUnit.Case
  doctest SimpleRepoNeo4j.Application

  test "greets the world" do
    assert SimpleRepoNeo4j.Application.hello() == :world
  end
end

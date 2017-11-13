defmodule SimpleRepoNeo4j.Application do
  @moduledoc """
  Documentation for SimpleRepoNeo4j.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SimpleRepoNeo4j.Application.hello
      :world

  """
  def hello do
    :world
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Bolt.Sips, [Application.get_env(:bolt_sips, Bolt)])
    ]

    opts = [strategy: :one_for_one, name: SimpleRepoNeo4j.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

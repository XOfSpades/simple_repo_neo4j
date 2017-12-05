defmodule SimpleRepoNeo4j do
  use Application

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

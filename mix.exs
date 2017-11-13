defmodule SimpleRepoNeo4j.Mixfile do
  use Mix.Project

  def project do
    [
      app: :simple_repo_neo4j,
      version: "0.1.0",
      elixir: "~> 1.5",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :bolt_sips]]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_),     do: ["lib",  "test/support"]

  defp package do
    [
      maintainers: ["Bernhard Støcker"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/xofspades/simple_repo_neo4j"}
    ]
  end

  defp deps do
    [
      {:bolt_sips, git: "https://github.com/xofspades/bolt_sips"},
      {:excoveralls, "~> 0.7.5", only: :test}
    ]
  end
end

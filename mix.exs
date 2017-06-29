defmodule Exorch.Mixfile do
  use Mix.Project

  def project do
    [app: :exorch,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     escript: [main_module: Exorch, path: "release/exorch"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :ssh]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:erlcloud, github: "erlcloud/erlcloud"},
      {:poison, "~>3.0"}
    ]
  end

  defp elixirc_paths(:test), do: ~W[lib test/support]
  defp elixirc_paths(_), do: ~W[lib]
end

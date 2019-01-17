defmodule Crdt.MixProject do
  use Mix.Project

  def project do
    [
      app: :crdt,
      version: "0.1.0",
      description: "A library of Conflict-Free Replicated Data Types (CRDTs).",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "crdt",
      source_url: "https://gitlab.com/jeffrey-xiao/crdt_ex",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT", "Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/jeffrey-xiao/crdt_ex",
        "GitLab" => "https://gitlab.com/jeffrey-xiao/crdt_ex"
      }
    ]
  end
end

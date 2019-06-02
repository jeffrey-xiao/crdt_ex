defmodule Crdt.MixProject do
  use Mix.Project

  @github_url "https://github.com/jeffrey-xiao/crdt_ex"
  @gitlab_url "https://gitlab.com/jeffrey-xiao/crdt_ex"

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
      source_url: @gitlab_url,
      homepage_url: @gitlab_url,
            docs: [
        extras: ["README.md"]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      dialyzer: [
        plt_add_deps: :transitive
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
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "LICENSE-APACHE", "LICENSE-MIT", "mix.exs", "README.md"],
      licenses: ["Apache 2.0", "MIT"],
      links: %{
        "GitHub" => @github_url,
        "GitLab" => @gitlab_url
      }
    ]
  end
end

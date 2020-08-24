defmodule ExBankID.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ex_bank_id,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7", optional: true},
      {:poison, "~> 3.1", optional: true},
      {:uuid, "~> 1.1"},
      {:credo, "~> 1.4", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:bypass, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:nimble_options, "~> 0.3.0"}
    ]
  end

  defp description(), do: "exBankID is a simple stateless API-client for the Swedish BankID API"

  defp package() do
    [
      name: "exBankID",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* assets),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/anfly0/exBankID"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "ExBankID",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/ExBankID",
      source_url: "https://github.com/anfly0/exBankID",
      extras: [
        "README.md"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]
end

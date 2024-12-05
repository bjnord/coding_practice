defmodule Manual.MixProject do
  use Mix.Project

  def project do
    [
      app: :manual,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.30.9", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.13"},
      #{:math, "~> 0.7.0"},
      #{:propcheck, "~> 1.4", only: [:test]},
      {:snow, path: "../../../advent-2023/snow"},
    ]
  end

  defp escript_config do
    [
      main_module: Manual
    ]
  end
end

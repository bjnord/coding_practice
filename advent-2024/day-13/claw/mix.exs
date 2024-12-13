defmodule Claw.MixProject do
  use Mix.Project

  def project do
    [
      app: :claw,
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
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.13"},
      {:nimble_parsec, "~> 1.4.0"},
      {:nx, "~> 0.9"},
      #{:math, "~> 0.7.0"},
      #{:propcheck, "~> 1.4", only: [:test]},
      {:history, path: "../../history"},
    ]
  end

  defp escript_config do
    [
      main_module: Claw
    ]
  end
end

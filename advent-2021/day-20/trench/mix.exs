defmodule Trench.MixProject do
  use Mix.Project

  def project do
    [
      app: :trench,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.9",
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
      {:ex_doc, "~> 0.22.0", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.12"},
      #{:math, "~> 0.7.0"},
      #{:propcheck, "~> 1.4", only: [:test]},
      {:submarine, path: "../../submarine"},
    ]
  end

  defp escript_config do
    [
      main_module: Trench
    ]
  end
end

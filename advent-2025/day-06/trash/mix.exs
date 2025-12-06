defmodule Trash.MixProject do
  use Mix.Project

  def project do
    [
      app: :trash,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.39", only: :dev, runtime: false},
      {:freedom_formatter, "~> 2.1.3", only: :dev},
      #{:math, "~> 0.7.0"},
      #{:propcheck, "~> 1.5", only: [:test]},
      {:decor, path: "../../decor"},
    ]
  end

  defp escript_config do
    [
      main_module: Trash
    ]
  end
end

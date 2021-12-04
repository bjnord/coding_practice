defmodule Bingo.MixProject do
  use Mix.Project

  def project do
    [
      app: :bingo,
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
      {:math, "~> 0.7.0"},
    ]
  end

  defp escript_config do
    [
      main_module: Bingo
    ]
  end
end

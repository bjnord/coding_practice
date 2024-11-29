defmodule Potions.MixProject do
  use Mix.Project

  def project do
    [
      app: :potions,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.16",
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
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
      {:kingdom, path: "../../kingdom"},
    ]
  end

  defp escript_config do
    [
      main_module: Potions
    ]
  end
end

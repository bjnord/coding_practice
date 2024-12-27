defmodule Bridge.MixProject do
  use Mix.Project

  def project do
    [
      app: :bridge,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:ex_doc, "~> 0.36", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.13"},
      {:benchee, "~> 1.3", only: :dev},
      #{:math, "~> 0.7.0"},
      #{:propcheck, "~> 1.4", only: [:test]},
      {:history, path: "../../history"},
    ]
  end

  defp escript_config do
    [
      main_module: Bridge
    ]
  end

  # Specifies which paths to compile per environment.
  # h/t <https://stackoverflow.com/a/73967553/291754>
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end

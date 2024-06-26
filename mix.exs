defmodule Deepl.MixProject do
  use Mix.Project

  def project do
    [
      app: :deepl,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Deepl.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:con_cache, "~> 1.0"},
      {:plug, "~> 1.0", only: :test}
    ]
  end
end

defmodule StatsDoggo.Mixfile do
  use Mix.Project

  @name    :stats_doggo
  @version "0.4.4"

  @deps [
    {:env_config, ">= 0.1.0"},
    {:plug, ">= 1.3.0"},
    {:statix, ">= 1.0.0"},

    {:ex_doc,  "~> 0.16", only: [ :dev, :test ]},
  ]

  @description """
  A good stats doggo.

  * Uses Statix to send metrics to a StatsD host
  * Uses ex_vmstats to gather VM metrics
  * Provides a Plug to get web stats
  """

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= 1.3.0",
      deps:    @deps,
      build_embedded:  in_production,
      package: package(),
      description: @description,
      start_permanent: in_production,
    ]
  end

  def application do
    [
      mod: { StatsDoggo.Application, [] },
      extra_applications: [ :logger ],
    ]
  end

  defp package do
    [
      files: [
        "lib", "mix.exs", "README.md"
      ],
      maintainers: [
        "Donald Plummer <donald.plummer@gmail.com>"
      ],
      licenses: [
        "Apache 2.0"
      ],
      links: %{
        "GitHub" => "https://github.com/avvo/stats_doggo",
      }
    ]
  end
end

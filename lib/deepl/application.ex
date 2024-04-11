defmodule Deepl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts =
      :deepl
      |> Application.get_env(:con_cache_opts, [])
      |> then(fn x ->
        Keyword.merge([ttl_check_interval: :timer.seconds(60 * 5), global_ttl: false], x)
      end)
      |> Keyword.take([:ttl_check_interval, :global_ttl])

    children =
      [
        {ConCache, [{:name, Deepl.Cache} | opts]}
      ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Deepl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

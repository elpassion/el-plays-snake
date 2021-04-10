defmodule ElPlaysSnake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ElPlaysSnake.Repo,
      # Start the Telemetry supervisor
      ElPlaysSnakeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElPlaysSnake.PubSub},
      # Start the Endpoint (http/https)
      ElPlaysSnakeWeb.Endpoint,

      ElPlaysSnake.Presence,
      # Start a worker by calling: ElPlaysSnake.Worker.start_link(arg)
      # {ElPlaysSnake.Worker, arg}
      {ElPlaysSnake.Game, name: ElPlaysSnake.Game}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElPlaysSnake.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ElPlaysSnakeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Myappv1.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Myappv1Web.Telemetry,
      Myappv1.Repo,
      {DNSCluster, query: Application.get_env(:myappv1, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Myappv1.PubSub},
      # Start a worker by calling: Myappv1.Worker.start_link(arg)
      # {Myappv1.Worker, arg},
      # Start to serve requests, typically the last entry
      Myappv1Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Myappv1.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Myappv1Web.Endpoint.config_change(changed, removed)
    :ok
  end
end

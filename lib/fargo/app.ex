defmodule Fargo.App do
  use Application


  @impl true
  def start(_type, _args) do
    Supervisor.start_link([Fargo.Cache], strategy: :one_for_one)
  end
end

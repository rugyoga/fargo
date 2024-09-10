defmodule Fargo do
  @moduledoc false
  def child_spec(_opts) do
    %{id: Fargo,
      start: {Fargo.Cache, :start_link, [nil]}
     }
  end
end

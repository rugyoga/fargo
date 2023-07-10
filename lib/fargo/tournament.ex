defmodule Fargo.Tournament do
  def knockout(players) do

  end

  def knockout_draw(n) do
    power_of_2 = trunc(:math.pow(2.0, :math.ceil(:math.log(n)/:math.log(2))))
    extra_round = (n+1)..power_of_2
    Enum.map(1..n, & &1) ++ Enum.map(extra_round, fn _ -> :bye end)
    |> mk_draw()
  end

  def mk_draw(prior) do
    n = length(prior)
    if n == 1 do
      prior
    else
      {top, bottom} = Enum.split(prior, div(n, 2))
      top |> Enum.zip(Enum.reverse(bottom)) |> mk_draw()
    end
  end

  def double_elimination(players) do

  end
end

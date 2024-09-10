defmodule Fargo.Tournament do
  def mk_knockout(n) do
    players(n)
    |> pad()
    |> mk_knockout_draw_rec()
  end

  def round_up_to_power_of_2(n) do
    trunc(:math.pow(2.0, :math.ceil(:math.log(n)/:math.log(2))))
  end

  def players(n), do: Enum.map(1..n, &{:player, &1})

  def pad(participants) do
    n = length(participants)
    participants
    |> Kernel.++(add_byes(n+1, round_up_to_power_of_2(n)))
  end

  def add_byes(m, n) do
    if m > n, do: [], else: m..n |> Enum.map(fn _ -> :bye end)
  end

  def mk_draw(players, i) do
    sorted = players |> Enum.sort(&compare/2)
    {top, bottom} = Enum.split(sorted, div(length(sorted), 2))
    top
    |> Enum.zip(Enum.reverse(bottom)) # if(reverse, do: Enum.reverse(bottom), else: bottom))
    |> Enum.map_reduce(i, fn {a, b}, i -> if(a == :bye or b == :bye, do: {{0, {a, b}}, i}, else: {{i, {a, b}}, i+1}) end)
  end

  def mk_neighbour_draw(players, i) do
    players
    |> Enum.chunk_every(2)
    |> Enum.map_reduce(i, fn [a, b], i -> if(a == :bye or b == :bye, do: {{0, {a, b}}, i}, else: {{i, {a, b}}, i+1}) end)
  end

  def mk_double(n) do
    {first_round_matches, i} = Fargo.Tournament.players(n) |> Fargo.Tournament.pad() |> mk_draw(1)
    mk_double([first_round_matches], [], i) |> display()
  end

  def display(matches) do
    matches
    |> Enum.reject(fn {m, {a, b}} -> m == 0 or a == :bye or b == :bye end)
    |> Enum.map_join("\n", fn {m, {a, b}} -> "#{m}. #{pretty(a)} vs #{pretty(b)}" end)
    |> IO.puts
  end

  def pretty({:player, n}), do: "player #{n}"
  def pretty({:winner, n}), do: "winner #{n}"
  def pretty({:loser, n}), do: "loser #{n}"

  def compare({:player, m}, {:player, n}), do: m < n
  def compare({:player, _}, _), do: true
  def compare(_, {:player, _}), do: false
  def compare({:winner, m}, {:winner, n}), do: m < n
  def compare({:winner, _}, _), do: true
  def compare(_, {:winner, _}), do: false
  def compare({:loser, m}, {:loser, n}), do: m < n
  def compare({:loser, _}, _), do: true
  def compare(_, {:loser, _}), do: false
  def compare(_, _), do: false

  def mk_double([[{_, _}] | _] = winners_bracket, [[{_, _}] | _] = losers_bracket, _) do
    [winners_bracket, losers_bracket] |> List.flatten |> Enum.sort
  end
  def mk_double([winners_last_round | _]=winners_bracket, losers_bracket, i) do
    {winners_matches, i} = winners_last_round |> mk_winners() |> mk_neighbour_draw(i)
    {minor_loser_matches, i} = winners_last_round |> mk_losers() |> mk_neighbour_draw(i)
    {major_loser_matches, i} = (mk_losers(winners_matches) ++ mk_winners(minor_loser_matches)) |> mk_draw(i)
    mk_double([winners_matches | winners_bracket], [major_loser_matches | [minor_loser_matches | losers_bracket]], i)
  end

  def mk_winners(matches), do: Enum.map(matches, fn {n, {a, b}} -> if(b == :bye, do: a, else: {:winner, n}) end)
  def mk_losers(matches), do: Enum.map(matches, fn {n, {_, b}} -> if(b == :bye, do: :bye, else: {:loser, n}) end)

  def mk_knockout_draw_rec(prior, i \\ 1) do
    n = length(prior)
    if n == 1 do
      prior
    else
      prior
      |> mk_draw(i)
      |> then(fn {draw, i} -> mk_knockout_draw_rec(draw, i) end)
    end
  end
end

defmodule Fargo.Tournament do
  def mk_knockout(n) do
    players(n)
    |> pad()
    |> mk_knockout_draw_rec()
  end

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

  def round_up_to_power_of_2(n) do
    trunc(:math.pow(2.0, :math.ceil(:math.log(n)/:math.log(2))))
  end

  def players(n), do: Enum.map(1..n, &{:player, &1})

  def pad(participants) do
    n = length(participants)
    powerof2 = round_up_to_power_of_2(n)
    participants ++ byes(powerof2-n)
  end

  def byes(0), do: []
  def byes(n), do: Enum.map(1..n, fn _ -> :bye end)


  def assign_match({_, :bye} = pair, match), do: {{0, pair}, match}
  def assign_match({:bye, _} = pair, match), do: {{0, pair}, match}
  def assign_match(pair, match), do: {{match, pair}, match+1}
  def assign_matches(pairs, match), do: Enum.map_reduce(pairs, match, &assign_match/2)

  def mk_draw(players, match) do
    {top, bottom} = Enum.split(players, div(length(players), 2))
    top
    |> Enum.zip(Enum.reverse(bottom)) # if(reverse, do: Enum.reverse(bottom), else: bottom))
    |> assign_matches(match)
  end

  def mk_neighbour_draw(players, match) do
    players
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
    |> assign_matches(match)
  end

  def mk_double(n) do
    power2 = round_up_to_power_of_2(n)
    if n == power2 do
      {first_round_matches, i} = players(n) |> mk_draw(1)
      {winners_matches, i} = first_round_matches |> mk_winners() |> mk_neighbour_draw(i)
      {minor_loser_matches, i} = first_round_matches |> mk_losers() |> mk_neighbour_draw(i)
      {major_loser_matches, i} = (mk_losers(winners_matches) ++ mk_winners(minor_loser_matches)) |> mk_draw(i)
      mk_double([winners_matches, first_round_matches], [major_loser_matches, minor_loser_matches], i)
    else
      {first_round_matches, i} = players(n) |> pad() |> mk_draw(1)
      {winners_matches, i} = first_round_matches |> mk_winners() |> mk_draw(i)
      {minor_loser_matches, i} = first_round_matches |> mk_losers() |> mk_neighbour_draw(i)
      {major_loser_matches, i} = (mk_losers(winners_matches) ++ mk_winners(minor_loser_matches)) |> mk_draw(i)
      mk_double([winners_matches, first_round_matches], [major_loser_matches, minor_loser_matches], i)
    end
  end

  def mk_double([[{hotseat, _}] | _] = winners_bracket, [[{loser_final, _}] | _] = losers_bracket, match) do
    [{match, {:winner, hotseat}, {:winner, loser_final}}, winners_bracket, losers_bracket] |> List.flatten |> Enum.sort
  end
  def mk_double([winners_last_round | _]=winners_bracket, [losers_last_round |_]=losers_bracket, i) do
    {winners_matches, i} = winners_last_round |> mk_winners() |> mk_neighbour_draw(i)
    {minor_loser_matches, i} = losers_last_round |> mk_winners() |> mk_neighbour_draw(i)
    {major_loser_matches, i} = (mk_losers(winners_matches) ++ mk_winners(minor_loser_matches)) |> mk_draw(i)
    mk_double([winners_matches | winners_bracket], [major_loser_matches | [minor_loser_matches | losers_bracket]], i)
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


  def winner({_, {:bye, a}}), do: a
  def winner({_, {a, :bye}}), do: a
  def winner({match, _}), do: {:winner, match}

  def mk_winners(matches), do: Enum.map(matches, fn {n, {a, b}} -> if(b == :bye, do: a, else: {:winner, n}) end)
  def mk_losers(matches), do: Enum.map(matches, fn {n, {_, b}} -> if(b == :bye, do: :bye, else: {:loser, n}) end)
end

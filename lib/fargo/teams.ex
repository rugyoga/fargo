defmodule Fargo.Teams do

  def pairings([h1, h2, h3, h4], [a1, a2, a3, a4]) do
    [{h1, a1}, {h2, a2}, {h3, a3}, {h4, a4},
     {h1, a2}, {h2, a1}, {h4, a3}, {h3, a2},
     {h1, a4}, {h4, a1}, {h2, a3}, {h3, a4},
     {h4, a2}, {h1, a3}, {h3, a1}, {h2, a4}]
  end

  def playoff_pairings(home, away), do: pairings(home, away) ++ [{Enum.max(home), Enum.max(away)}]

  def playoff_outcomes(probs, completed \\ [{{0, 0}, 1.0}])
  def playoff_outcomes([], completed), do: completed
  def playoff_outcomes([prob | probs], completed) do
    {finished, ongoing} = Enum.split_with(completed, &finished?/1)
    next_round = ongoing
      |> Enum.flat_map(fn {{h, a}, p} -> [{{h+1, a}, prob*p}, {{h, a+1}, (1.0-prob)*p}] end)
      |> Enum.group_by(fn {score, _} -> score end, fn {_, p} -> p end)
      |> Enum.map(fn {score, ps} -> {score, Enum.sum(ps)} end)
    playoff_outcomes(probs, next_round) ++ finished
  end

  def season_outcomes(probs, completed \\ [{{0, 0}, 1.0}])
  def season_outcomes([], completed), do: completed
  def season_outcomes([prob | probs], completed) do
    next_round = completed
      |> Enum.flat_map(fn {{h, a}, p} -> [{{h+1, a}, prob*p}, {{h, a+1}, (1.0-prob)*p}] end)
      |> Enum.group_by(fn {score, _} -> score end, fn {_, p} -> p end)
      |> Enum.map(fn {score, ps} -> {score, Enum.sum(ps)} end)
    season_outcomes(probs, next_round)
  end

  def finished?({{9, _}, _}), do: true
  def finished?({{_, 9}, _}), do: true
  def finished?(_), do: false

  def probabilities(home, away, analyzer \\ &season_outcomes/1) do
    pairings(home, away)
    |> Enum.map(fn {h, a} -> Fargo.Math.chance(h, a) end)
    |> then(analyzer)
  end

  def win_percentage(home, away) do
    home
    |> probabilities(away)
    |> Enum.flat_map(fn {{h, _}, p} -> if(h == 9, do: [p], else: []) end)
    |> Enum.sum()
  end

  def percent(prob), do: :erlang.float_to_binary(100.0 * prob, [decimals: 1])

  def display({{home, away}, prob}), do: "#{home}-#{away} #{percent(prob)}%"

  def sort(probs) do
    (probs |> Enum.filter(fn {{home, _}, _} -> home == 9 end) |> Enum.sort()) ++
    (probs |> Enum.filter(fn {{_, away}, _} -> away == 9 end) |> Enum.sort(:desc))
  end

  def expected_score(home, away, regular \\ true) do
    probabilities(home, away, if(regular, do: &season_outcomes/1, else: &playoff_outcomes/1))
    |> Enum.map_join("\n", &display/1)
  end

  def matchup(home, home_strategy \\ &best/1, away, away_strategy \\ &best/1) do
    home_players = pick(home)  |> then(home_strategy) |> IO.inspect(label: "home: #{home}")
    away_players = pick(away)  |> then(away_strategy) |> IO.inspect(label: "away: #{away}")
    probabilities(home_players, away_players, &season_outcomes/1)
    |> Enum.map_join("\n", &display/1)
    |> IO.puts()
  end

  def best(players), do: Enum.take(players, 4)
  def worst(players), do: Enum.take(players, -4)

  def pick(name) do
    Fargo.Scraper.get_teams()
    |> Enum.filter(fn {team, _} -> String.contains?(team, name) end)
    |> then(fn [{_, players}| _] -> players |> Enum.unzip() |> elem(1) |> Enum.sort(:desc) end)
  end

end

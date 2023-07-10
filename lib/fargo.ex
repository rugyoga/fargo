defmodule Fargo do
  @moduledoc """
  Documentation for `Fargo`.
  Toolkit to use Fargo rating to predict matches and tournaments.
  """


  def raw_rating(rating, robustness, starter) do
    ((200.0 * rating) - (starter * (200-robustness)))/robustness
  end

  def transformed(r), do: :math.pow(2.0, r/ 100.0)

  def chance(a, b) do
    ta = transformed(a)
    tb = transformed(b)
    ta/(ta + tb)
  end

  def team_chance(home, away) do
    if length(home) != length(away) do
      {:error, "teams of different sizes"}
    else
      {:ok, "team size matched"}
    end
  end

  def pairings([h1, h2, h3, h4], [a1, a2, a3, a4]) do
    [{h1, a1}, {h2, a2}, {h3, a3}, {h4, a4},
     {h1, a2}, {h2, a1}, {h4, a3}, {h3, a2},
     {h1, a4}, {h4, a1}, {h2, a3}, {h3, a4},
     {h4, a2}, {h1, a3}, {h3, a1}, {h2, a4}]
  end


  def outcomes(probs, completed \\ [{{0, 0}, 1.0}])
  def outcomes([], completed), do: completed
  def outcomes([prob | probs], completed) do
    {finished, ongoing} = Enum.split_with(completed, &finished?/1)
    next_round = ongoing
      |> Enum.flat_map(fn {{h, a}, p} -> [{{h+1, a}, prob*p}, {{h, a+1}, (1.0-prob)*p}] end)
      |> Enum.group_by(fn {score, _} -> score end, fn {_, p} -> p end)
      |> Enum.map(fn {score, ps} -> {score, Enum.sum(ps)} end)
    outcomes(probs, next_round) ++ finished
  end

  def finished?({{9, _}, _}), do: true
  def finished?({{_, 9}, _}), do: true
  def finished?(_), do: false

  def probabilities(home, away) do
    pairings(home, away)
    |> Enum.map(fn {h, a} -> chance(h, a) end)
    |> outcomes()
  end

  def win_percentage(home, away) do
    outcomes = probabilities(home, away)
    [{_, tie}] = Enum.filter(outcomes, fn {score, _} -> score == {8, 8} end)
    outcomes
    |> Enum.flat_map(fn {{h, _}, p} -> if(h == 9, do: [p], else: []) end)
    |> Kernel.++([tie * chance(List.first(home), List.first(away))])
    |> Enum.sum()
  end
end

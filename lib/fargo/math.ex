defmodule Fargo.Math do
  @moduledoc false

  def raw_rating(rating, robustness, starter) do
    ((200.0 * rating) - (starter * (200-robustness)))/robustness
  end

  defp transformed(r), do: :math.pow(2.0, r/ 100.0)

  def chance(a, b) do
    ta = transformed(a)
    tb = transformed(b)
    ta/(ta + tb)
  end

  def m_choose_n(m, n), do: m_choose_n(m, 0, n-1)

  def m_choose_n(0, _, _), do: []
  def m_choose_n(_, n_lo, n_hi) when n_lo > n_hi, do: []
  def m_choose_n(1, n_lo, n_hi), do: Enum.map(n_lo..n_hi, &[&1])
  def m_choose_n(m, n_lo, n_hi) do
    Enum.map(m_choose_n(m-1, n_lo+1, n_hi), &[n_lo | &1]) ++ m_choose_n(m, n_lo+1, n_hi)
  end

  def race_to_n_outcomes(n) do
    fn {a, b} -> a == n or b == n end
    |> race()
    |> Enum.group_by(& &1, fn _ -> 1 end)
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)
  end

  def race_to_n(n) do
    counts = n |> race_to_n_outcomes() |> Enum.filter(fn {{w, _}, _} -> w == n end)

    fn p ->
      counts
      |> Enum.map(fn {{w, l}, count} -> :math.pow(p, w) * :math.pow(1-p, l) * count end)
      |> Enum.sum
    end
  end

  def race(done?), do: race(done?, [], [{0, 0}])

  def race(_, completed, []), do: completed
  def race(done?, completed, [{wins, losses} = candidate | candidates]) do
    if done?.(candidate) do
      race(done?, [candidate | completed], candidates)
    else
      race(done?, completed, [{wins+1, losses} | [{wins, losses+1} | candidates]])
    end
  end
end

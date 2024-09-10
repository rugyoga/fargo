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
end

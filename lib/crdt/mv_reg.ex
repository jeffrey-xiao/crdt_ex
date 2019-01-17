defmodule Crdt.MVReg do
  alias Crdt.VectorClock

  def new(), do: []

  def merge(r1, r2) do
    r1_values =
      r1
      |> Enum.reject(fn {_value1, clock1} ->
        r2
        |> Enum.any?(fn {_value2, clock2} -> VectorClock.dominates?(clock2, clock1) end)
      end)

    r2_values =
      r2
      |> Enum.reject(fn {_value2, clock2} ->
        r1
        |> Enum.any?(fn {_value1, clock1} -> VectorClock.descends?(clock1, clock2) end)
      end)

    r1_values ++ r2_values
  end

  def update(reg, id, value) do
    [{value, reg |> clock() |> VectorClock.increment(id, 1)}]
  end

  def get(reg), do: reg |> Enum.map(fn {value, _clock} -> value end) |> Enum.uniq()

  defp clock(reg) do
    reg
    |> Enum.reduce(VectorClock.new(), fn {_value, clock}, acc -> VectorClock.merge(clock, acc) end)
  end
end

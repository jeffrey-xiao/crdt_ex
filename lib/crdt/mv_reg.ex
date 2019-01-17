defmodule Crdt.MVReg do
  defstruct values: []

  alias Crdt.VectorClock

  def new(), do: %__MODULE__{values: []}

  def merge(r1, r2) do
    r1_values =
      r1.values
      |> Enum.reject(fn {_value1, clock1} ->
        r2.values
        |> Enum.any?(fn {_value2, clock2} -> VectorClock.dominates?(clock2, clock1) end)
      end)

    r2_values =
      r2.values
      |> Enum.reject(fn {_value2, clock2} ->
        r1.values
        |> Enum.any?(fn {_value1, clock1} -> VectorClock.descends?(clock1, clock2) end)
      end)

    %__MODULE__{values: r1_values ++ r2_values}
  end

  def update(reg, id, value) do
    %{reg | values: [{value, reg |> clock() |> VectorClock.increment(id, 1)}]}
  end

  def get(reg), do: reg.values |> Enum.map(fn {value, _clock} -> value end) |> Enum.uniq()

  defp clock(reg) do
    reg.values
    |> Enum.reduce(VectorClock.new(), fn {_value, clock}, acc -> VectorClock.merge(clock, acc) end)
  end
end

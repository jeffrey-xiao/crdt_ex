defmodule Crdt.MVReg do
  @moduledoc """
  A MV-Reg is a register that maintains all values when there are conflicting entries. These
  conflicting entries are detected using Vector Clocks.
  """
  alias Crdt.VectorClock

  @type t :: [{any(), VectorClock.t()}]

  @doc """
  Returns a new, empty MV-Reg.
  """
  @spec new() :: t
  def new(), do: []

  @doc """
  Merges `r1` and `r2`.
  """
  @spec merge(t, t) :: t
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

  @doc """
  Updates `reg` with `value` from actor `id`. It will store all conflicting entries that do have
  parent Vector Clocks.
  """
  @spec update(t, any(), any()) :: t
  def update(reg, id, value) do
    [{value, reg |> clock() |> VectorClock.increment(id, 1)}]
  end

  @doc """
  Returns a list of values associated with `reg`.
  """
  @spec get(t) :: [any()]
  def get(reg), do: reg |> Enum.map(fn {value, _clock} -> value end) |> Enum.uniq()

  @spec clock(t) :: VectorClock.t()
  defp clock(reg) do
    reg
    |> Enum.reduce(VectorClock.new(), fn {_value, clock}, acc -> VectorClock.merge(clock, acc) end)
  end
end

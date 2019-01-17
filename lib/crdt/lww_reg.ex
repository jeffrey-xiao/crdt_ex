defmodule Crdt.LWWReg do
  @moduledoc """
  A LWW-Reg is a register that stores the value with the latest client provided timestamp.
  """
  defstruct value: nil, timestamp: nil

  @doc """
  Returns a new LWW-Reg initialized to `value` at `timestamp`.
  """
  def new(value, timestamp), do: %__MODULE__{value: value, timestamp: timestamp}

  @doc """
  Merges `r1` and `r2`.
  """
  def merge(r1, r2) do
    update(r1, r2.value, r2.timestamp)
  end

  @doc """
  Updates `reg` with `value` at `timestamp`.
  """
  def update(reg, value, timestamp) do
    cond do
      reg.timestamp == timestamp && reg.value != value ->
        raise "Register timestamps are equal, but values are not."

      reg.timestamp <= timestamp ->
        new(value, timestamp)

      reg.timestamp > timestamp ->
        reg
    end
  end

  @doc """
  Returns the value associated with `reg`.
  """
  def get(reg), do: reg.value
end

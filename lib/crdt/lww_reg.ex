defmodule LWWReg do
  defstruct val: nil, timestamp: nil

  def new(val, timestamp), do: %__MODULE__{val: val, timestamp: timestamp}

  def merge(r1, r2) do
    update(r1, r2.val, r2.timestamp)
  end

  def update(reg, val, timestamp) do
    cond do
      reg.timestamp == timestamp && reg.val != val ->
        raise "Register timestamps are equal, but values are not."

      reg.timestamp <= timestamp ->
        new(val, timestamp)

      reg.timestamp > timestamp ->
        reg
    end
  end

  def get(reg), do: reg.val
end

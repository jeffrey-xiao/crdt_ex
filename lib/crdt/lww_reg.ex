defmodule LWWReg do
  defstruct value: nil, timestamp: nil

  def new(value, timestamp), do: %__MODULE__{value: value, timestamp: timestamp}

  def merge(r1, r2) do
    update(r1, r2.value, r2.timestamp)
  end

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

  def get(reg), do: reg.value
end

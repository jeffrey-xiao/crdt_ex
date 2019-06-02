defmodule Crdt.GCounterTest do
  use ExUnit.Case
  import Crdt.GCounter
  alias Crdt.VectorClock
  doctest Crdt.GCounter

  test "new" do
    assert new() == VectorClock.new()
  end

  test "merge" do
    c1 = new() |> increment(1, 1) |> increment(2, 2)
    c2 = new() |> increment(2, 3) |> increment(3, 3)
    assert c1 |> merge(c1) |> get() == 7
  end

  test "increment" do
    assert new() |> increment(1) |> get() == 1
    assert new() |> increment(1, 1) |> get() == 1
    assert new() |> increment(1, 2) |> get() == 2
  end
end

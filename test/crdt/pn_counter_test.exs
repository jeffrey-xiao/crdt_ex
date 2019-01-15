defmodule Crdt.PNCounterTest do
  use ExUnit.Case
  import Crdt.PNCounter
  alias Crdt.{PNCounter, VectorClock}
  doctest Crdt.PNCounter

  test "new" do
    assert new() == %PNCounter{p_clock: VectorClock.new(), n_clock: VectorClock.new()}
  end

  test "merge" do
    c1 = new() |> increment(1, 1) |> decrement(2, 2)
    c2 = new() |> decrement(2, 3) |> increment(3, 3)
    assert merge(c1, c2) |> get() == 1
  end

  test "increment" do
    assert new() |> increment(1) |> get() == 1
    assert new() |> increment(1, 1) |> get() == 1
    assert new() |> increment(1, 2) |> get() == 2
  end

  test "decrement" do
    assert new() |> decrement(1) |> get() == -1
    assert new() |> decrement(1, 1) |> get() == -1
    assert new() |> decrement(1, 2) |> get() == -2
  end
end

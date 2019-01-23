defmodule Crdt.ORSetTest do
  use ExUnit.Case
  import Crdt.ORSet
  alias Crdt.{ORSet, VectorClock}
  doctest Crdt.ORSet

  test "new" do
    assert new() == %ORSet{clock: VectorClock.new(), entries: %{}, deferred: %{}}
  end

  test "merge removes different elements in the event of identical clocks" do
    s1 = new() |> add(1, 1)
    s2 = new() |> add(2, 1)
    s3 = merge(s1, s2)
    assert get(s3) == MapSet.new()
  end

  test "merge removal after added item" do
    s1 = new() |> add(1, 1)
    s2 = new() |> add(1, 1) |> remove(1)
    s3 = merge(s1, s2)
    refute member?(s3, 1)
  end

  test "merge unwitnessed insertion" do
    s1 = new() |> add(1, 1)
    s2 = new()

    s3 = merge(s1, s2)
    assert member?(s3, 1)

    s3 = merge(s2, s1)
    assert member?(s3, 1)
  end

  test "merge identical entries but different clocks" do
    s1 = new() |> add(1, 1)
    s2 = new() |> add(1, 2)
    s3 = merge(s1, s2)
    assert member?(s3, 1)
    assert s3.entries == %{1 => %{1 => 1, 2 => 1}}
  end

  test "remove occurred in future" do
    s1 =
      new()
      |> add(1, 1)
      |> apply_remove(2, VectorClock.new() |> VectorClock.increment(2, 2))

    s2 =
      new()
      |> add(2, 2)
      |> apply_remove(1, VectorClock.new() |> VectorClock.increment(1, 2))
      |> apply_remove(1, VectorClock.new() |> VectorClock.increment(2, 2))

    s3 = merge(s1, s2)
    assert get(s3) == MapSet.new()

    s1 = add(s1, 1, 1)
    s2 = add(s2, 2, 2)
    s3 = merge(s1, s2)
    assert get(s3) == MapSet.new()

    s1 = add(s1, 1, 1)
    s2 = add(s2, 2, 2)
    s3 = merge(s1, s2)
    assert get(s3) == MapSet.new([1, 2])
  end
end

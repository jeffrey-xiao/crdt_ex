defmodule Crdt.TwoPSetTest do
  use ExUnit.Case
  import Crdt.TwoPSet
  alias Crdt.{GSet, TwoPSet}
  doctest Crdt.TwoPSet

  test "new" do
    assert new() == %TwoPSet{a_set: GSet.new(), r_set: GSet.new()}
  end

  test "merge" do
    s1 = new() |> add(1) |> add(2) |> remove(1)
    s2 = new() |> add(1) |> add(3)
    s3 = merge(s1, s2)

    refute member?(s3, 1)
    assert member?(s3, 2)
    assert member?(s3, 3)
  end

  test "add" do
    set = new() |> add(1) |> add(1)
    assert member?(set, 1)
  end

  test "remove" do
    set = new() |> remove(1) |> add(1)
    assert member?(set, 1)

    set = new() |> add(1) |> remove(1)
    refute member?(set, 1)
  end

  test "get" do
    assert new() |> add(1) |> remove(1) |> add(2) |> get() == MapSet.new([2])
  end
end

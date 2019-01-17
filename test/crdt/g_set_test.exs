defmodule Crdt.GSetTest do
  use ExUnit.Case
  import Crdt.GSet
  doctest Crdt.GSet

  test "new" do
    assert new() == MapSet.new()
  end

  test "merge" do
    s1 = new() |> add(1) |> add(2)
    s2 = new() |> add(2) |> add(3)
    s3 = merge(s1, s2)

    assert member?(s3, 1)
    assert member?(s3, 2)
    assert member?(s3, 3)
  end

  test "add" do
    set = new() |> add(1) |> add(1)
    assert member?(set, 1)
  end
end

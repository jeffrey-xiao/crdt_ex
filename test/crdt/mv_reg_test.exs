defmodule Crdt.MVRegTest do
  use ExUnit.Case
  import Crdt.MVReg
  doctest Crdt.MVReg

  test "new" do
    assert new() == []
  end

  test "merge" do
    reg = merge(new() |> update(1, 1), new() |> update(2, 2))
    assert reg |> get() == MapSet.new([1, 2])

    reg = merge(new() |> update(1, 1), new() |> update(2, 1))
    assert reg |> get() == MapSet.new([1])

    reg = merge(new() |> update(1, 1), new() |> update(1, 2) |> update(1, 2))
    assert reg |> get() == MapSet.new([2])
  end

  test "update" do
    reg = merge(new() |> update(1, 1), new() |> update(2, 2)) |> update(1, 3)
    assert reg |> get() == MapSet.new([3])
  end
end

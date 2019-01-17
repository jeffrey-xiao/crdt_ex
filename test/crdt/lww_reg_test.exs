defmodule Crdt.LWWRegTest do
  use ExUnit.Case
  import Crdt.LWWReg
  alias Crdt.LWWReg
  doctest Crdt.LWWReg

  test "new" do
    assert new(1, 2) == %LWWReg{value: 1, timestamp: 2}
  end

  test "update" do
    assert new(1, 2) |> update(2, 1) |> get() == 1
    assert new(1, 1) |> update(2, 2) |> get() == 2
    assert_raise RuntimeError, fn -> new(1, 1) |> update(2, 1) end
  end

  test "merge" do
    assert merge(new(1, 2), new(2, 1)) |> get() == 1
    assert merge(new(1, 1), new(2, 2)) |> get() == 2
    assert_raise RuntimeError, fn -> merge(new(1, 1), new(2, 1)) end
  end
end

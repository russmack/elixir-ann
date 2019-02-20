defmodule OperationOrTest do

  use ExUnit.Case, async: true

  doctest OperationOr

  test "greets the world" do
    # assert OperationOr.hello() == :world

    assert :world == :world
  end


  # `setup` is called before each test is run
  setup do
    # none
    :ok  # The `setup` callback must return :ok
  end


  test "count list" do
    assert length([]) == 0
    assert length([7]) == 1
    assert length([7, 8, 9]) == 3
  end

  test "get item at index" do
    assert Enum.fetch([], 1) == :error
    assert Enum.fetch([1, 2, 3], -1) == {:ok, 3}
    assert Enum.fetch([1, 2, 3, 4, 5], 3) == {:ok, 4}
  end
end

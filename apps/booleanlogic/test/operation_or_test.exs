defmodule OperationOrTest do
  use ExUnit.Case
  doctest OperationOr

  test "greets the world" do
    assert OperationOr.hello() == :world
  end
end

ExUnit.start()

defmodule ListExtTest do

    use ExUnit.Case, async: true

    # `setup` is called before each test is run
    setup do
        # none
        :ok  # The `setup` callback must return :ok
    end

    test "count list" do
        assert ListExt.count([]) == 0
        assert ListExt.count([7]) == 1
        assert ListExt.count([7, 8, 9]) == 3
    end

    test "get item at index" do
        assert ListExt.get_at([], 1) == -1
        assert ListExt.get_at([1, 2, 3], -1) == -1
        assert ListExt.get_at([1, 2, 3, 4, 5], 3) == 4
    end
end
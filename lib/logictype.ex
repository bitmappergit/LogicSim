defmodule LogicType do
  defmodule Internal do
    # fixme: needs to work when used recusively, see Recursive.rXor for more
    def xor(a, b) do
      case {a, b} do
        {true, true} -> false
        {false, false} -> false
        {_, _} -> true
      end
    end
  end

  defmodule Recursive do
    def rAnd(list) do
      cond do
        Enum.at(list, 0) and Enum.at(list, 1) ->
          Enum.reduce(list,
            fn x, acc ->
              x and acc
            end)
        true ->
          false
      end
    end

    def rOr(list) do
      Enum.reduce(list,
        fn x, acc ->
          x or acc
        end)
    end

    # fixme: bug with improper xor implementation
    # LogicType.Recursive.rXor([true, true, true]) should NOT return true, but does because:
    # xor(true, true) -> false
    # and
    # xor(xor(true, true), true) -> xor(false, true) -> true
    # which is incorrect
    def rXor(list) do
      Enum.reduce(list,
        fn x, acc ->
          Internal.xor(x, acc)
        end)
    end
  end
end
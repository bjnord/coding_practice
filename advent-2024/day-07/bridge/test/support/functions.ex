defmodule Bridge.TestSupport do
  @spec string_op_concat(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def string_op_concat(a, b) when a >= 0 and b >= 0 do
    "#{a}#{b}"
    |> String.to_integer()
  end
end

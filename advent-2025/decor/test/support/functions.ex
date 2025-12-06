defmodule Decor.TestSupport do
  def string_n_digits(n) do
    Integer.to_string(n)
    |> String.length()
  end
end

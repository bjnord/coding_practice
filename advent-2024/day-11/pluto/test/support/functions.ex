defmodule Pluto.TestSupport do
  def string_divide(n) do
    s = Integer.to_string(n)
    length = String.length(s)
    half_length = div(length, 2)
    {
      String.slice(s, 0..(half_length - 1)) |> String.to_integer(),
      String.slice(s, half_length..(length - 1)) |> String.to_integer(),
    }
  end

  def string_n_digits(n) do
    Integer.to_string(n)
    |> String.length()
  end
end

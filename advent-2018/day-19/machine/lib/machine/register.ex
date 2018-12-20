defmodule Machine.Register do
  @moduledoc """
  Register behavior for `Machine`.
  """

  @doc """
  Create a new register set.

  ## Examples

  iex> Machine.Register.new()
  %{
    :size => 6, :ip => nil,
    0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0
  }

  iex> Machine.Register.new(5, [1, 2, 3, :five])
  %{
    :size => 5, :ip => nil,
    0 => 1, 1 => 2, 2 => 3, 3 => 0, 4 => 0
  }
  """
  def new(size \\ 6, values \\ []) do
    if size < 4 do
      raise ArgumentError, "size must be at least 4"
    end
    1..size
    |> Enum.reduce({%{:size => size, :ip => nil}, values}, fn (c, {reg, values}) ->
      case values do
        [value | values] when is_integer(value) ->
          {Map.put(reg, c-1, value), values}
        _ ->
          {Map.put(reg, c-1, 0), values}
      end
    end)
    |> elem(0)
  end

  @doc """
  Set register value.

  ## Example

  iex> reg = Machine.Register.new(4, [10, 9, 1, 7])
  iex> Machine.Register.set(reg, 2, 8)
  %{
    :size => 4, :ip => nil,
    0 => 10, 1 => 9, 2 => 8, 3 => 7
  }
  """
  def set(reg, key, value) do
    Map.replace!(reg, key, value)
  end

  @doc """
  Dump register values.
  """
  def dump_reg(reg, opts \\ []) do
    if (opts[:ip]) do
      label = if reg[:ip], do: "IP(R#{reg[:ip]}):", else: "    IP:"
      IO.write(label <> String.pad_leading(Integer.to_string(opts[:ip]), 6, "0") <> "  ")
    end
    0..reg[:size]-1
    |> Enum.map(fn (i) ->
      if (i == reg[:ip]) do
        IO.write("  R#{i}=------")
      else
        IO.write("  R#{i}=" <> String.pad_leading(Integer.to_string(reg[i]), 6, "0"))
      end
    end)
    IO.write("\n")
    reg
  end

  def dump_bound_ip_reg(reg) do
    IO.write("               ")
    if reg[:ip] > 0 do
      0..reg[:ip]-1
      |> Enum.map(fn (_i) -> IO.write("           ") end)
    end
    IO.write("  R#{reg[:ip]}=" <> String.pad_leading(Integer.to_string(reg[reg[:ip]]), 6, "0"))
    IO.write("\n")
    reg
  end
end

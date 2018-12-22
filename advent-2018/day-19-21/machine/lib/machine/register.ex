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
      ip = format_i(opts[:ip], opts)
      IO.write("#{label}#{ip}  ")
    end
    0..reg[:size]-1
    |> Enum.map(fn (i) ->
      if (i == reg[:ip]) do
        dash = format_i_pad("-", opts)
        IO.write("  R#{i}=#{dash}")
      else
        r_val = format_i(reg[i], opts)
        IO.write("  R#{i}=#{r_val}")
      end
    end)
    IO.write("\n")
    reg
  end

  def dump_bound_ip_reg(reg, opts \\ []) do
    # 7 spaces is width of "IP(Rx):" label, and 2 trailing separation
    IO.write("         " <> format_i_pad(" ", opts))
    if reg[:ip] > 0 do
      0..reg[:ip]-1
      |> Enum.map(fn (_i) ->
        # 3 spaces is width of "Rx=" label, and 2 leading separation
        IO.write("     " <> format_i_pad(" ", opts))
      end)
    end
    r_val = format_i(reg[reg[:ip]], opts)
    IO.write("  R#{reg[:ip]}=#{r_val}\n")
    reg
  end

  def format_i(i, opts \\ []) do
    {base, lead, width} = i_format(opts)
    n_pad = width - String.length(lead)
    num_s =
      Integer.to_string(i, base)
      |> String.upcase()
      |> String.pad_leading(n_pad, "0")
    "#{lead}#{num_s}"
  end

  def format_i_pad(ch, opts \\ []) do
    {_, _, width} = i_format(opts)
    String.pad_leading("", width, ch)
  end

  def format_r(i, opts \\ []) do
    {base, lead, _} = i_format(opts)
    num_s = Integer.to_string(i, base)
    "#{lead}#{num_s}"
  end

  defp i_format(opts) do
    case opts[:numeric] do
      "dec" -> {10, "", 6}
      "oct" -> {8, "o", 8}
      _     -> {16, "x", 7}
    end
  end
end

defmodule Wire do
  @moduledoc """
  Documentation for `Wire`.
  """

  import Bitwise
  import History.CLI
  require Logger
  import Wire.Parser

  def eval(diagram) do
    Map.keys(diagram)
    |> Enum.filter(&z_wire?/1)
    |> build_queue(diagram)
    |> then(fn queue -> {%{}, queue} end)
    |> eval_queue(diagram)
    |> reduce_value()
  end

  defp build_queue(z_wires, diagram) do
    z_wires
    |> Enum.reduce([], fn z_wire, queue ->
      add_to_queue(queue, z_wire, diagram)
    end)
  end

  defp add_to_queue(queue, wire = rhs, diagram) when is_binary(rhs) do
    rhs = Map.get(diagram, wire)
    add_to_queue([wire | queue], rhs, diagram)
  end
  defp add_to_queue(queue, {wire1, _gate, wire2} = _rhs, diagram) do
    add_to_queue(queue, wire1, diagram)
    |> add_to_queue(wire2, diagram)
  end
  defp add_to_queue(queue, _rhs, _diagram), do: queue

  defp eval_queue({values, []}, _diagram), do: values
  defp eval_queue({values, [item | queue]}, diagram) do
    value = eval_item(values, Map.get(diagram, item))
    next = {Map.put(values, item, value), queue}
    eval_queue(next, diagram)
  end

  defp eval_item(values, wire = rhs) when is_atom(rhs) do
    Map.get(values, wire)
  end
  defp eval_item(values, {wire1, gate, wire2} = _rhs) do
    value1 = Map.get(values, wire1)
    value2 = Map.get(values, wire2)
    expr(value1, gate, value2)
  end
  defp eval_item(_values, value = _rhs), do: value

  defp expr(v1, :AND, v2), do: v1 &&& v2
  defp expr(v1, :OR, v2), do: v1 ||| v2
  defp expr(v1, :XOR, v2), do: bxor(v1, v2)

  def reduce_value(values) do
    Map.keys(values)
    |> Enum.filter(&z_wire?/1)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.reduce(0, fn wire, acc ->
      acc * 2 + Map.get(values, wire)
    end)
  end

  def swaps(diagram) do
    catalog =
      new_catalog()
      |> add_halfadds_to_catalog(diagram)
      |> add_carries_to_catalog(diagram)
      |> dbg()
    []
  end

  defp new_catalog(), do: {%{}, %{}}

  def add_halfadds_to_catalog(catalog, diagram) do
    xy_gates(diagram, :XOR)
    |> Enum.reduce(catalog, fn {i, wire}, catalog ->
      if wire != nil do
        add_to_catalog(catalog, {wire_name("halfadd_", i), wire})
      else
        catalog
      end
    end)
  end

  def add_carries_to_catalog(catalog, diagram) do
    xy_gates(diagram, :AND)
    |> Enum.reduce(catalog, fn {i, wire}, catalog ->
      if wire != nil do
        add_to_catalog(catalog, {wire_name("carry_", i), wire})
      else
        catalog
      end
    end)
  end

  def add_to_catalog({fwd, rev}, {a_wire, b_wire}) do
    {
      Map.put_new(fwd, a_wire, b_wire),
      Map.put_new(rev, b_wire, a_wire),
    }
  end

  def xy_gates(diagram, gate) do
    ww = word_width(diagram)
    0..(ww - 1)
    |> Enum.map(fn i ->
      Enum.find(diagram, fn {k, v} ->
        k_ok =
          if (i == 0) && (gate == :XOR) do
            z_wire?(k)
          else
            !z_wire?(k)
          end
        v_ok =
          (v == {wire_name("x", i), gate, wire_name("y", i)})
        k_ok && v_ok
      end)
      |> then(&(wire_or_nil(i, &1)))
    end)
  end

  def wire_name(a, i) do
    ii =
      Integer.to_string(i)
      |> String.pad_leading(2, "0")
    "#{a}#{ii}"
  end

  defp wire_or_nil(i, nil), do: {i, nil}
  defp wire_or_nil(i, {k, _v}), do: {i, k}

  defp word_width(diagram) do
    nx = count(diagram, &x_wire?/1)
    ny = count(diagram, &y_wire?/1)
    if nx != ny do
      raise "mismatch nx=#{nx} <> ny=#{ny}"
    end
    Logger.debug("word_width: x=#{nx} y=#{ny} z=#{nx + 1}")
    nx
  end

  defp count(diagram, f) do
    Map.keys(diagram)
    |> Enum.count(f)
  end

  defp x_wire?(wire), do: wire_in_range?(wire, "x00", "x99")
  defp y_wire?(wire), do: wire_in_range?(wire, "y00", "y99")
  defp z_wire?(wire), do: wire_in_range?(wire, "z00", "z99")
  defp wire_in_range?(w, a, b) when w >= a and w <= b, do: true
  defp wire_in_range?(_w, _a, _b), do: false

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Wire.eval()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Wire.swaps()
    |> Enum.join(",")
    |> IO.inspect(label: "Part 2 answer is")
  end
end

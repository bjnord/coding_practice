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

  def dump(path, diagram, {_f_mapping, mapping}, opts \\ []) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, "--\n")
    Map.keys(diagram)
    |> Enum.filter(&z_wire?/1)
    |> Enum.sort()
    |> Enum.reduce(%{}, fn wire, seen ->
      IO.binwrite(f, "#{wire}\n")
      dump_subtree(f, diagram, Map.get(diagram, wire), 3, mapping, seen, opts)
    end)
    IO.binwrite(f, "--\n")
    File.close(f)
  end

  defp dump_subtree(f, _diagram, value = rhs, indent, _mapping, seen, _opts) when is_integer(rhs) do
    Integer.to_string(value)
    |> String.pad_leading(indent, " ")
    |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
    seen
  end
  defp dump_subtree(f, diagram, {wire1, gate, wire2} = _rhs, indent, mapping, seen, opts) do
    {deob_wire1, deob_len1} = deobfuscate_wire(mapping, wire1, opts)
    {deob_wire2, deob_len2} = deobfuscate_wire(mapping, wire2, opts)
    {{wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2}} =
      flop_ops({wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2})
    #
    seen =
      if Map.get(seen, wire1) do
        String.pad_leading(deob_wire1, deob_len1 + indent, " ")
        |> then(fn s -> s <> " #{gate}" end)
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen
      else
        String.pad_leading(deob_wire1, deob_len1 + indent, " ")
        |> then(fn s -> s <> " #{gate}" end)
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen = Map.put(seen, wire1, true)
        dump_subtree(f, diagram, Map.get(diagram, wire1), indent + 3, mapping, seen, opts)
      end
    #
    seen =
      if Map.get(seen, wire2) do
        String.pad_leading(deob_wire2, deob_len2 + indent, " ")
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen
      else
        String.pad_leading(deob_wire2, deob_len2 + indent, " ")
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen = Map.put(seen, wire2, true)
        dump_subtree(f, diagram, Map.get(diagram, wire2), indent + 3, mapping, seen, opts)
      end
    #
    seen
  end

  defp flop_ops({wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2}) do
    cond do
      String.slice(deob_wire1, 0..9) == "halfcarry_" && String.slice(deob_wire2, 0..7) == "halfadd_" ->
        {{wire2, deob_wire2, deob_len2}, {wire1, deob_wire1, deob_len1}}
      String.slice(deob_wire1, 0..9) == "fullcarry_" && String.slice(deob_wire2, 0..7) == "halfadd_" ->
        {{wire2, deob_wire2, deob_len2}, {wire1, deob_wire1, deob_len1}}
      String.slice(deob_wire1, 0..9) == "halfcarry_" && String.slice(deob_wire2, 0..9) == "fullcarop_" ->
        {{wire2, deob_wire2, deob_len2}, {wire1, deob_wire1, deob_len1}}
      true ->
        {{wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2}}
    end
  end

  defp deobfuscate_wire(mapping, wire, opts) do
    deob_wire =
      cond do
        xyz_wire?(wire) ->
          Map.get(mapping, wire, wire)
        opts[:both] ->
          deob_wire = Map.get(mapping, wire, wire)
          if deob_wire != wire do
            "#{deob_wire} [#{wire}]"
          else
            "? [#{wire}]"
          end
        true ->
          Map.get(mapping, wire, wire)
      end
    {deob_wire, deob_length(deob_wire)}
  end

  defp deob_length(w), do: String.length(w)

  def generate_adder(ww) do
    0..(ww - 1)
    |> Enum.reduce(%{}, fn i, diagram ->
      Map.put(diagram, wire_name("x", i), 1)
      |> Map.put(wire_name("y", i), 1)
    end)
    |> generate_adder(0, ww)
  end

  defp generate_adder(diagram, i, ww) when i == ww, do: diagram
  defp generate_adder(diagram, 0, ww) do
    Map.put(diagram, "z00", {"x00", :XOR, "y00"})
    |> Map.put("halfcarry_00", {"x00", :AND, "y00"})
    |> generate_adder(1, ww)
  end
  defp generate_adder(diagram, i, ww) do
    wires = adder_wires(i)
    # halfadd = XOR(a, b)
    Map.put(diagram, wires[:halfadd], {wires[:a], :XOR, wires[:b]})
    # halfcarry = AND(a, b)
    |> Map.put(wires[:halfcarry], {wires[:a], :AND, wires[:b]})
    # fulladd = XOR(halfadd, fullcarry-in)
    |> Map.put(wires[:z], {wires[:halfadd], :XOR, wires[:fullcarry_in]})
    # fullcarop = AND(halfadd, fullcarry-in)  [intermediate step for fullcarry]
    |> Map.put(wires[:fullcarop], {wires[:halfadd], :AND, wires[:fullcarry_in]})
    # fullcarry-out = OR(fullcarop, halfcarry)
    |> Map.put(wires[:fullcarry], {wires[:fullcarop], :OR, wires[:halfcarry]})
    |> generate_adder(i + 1, ww)
  end

  defp adder_wires(i) do
    [
      {:a, wire_name("x", i)},
      {:b, wire_name("y", i)},
      {:halfadd, wire_name("halfadd_", i)},
      {:halfcarry, wire_name("halfcarry_", i)},
      {:fullcarry_in, fullcarry_in_wire_name(i)},
      {:z, wire_name("z", i)},
      {:fullcarop, wire_name("fullcarop_", i)},
      {:fullcarry, wire_name("fullcarry_", i)},
    ]
  end

  def fullcarry_in_wire_name(1), do: wire_name("halfcarry_", 0)
  def fullcarry_in_wire_name(i), do: wire_name("fullcarry_", i - 1)

  def swapped_wires(diagram) do
    swap_list(diagram)
    |> Enum.map(fn {w1, w2} -> [w1, w2] end)
    |> List.flatten()
    |> Enum.sort
  end

  # TODO find these algorithmically :)
  #      (I did it by diff'ing the puzzle input with a generated adder)
  def swap_list(_diagram) do
    [
      {"z10", "vcf"},
      {"fhg", "z17"},
      {"dvb", "fsq"},
      {"tnc", "z39"}
    ]
  end

  def dump_adders(diagram) do
    diagram = swap(diagram, swap_list(diagram))
    catalog =
      new_catalog()
      |> add_halfadds_to_catalog(diagram)
      |> add_halfcarries_to_catalog(diagram)
      |> add_fulls_to_catalog(diagram)
    dump("log/dump.out", diagram, catalog, both: true)
    #
    adder_diagram = generate_adder(45)  # TODO derive `45` from `diagram`
    dump("log/adder.out", adder_diagram, {%{}, %{}})
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

  def add_halfcarries_to_catalog(catalog, diagram) do
    xy_gates(diagram, :AND)
    |> Enum.reduce(catalog, fn {i, wire}, catalog ->
      if wire != nil do
        add_to_catalog(catalog, {wire_name("halfcarry_", i), wire})
      else
        catalog
      end
    end)
  end

  def add_fulls_to_catalog(catalog, diagram) do
    ww = word_width(diagram)
    1..(ww - 1)
    |> Enum.reduce(catalog, fn i, catalog ->
      full_gates(catalog, diagram, i)
      |> Enum.reduce(catalog, fn {wire_name, wire}, catalog ->
        if wire != nil do
          add_to_catalog(catalog, {wire_name, wire})
        else
          catalog
        end
      end)
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

  def full_gates(catalog, diagram, i) do
    fulladd =
      Enum.find(diagram, fn {k, v} ->
        carry_wire_name = fullcarry_wire_name(i)
        k_match = !xyz_wire?(k)
        deob_v = deobfuscate_rhs(catalog, v)
        v_match1 = (deob_v == {wire_name("halfadd_", i), :XOR, carry_wire_name})
        v_match2 = (deob_v == {carry_wire_name, :XOR, wire_name("halfadd_", i)})
        k_match && (v_match1 || v_match2)
      end)
      |> then(&(wire_or_nil(wire_name("fulladd_", i), &1)))
    #
    {_, fco_name} = fullcarry_op =
      Enum.find(diagram, fn {k, v} ->
        carry_wire_name = fullcarry_wire_name(i)
        k_match = !xyz_wire?(k)
        deob_v = deobfuscate_rhs(catalog, v)
        v_match1 = (deob_v == {wire_name("halfadd_", i), :AND, carry_wire_name})
        v_match2 = (deob_v == {carry_wire_name, :AND, wire_name("halfadd_", i)})
        k_match && (v_match1 || v_match2)
      end)
      |> then(&(wire_or_nil(wire_name("fullcarop_", i), &1)))
    #
    fullcarry =
      Enum.find(diagram, fn {k, v} ->
        k_match = !xyz_wire?(k)
        deob_v = deobfuscate_rhs(catalog, v)
        v_match1 = (deob_v == {fco_name, :OR, wire_name("halfcarry_", i)})
        v_match2 = (deob_v == {wire_name("halfcarry_", i), :OR, fco_name})
        k_match && (v_match1 || v_match2)
      end)
      |> then(&(wire_or_nil(wire_name("fullcarry_", i), &1)))
    #
    [fulladd, fullcarry_op, fullcarry]
  end

  defp fullcarry_wire_name(1), do: wire_name("halfcarry_", 0)
  defp fullcarry_wire_name(i), do: wire_name("fullcarry_", i - 1)

  #defp debug_key(k, v, deob_v, i, matches) do
  #  if k == "htw" do
  #    {k, v}
  #    |> IO.inspect(label: "htw {k, v}")
  #    {deob_v, i}
  #    |> IO.inspect(label: "htw {deob_v, i}")
  #    matches
  #    |> IO.inspect(label: "htw matches")
  #  end
  #end

  defp deobfuscate_rhs(_catalog, value = _rhs) when is_integer(value), do: value
  defp deobfuscate_rhs({_f_mapping, mapping} = _catalog, {wire1, gate, wire2} = _rhs) do
    {
      Map.get(mapping, wire1, wire1),
      gate,
      Map.get(mapping, wire2, wire2),
    }
  end

  def wire_name(a, i) do
    ii =
      Integer.to_string(i)
      |> String.pad_leading(2, "0")
    "#{a}#{ii}"
  end

  defp wire_or_nil(w, nil), do: {w, nil}
  defp wire_or_nil(w, {k, _v}), do: {w, k}

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
  defp xyz_wire?(wire), do: wire_in_range?(wire, "x00", "z99")
  defp wire_in_range?(w, a, b) when w >= a and w <= b, do: true
  defp wire_in_range?(_w, _a, _b), do: false

  def swap(diagram, swaplist) do
    swaplist
    |> Enum.reduce(diagram, fn {from, to}, diagram ->
      trans = Map.get(diagram, from)
      Map.put(diagram, from, Map.get(diagram, to))
      |> Map.put(to, trans)
    end)
  end

  def mermaid(path, diagram) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, "graph TD\n")
    Map.keys(diagram)
    |> Enum.each(fn wire ->
      mermaid_node(f, wire, Map.get(diagram, wire))
    end)
    File.close(f)
  end

  def mermaid_node(f, wire, {wire1, gate, wire2}) do
    IO.binwrite(f, "#{wire}-->#{wire}#{gate}\n")
    IO.binwrite(f, "#{wire}#{gate}-->#{wire1}\n")
    IO.binwrite(f, "#{wire}#{gate}-->#{wire2}\n")
  end
  def mermaid_node(_f, _wire, _value), do: :ok

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
    if opts[:verbose], do: dumps(input_path)
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
    |> Wire.swapped_wires()
    |> Enum.join(",")
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Dump puzzle input adder and generated adder.
  """
  def dumps(input_path) do
    parse_input_file(input_path)
    |> Wire.dump_adders()
  end
end

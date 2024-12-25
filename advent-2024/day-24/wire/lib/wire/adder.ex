defmodule Wire.Adder do
  @moduledoc """
  Documentation for `Wire.Adder`.
  """

  import Wire, only: [wire_name: 2]

  def generate(ww) do
    0..ww
    |> Enum.reduce(%{}, fn i, diagram ->
      Map.put(diagram, wire_name("x", i), 1)
      |> Map.put(wire_name("y", i), 1)
    end)
    |> generate(0, ww)
  end

  defp generate(diagram, i, ww) when i == ww do
    diagram
    |> Map.put(wire_name("z", i), {wire_name("fullcarop_", i - 1), :OR, wire_name("halfcarry_", i - 1)})
  end
  defp generate(diagram, 0, ww) do
    diagram
    |> Map.put("z00", {"x00", :XOR, "y00"})
    |> Map.put("halfcarry_00", {"x00", :AND, "y00"})
    |> generate(1, ww)
  end
  defp generate(diagram, i, ww) do
    wires = adder_wires(i)
    # halfadd = XOR(a, b)
    diagram
    |> Map.put(wires[:halfadd], {wires[:a], :XOR, wires[:b]})
    # halfcarry = AND(a, b)
    |> Map.put(wires[:halfcarry], {wires[:a], :AND, wires[:b]})
    # fulladd = XOR(halfadd, fullcarry-in)
    |> Map.put(wires[:z], {wires[:halfadd], :XOR, wires[:fullcarry_in]})
    # fullcarop = AND(halfadd, fullcarry-in)  [intermediate step for fullcarry]
    |> Map.put(wires[:fullcarop], {wires[:halfadd], :AND, wires[:fullcarry_in]})
    # fullcarry-out = OR(fullcarop, halfcarry)
    |> Map.put(wires[:fullcarry], {wires[:fullcarop], :OR, wires[:halfcarry]})
    |> generate(i + 1, ww)
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

  defp fullcarry_in_wire_name(1), do: wire_name("halfcarry_", 0)
  defp fullcarry_in_wire_name(i), do: wire_name("fullcarry_", i - 1)
end

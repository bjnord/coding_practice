defmodule WireTest do
  use ExUnit.Case
  doctest Wire

  import Wire.Parser

  describe "puzzle example" do
    setup do
      [
        inputs: [
          """
          x00: 1
          x01: 1
          x02: 1
          y00: 0
          y01: 1
          y02: 0

          x00 AND y00 -> z00
          x01 XOR y01 -> z01
          x02 OR y02 -> z02
          """,
          """
          x00: 1
          x01: 0
          x02: 1
          x03: 1
          x04: 0
          y00: 1
          y01: 1
          y02: 1
          y03: 1
          y04: 1

          ntg XOR fgs -> mjb
          y02 OR x01 -> tnw
          kwq OR kpj -> z05
          x00 OR x03 -> fst
          tgd XOR rvg -> z01
          vdt OR tnw -> bfw
          bfw AND frj -> z10
          ffh OR nrd -> bqk
          y00 AND y03 -> djm
          y03 OR y00 -> psh
          bqk OR frj -> z08
          tnw OR fst -> frj
          gnj AND tgd -> z11
          bfw XOR mjb -> z00
          x03 OR x00 -> vdt
          gnj AND wpb -> z02
          x04 AND y00 -> kjc
          djm OR pbm -> qhw
          nrd AND vdt -> hwm
          kjc AND fst -> rvg
          y04 OR y02 -> fgs
          y01 AND x02 -> pbm
          ntg OR kjc -> kwq
          psh XOR fgs -> tgd
          qhw XOR tgd -> z09
          pbm OR djm -> kpj
          x03 XOR y03 -> ffh
          x00 XOR y04 -> ntg
          bfw OR bqk -> z06
          nrd XOR fgs -> wpb
          frj XOR qhw -> z04
          bqk OR frj -> z07
          y03 OR x01 -> nrd
          hwm AND bqk -> z03
          tgd XOR rvg -> z12
          tnw OR pbm -> gnj
          """,
        ],
        exp_outputs: [
          0b100,
          0b0011111101000,
        ],
        input_for_swap: """
        x00: 1
        x01: 0
        x02: 1
        x03: 1
        x04: 0
        y00: 1
        y01: 1
        y02: 1
        y03: 1
        y04: 1

        ntg XOR fgs -> mjb
        y02 OR x01 -> tnw
        kwq OR kpj -> z05
        x00 OR x03 -> fst
        tgd XOR rvg -> z01
        vdt OR tnw -> bfw
        bfw AND frj -> z10
        ffh OR nrd -> bqk
        y00 AND y03 -> djm
        y03 OR y00 -> psh
        bqk OR frj -> z08
        tnw OR fst -> frj
        gnj AND tgd -> z11
        bfw XOR mjb -> z00
        x03 OR x00 -> vdt
        gnj AND wpb -> z02
        x04 AND y00 -> kjc
        djm OR pbm -> qhw
        nrd AND vdt -> hwm
        kjc AND fst -> rvg
        y04 OR y02 -> fgs
        y01 AND x02 -> pbm
        ntg OR kjc -> kwq
        psh XOR fgs -> tgd
        qhw XOR tgd -> z09
        pbm OR djm -> kpj
        x03 XOR y03 -> ffh
        x00 XOR y04 -> ntg
        bfw OR bqk -> z06
        nrd XOR fgs -> wpb
        frj XOR qhw -> z04
        bqk OR frj -> z07
        y03 OR x01 -> nrd
        hwm AND bqk -> z03
        tgd XOR rvg -> z12
        tnw OR pbm -> gnj
        """,
        swaplist: [
          {"z00", "pbm"},
          {"nrd", "fst"},
        ],
        exp_swap_diagram: %{
            "x00" => 1,
            "x01" => 0,
            "x02" => 1,
            "x03" => 1,
            "x04" => 0,
            "y00" => 1,
            "y01" => 1,
            "y02" => 1,
            "y03" => 1,
            "y04" => 1,
            "bfw" => {"vdt", :OR, "tnw"},
            "bqk" => {"ffh", :OR, "nrd"},
            "djm" => {"y00", :AND, "y03"},
            "ffh" => {"x03", :XOR, "y03"},
            "fgs" => {"y04", :OR, "y02"},
            "frj" => {"tnw", :OR, "fst"},
            "nrd" => {"x00", :OR, "x03"},   # fst
            "gnj" => {"tnw", :OR, "pbm"},
            "hwm" => {"nrd", :AND, "vdt"},
            "kjc" => {"x04", :AND, "y00"},
            "kpj" => {"pbm", :OR, "djm"},
            "kwq" => {"ntg", :OR, "kjc"},
            "mjb" => {"ntg", :XOR, "fgs"},
            "fst" => {"x01", :OR, "y03"},   # nrd
            "ntg" => {"x00", :XOR, "y04"},
            "z00" => {"x02", :AND, "y01"},  # pbm
            "psh" => {"y03", :OR, "y00"},
            "qhw" => {"djm", :OR, "pbm"},
            "rvg" => {"kjc", :AND, "fst"},
            "tgd" => {"psh", :XOR, "fgs"},
            "tnw" => {"x01", :OR, "y02"},
            "vdt" => {"x03", :OR, "x00"},
            "wpb" => {"nrd", :XOR, "fgs"},
            "pbm" => {"bfw", :XOR, "mjb"},  # z00
            "z01" => {"tgd", :XOR, "rvg"},
            "z02" => {"gnj", :AND, "wpb"},
            "z03" => {"hwm", :AND, "bqk"},
            "z04" => {"frj", :XOR, "qhw"},
            "z05" => {"kwq", :OR, "kpj"},
            "z06" => {"bfw", :OR, "bqk"},
            "z07" => {"bqk", :OR, "frj"},
            "z08" => {"bqk", :OR, "frj"},
            "z09" => {"qhw", :XOR, "tgd"},
            "z10" => {"bfw", :AND, "frj"},
            "z11" => {"gnj", :AND, "tgd"},
            "z12" => {"tgd", :XOR, "rvg"},
        },
      ]
    end

    test "evaluate diagrams to get output value", fixture do
      act_outputs = fixture.inputs
                    |> Enum.map(&parse_input_string/1)
                    |> Enum.map(&Wire.eval/1)
      assert act_outputs == fixture.exp_outputs
    end

    test "expected diagram after swaps", fixture do
      act_swap_diagram = fixture.input_for_swap
                         |> parse_input_string()
                         |> Wire.swap(fixture.swaplist)
      Wire.Mermaid.write_diagram(act_swap_diagram, "log/example.mmd")
      assert act_swap_diagram == fixture.exp_swap_diagram
    end
  end
end

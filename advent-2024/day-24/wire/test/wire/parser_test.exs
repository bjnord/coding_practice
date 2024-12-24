defmodule Wire.ParserTest do
  use ExUnit.Case
  doctest Wire.Parser, import: true

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
        exp_diagrams: [
          %{
            "x00" => 1,
            "x01" => 1,
            "x02" => 1,
            "y00" => 0,
            "y01" => 1,
            "y02" => 0,
            "z00" => {"x00", :AND, "y00"},
            "z01" => {"x01", :XOR, "y01"},
            "z02" => {"x02", :OR, "y02"},
          },
          %{
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
            "fst" => {"x00", :OR, "x03"},
            "gnj" => {"tnw", :OR, "pbm"},
            "hwm" => {"nrd", :AND, "vdt"},
            "kjc" => {"x04", :AND, "y00"},
            "kpj" => {"pbm", :OR, "djm"},
            "kwq" => {"ntg", :OR, "kjc"},
            "mjb" => {"ntg", :XOR, "fgs"},
            "nrd" => {"x01", :OR, "y03"},
            "ntg" => {"x00", :XOR, "y04"},
            "pbm" => {"x02", :AND, "y01"},
            "psh" => {"y03", :OR, "y00"},
            "qhw" => {"djm", :OR, "pbm"},
            "rvg" => {"kjc", :AND, "fst"},
            "tgd" => {"psh", :XOR, "fgs"},
            "tnw" => {"x01", :OR, "y02"},
            "vdt" => {"x03", :OR, "x00"},
            "wpb" => {"nrd", :XOR, "fgs"},
            "z00" => {"bfw", :XOR, "mjb"},
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
        ],
      ]
    end

    test "parser gets expected diagrams", fixture do
      act_diagrams = fixture.inputs
                     |> Enum.map(&parse_input_string/1)
      assert act_diagrams == fixture.exp_diagrams
    end
  end
end

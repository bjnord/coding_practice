defmodule Network.ParserTest do
  use ExUnit.Case
  doctest Network.Parser, import: true

  import Network.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        kh-tc
        qp-kh
        de-cg
        ka-co
        yn-aq
        qp-ub
        cg-tb
        vc-aq
        tb-ka
        wh-tc
        yn-cg
        kh-ub
        ta-co
        de-co
        tc-td
        tb-wq
        wh-td
        ta-ka
        td-qp
        aq-cg
        wq-ub
        ub-vc
        de-ta
        wq-aq
        wq-vc
        wh-yn
        ka-de
        kh-ta
        co-tc
        wh-qp
        tb-vc
        td-yn
        """,
        exp_connections: [
          {"kh", "tc"},
          {"qp", "kh"},
          {"de", "cg"},
          {"ka", "co"},
          {"yn", "aq"},
          {"qp", "ub"},
          {"cg", "tb"},
          {"vc", "aq"},
          {"tb", "ka"},
          {"wh", "tc"},
          {"yn", "cg"},
          {"kh", "ub"},
          {"ta", "co"},
          {"de", "co"},
          {"tc", "td"},
          {"tb", "wq"},
          {"wh", "td"},
          {"ta", "ka"},
          {"td", "qp"},
          {"aq", "cg"},
          {"wq", "ub"},
          {"ub", "vc"},
          {"de", "ta"},
          {"wq", "aq"},
          {"wq", "vc"},
          {"wh", "yn"},
          {"ka", "de"},
          {"kh", "ta"},
          {"co", "tc"},
          {"wh", "qp"},
          {"tb", "vc"},
          {"td", "yn"},
        ],
      ]
    end

    test "parser gets expected connections", fixture do
      act_connections = fixture.input
                        |> parse_input_string()
                        |> Enum.to_list()
      assert act_connections == fixture.exp_connections
    end
  end
end

defmodule Cave.GraphTest do
  use ExUnit.Case
  doctest Cave.Graph

  describe "puzzle example" do
    setup do
      [
        sm_input: """
        start-A
        start-b
        A-c
        A-b
        b-d
        A-end
        b-end
        """,
        exp_sm_graph: %{
          "start" => [{:big, "A"}, {:small, "b"}],
          "A" => [{:small, "start"}, {:small, "c"}, {:small, "b"}, {:end, "end"}],
          "b" => [{:small, "start"}, {:big, "A"}, {:small, "d"}, {:end, "end"}],
          "c" => [{:big, "A"}],
          "d" => [{:small, "b"}],
          "end" => [{:big, "A"}, {:small, "b"}],
        },
        exp_sm_paths: """
        start,A,b,A,c,A,end
        start,A,b,A,end
        start,A,b,end
        start,A,c,A,b,A,end
        start,A,c,A,b,end
        start,A,c,A,end
        start,A,end
        start,b,A,c,A,end
        start,b,A,end
        start,b,end
        """,
        md_input: """
        dc-end
        HN-start
        start-kj
        dc-start
        dc-HN
        LN-dc
        HN-end
        kj-sa
        kj-HN
        kj-dc
        """,
        exp_md_paths: """
        start,HN,dc,HN,end
        start,HN,dc,HN,kj,HN,end
        start,HN,dc,end
        start,HN,dc,kj,HN,end
        start,HN,end
        start,HN,kj,HN,dc,HN,end
        start,HN,kj,HN,dc,end
        start,HN,kj,HN,end
        start,HN,kj,dc,HN,end
        start,HN,kj,dc,end
        start,dc,HN,end
        start,dc,HN,kj,HN,end
        start,dc,end
        start,dc,kj,HN,end
        start,kj,HN,dc,HN,end
        start,kj,HN,dc,end
        start,kj,HN,end
        start,kj,dc,HN,end
        start,kj,dc,end
        """,
        lg_input: """
        fs-end
        he-DX
        fs-he
        start-DX
        pj-DX
        end-zg
        zg-sl
        zg-pj
        pj-he
        RW-he
        fs-DX
        pj-RW
        zg-RW
        start-pj
        he-WI
        zg-he
        pj-fs
        start-RW
        """,
        exp_lg_path_count: 226,
      ]
    end

    test "parser gets expected graph", fixture do
      assert Cave.Graph.parse_input_string(fixture.sm_input) == fixture.exp_sm_graph
    end
  end
end

defmodule Syntax.ParserTest do
  use ExUnit.Case
  doctest Syntax.Parser, import: true

  import Syntax.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        [({(<(())[]>[[{[]{<()<>>
        [(()[<>])]({[<{<<[]>>(
        {([(<{}[<>[]}>{[]{[(<()>
        (((({<>}<{<{<>}{[]{[]{}
        [[<[([]))<([[{}[[()]]]
        [{[{({}]{}}([{[{{{}}([]
        {<[[]]>}<{[{[{[]{()[[[]
        [<(<(<(<{}))><([]([]()
        <{([([[(<>()){}]>(<<{{
        <{([{{}}[<[[[<>{}]]]>[]]
        """,
        exp_entries: [
          '[({(<(())[]>[[{[]{<()<>>',
          '[(()[<>])]({[<{<<[]>>(',
          '{([(<{}[<>[]}>{[]{[(<()>',
          '(((({<>}<{<{<>}{[]{[]{}',
          '[[<[([]))<([[{}[[()]]]',
          '[{[{({}]{}}([{[{{{}}([]',
          '{<[[]]>}<{[{[{[]{()[[[]',
          '[<(<(<(<{}))><([]([]()',
          '<{([([[(<>()){}]>(<<{{',
          '<{([{{}}[<[[[<>{}]]]>[]]',
        ],
      ]
    end

    test "parser gets expected entries", fixture do
      act_entries = fixture.input
                    |> parse_input_string()
                    |> Enum.to_list()
      assert act_entries == fixture.exp_entries
    end
  end
end

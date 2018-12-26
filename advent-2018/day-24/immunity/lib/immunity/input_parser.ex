defmodule Immunity.InputParser do
  @moduledoc """
  Parse the Day 24 input file.

  The [NimbleParsec](https://hexdocs.pm/nimble_parsec/NimbleParsec.html)
  documentation is rather sparse;
  [this article by Stefan Lapers](https://stefan.lapers.be/posts/elixir-writing-an-expression-parser-with-nimble-parsec/)
  helped me remember
  [EBNF](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form)
  (another thing I haven't used since college) and learn how to translate
  it to NimbleParsec.
  """

  import NimbleParsec

  @doc ~S"""
  `<input> :== <army> "\\n" <army>`
  """
  defparsec :input,
    parsec(:army)
    |> ignore(string("\n"))
    |> parsec(:army)

  @doc """
  `<army> :== <army_name> <group> { <group> }`
  """
  defparsec :army,
    parsec(:army_name)
    |> parsec(:group)
    |> repeat(parsec(:group))
    |> tag(:army)

  ###
  # <ws> :== \s+
  #
  # TODO support tabs & other whitespace too (as \s does)
  ws = ascii_char(' ') |> repeat(ascii_char(' '))

  @doc ~S"""
  `<army_name> :== <army_word> { <ws> <army_word> } ":" "\\n"`

  ## Example

      iex> Immunity.InputParser.army_name("Immune System:\n")
      {:ok, [army_name: 'Immune System'], "", %{}, {2, 15}, 15}
  """
  defparsec :army_name,
    parsec(:army_word)
    |> repeat(ws |> parsec(:army_word))
    |> ignore(string(":"))
    |> ignore(string("\n"))
    |> tag(:army_name)

  ###
  # <ucletter> :== /[A-Z]/
  # <lcletter> :== /[a-z]/
  #
  ucletter = ascii_char([?A..?Z]) |> label("upper-case letter")
  lcletter = ascii_char([?a..?z]) |> label("lower-case letter")

  @doc """
  `<army_word> :== <ucletter> { <letter> }`

  ## Example

      iex> Immunity.InputParser.army_word("Immune")
      {:ok, 'Immune', "", %{}, {1, 0}, 6}
  """
  defparsec :army_word,
    ucletter
    |> repeat(lcletter)

  @doc ~S"""
  `<group> :== <units> <hp> <imm_weak> <damage> <initiative> "\\n"`

  ## Examples

      iex> Immunity.InputParser.group("989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3\n")
      {:ok, [group: [989, 1274, {:immunity, [:fire]}, {:weakness, [:bludgeoning, :slashing]}, 25, :slashing, 3]], "", %{}, {2, 144}, 144}

      iex> Immunity.InputParser.group("2777 units each with 7460 hit points (weak to fire; immune to slashing) with an attack that does 24 bludgeoning damage at initiative 7\n")
      {:ok, [group: [2777, 7460, {:weakness, [:fire]}, {:immunity, [:slashing]}, 24, :bludgeoning, 7]], "", %{}, {2, 135}, 135}
  """
  defparsec :group,
    parsec(:units)
    |> parsec(:hp)
    |> choice([parsec(:imm_weak), parsec(:no_imm_weak)])
    |> parsec(:damage)
    |> parsec(:initiative)
    |> ignore(string("\n"))
    |> tag(:group)

  @doc """
  `<units> :== <integer> <ws> "units" <ws>`

  ## Examples

      iex> Immunity.InputParser.units("989 units ")
      {:ok, [989], "", %{}, {1, 0}, 10}

      iex> Immunity.InputParser.units("zero units ")
      {:error, "expected integer", "zero units ", %{}, {1, 0}, 0}
  """
  defparsec :units,
    integer(min: 1)
    |> label("integer")
    |> ignore(ws)
    |> ignore(string("units"))
    |> ignore(ws)

  @doc """
  `<hp> :== "each" <ws> "with" <ws> <integer> <ws> "hit" <ws> "points" <ws>`

  ## Examples

      iex> Immunity.InputParser.hp("each with 1274 hit points ")
      {:ok, [1274], "", %{}, {1, 0}, 26}

      iex> Immunity.InputParser.hp("each with no hit points ")
      {:error, "expected integer", "no hit points ", %{}, {1, 0}, 10}
  """
  defparsec :hp,
    ignore(string("each"))
    |> ignore(ws)
    |> ignore(string("with"))
    |> ignore(ws)
    |> integer(min: 1)
    |> label("integer")
    |> ignore(ws)
    |> ignore(string("hit"))
    |> ignore(ws)
    |> ignore(string("points"))
    |> ignore(ws)

  @doc """
  ```
  <imm_weak> :== [ "("
                    <immunity> [ ";" <ws> <weakness> ] | <weakness> [ ";" <ws> <immunity> ]
                 ")" <ws> ]
  ```

  In the input, this whole term (including parentheses/whitespace) can
  be missing, or the contents (inside the parentheses) can be an immunity,
  a weakness, or both in either order (separated with a semicolon).

  But in the output, we always want to have :immunity and :weakness tuples,
  even if one or both lists are blank.

  ## Examples

      iex> Immunity.InputParser.imm_weak("(immune to fire) ")
      {:ok, [immunity: [:fire], weakness: []], "", %{}, {1, 0}, 17}

      iex> Immunity.InputParser.imm_weak("(immune to fire; weak to bludgeoning, slashing) ")
      {:ok, [immunity: [:fire], weakness: [:bludgeoning, :slashing]], "", %{}, {1, 0}, 48}

      iex> Immunity.InputParser.imm_weak("(weak to bludgeoning, slashing) ")
      {:ok, [weakness: [:bludgeoning, :slashing], immunity: []], "", %{}, {1, 0}, 32}

      iex> Immunity.InputParser.imm_weak("(weak to bludgeoning, slashing; immune to fire) ")
      {:ok, [weakness: [:bludgeoning, :slashing], immunity: [:fire]], "", %{}, {1, 0}, 48}

      iex> Immunity.InputParser.no_imm_weak("")
      {:ok, [immunity: [], weakness: []], "", %{}, {1, 0}, 0}
  """
  defparsec :imm_weak,
    ignore(string("("))
    |> choice([
      parsec(:immunity) |> choice([ignore(string(";")) |> ignore(ws) |> parsec(:weakness), parsec(:no_weakness)]),
      parsec(:weakness) |> choice([ignore(string(";")) |> ignore(ws) |> parsec(:immunity), parsec(:no_immunity)]),
    ])
    |> ignore(string(")"))
    |> ignore(string(" "))
  defparsec :no_imm_weak,
    parsec(:no_immunity)
    |> parsec(:no_weakness)

  @doc """
  `<immunity> :== "immune" <ws> "to" <ws> <attack> { "," <ws> <attack> }`

  ## Examples

      iex> Immunity.InputParser.immunity("immune to fire")
      {:ok, [immunity: [:fire]], "", %{}, {1, 0}, 14}

      iex> Immunity.InputParser.no_immunity("")
      {:ok, [immunity: []], "", %{}, {1, 0}, 0}
  """
  defparsec :immunity,
    ignore(string("immune"))
    |> ignore(ws)
    |> ignore(string("to"))
    |> ignore(ws)
    |> parsec(:attack)
    |> repeat(ignore(string(",")) |> ignore(ws) |> parsec(:attack))
    |> tag(:immunity)
  defparsec :no_immunity,
    empty()
    |> tag(:immunity)

  @doc """
  `<weakness> :== "weak" <ws> "to" <ws> <attack> { "," <ws> <attack> }`

  ## Examples

      iex> Immunity.InputParser.weakness("weak to bludgeoning, slashing")
      {:ok, [weakness: [:bludgeoning, :slashing]], "", %{}, {1, 0}, 29}

      iex> Immunity.InputParser.no_weakness("")
      {:ok, [weakness: []], "", %{}, {1, 0}, 0}
  """
  defparsec :weakness,
    ignore(string("weak"))
    |> ignore(ws)
    |> ignore(string("to"))
    |> ignore(ws)
    |> parsec(:attack)
    |> repeat(ignore(string(",")) |> ignore(ws) |> parsec(:attack))
    |> tag(:weakness)
  defparsec :no_weakness,
    empty()
    |> tag(:weakness)

  ###
  # `<attack> :== "bludgeoning" | "slashing" | "radiation" | "fire" | "cold"`
  #
  bludgeoning = string("bludgeoning") |> replace(:bludgeoning) |> label("bludgeoning")
  slashing = string("slashing") |> replace(:slashing) |> label("slashing")
  radiation = string("radiation") |> replace(:radiation) |> label("radiation")
  fire = string("fire") |> replace(:fire) |> label("fire")
  cold = string("cold") |> replace(:cold) |> label("cold")
  defcombinatorp(:attack, choice([bludgeoning, slashing, radiation, fire, cold]))

  @doc """
  `<damage> :== "with" <ws> "an" <ws> "attack" <ws> "that" <ws> "does" <ws> <integer> <ws> <attack> <ws> "damage" <ws>`

  ## Examples

      iex> Immunity.InputParser.damage("with an attack that does 25 slashing damage ")
      {:ok, [25, :slashing], "", %{}, {1, 0}, 44}

      iex> Immunity.InputParser.damage("with an attack that does 25 biting damage ")
      {:error, "expected bludgeoning or slashing or radiation or fire or cold", "biting damage ", %{}, {1, 0}, 28}
  """
  defparsec :damage,
    ignore(string("with"))
    |> ignore(ws)
    |> ignore(string("an"))
    |> ignore(ws)
    |> ignore(string("attack"))
    |> ignore(ws)
    |> ignore(string("that"))
    |> ignore(ws)
    |> ignore(string("does"))
    |> ignore(ws)
    |> integer(min: 1)
    |> label("integer")
    |> ignore(ws)
    |> parsec(:attack)
    |> ignore(ws)
    |> ignore(string("damage"))
    |> ignore(ws)

  @doc """
  `<initiative> :== "at" <ws> "initiative" <ws> <integer>`

  ## Example

      iex> Immunity.InputParser.initiative("at initiative 3")
      {:ok, [3], "", %{}, {1, 0}, 15}
  """
  defparsec :initiative,
    ignore(string("at"))
    |> ignore(ws)
    |> ignore(string("initiative"))
    |> ignore(ws)
    |> integer(min: 1)
    |> label("integer")
end

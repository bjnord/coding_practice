defmodule Runes.Artifact do
  @moduledoc """
  Runes artifact functions.
  """

  defstruct words: [], height: 0, widths: [], grid: %{}

  @type t :: %__MODULE__{
    words: [charlist()],
    height: integer(),
    widths: [integer()],
    grid: %{{integer(), integer()} => char()}
  }
end

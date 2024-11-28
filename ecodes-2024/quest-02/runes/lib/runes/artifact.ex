defmodule Runes.Artifact do
  @moduledoc """
  Runes artifact functions.
  """

  defstruct words: [], grid: %{}

  @type t :: %__MODULE__{
    words: [charlist()],
    grid: %{{integer(), integer()} => char()}
  }
end

defmodule Trench.Image do
  @moduledoc """
  Image for `Trench`.
  """

  alias Trench.Image, as: Image

  defstruct radius: 0, pixmap: %{}, infinity: :all_zeros

  @doc ~S"""
  Construct new `Image`.
  """
  def new({radius, pixmap}) do
    %Image{radius: radius, pixmap: pixmap}
  end

  def radius(image), do: image.radius

  @doc ~S"""
  Return pixel value (0 or 1) at location `{x, y}`.
  """
  def pixel_at(image, {x, y}) do
    case image.pixmap[{x, y}] do
      nil -> if image.infinity == :all_ones, do: 1, else: 0
      px  -> px
    end
  end

  @doc ~S"""
  Apply image-enhancement `algor` to `image`.
  """
  def apply(image, algor) do
    {_px, enh_image} = set_new_pixel_at(image, image, algor, {0, 0})
    apply(enh_image, image, algor, 1, image.radius, [nil, nil, nil])
  end
  defp apply(enh_image, image, algor, radius, min_radius, states) do
    #  XXY  <- each row and column
    #  Y Y  <- is shortened/offset
    #  YXX  <- so no wasted overlap
    #
    ###
    # top and bottom rows
    {n_ones_x, enh_image} =
      -radius..(radius-1)
      |> Enum.reduce({0, enh_image}, fn (x, {n_ones, enh_image}) ->
        {px_top, enh_image} = set_new_pixel_at(enh_image, image, algor, {x, -radius})
        {px_bot, enh_image} = set_new_pixel_at(enh_image, image, algor, {x + 1, radius})
        {n_ones + px_top + px_bot, enh_image}
      end)
    ###
    # left and right columns
    {n_ones_y, enh_image} =
      -(radius-1)..radius
      |> Enum.reduce({0, enh_image}, fn (y, {n_ones, enh_image}) ->
        {px_left, enh_image} = set_new_pixel_at(enh_image, image, algor, {-radius, y})
        {px_right, enh_image} = set_new_pixel_at(enh_image, image, algor, {radius, y - 1})
        {n_ones + px_left + px_right, enh_image}
      end)
    states = [state(n_ones_x + n_ones_y, (radius * 2) * 4) | states]
    cond do
      radius < min_radius ->
        apply(enh_image, image, algor, radius + 1, min_radius, states)
      repeat_state(states) == :all_zeros ->
        %Image{enh_image | radius: radius, infinity: :all_zeros}
      repeat_state(states) == :all_ones ->
        %Image{enh_image | radius: radius, infinity: :all_ones}
      true ->
        apply(enh_image, image, algor, radius + 1, min_radius, states)
    end
  end

  defp state(n_ones, max_ones) do
    cond do
      n_ones == max_ones -> :all_ones
      n_ones == 0 -> :all_zeros
      true -> :mixed
    end
  end

  defp repeat_state([s2, s1, s0 | _]) when s0 == s1 and s1 == s2 and s2 == :all_ones, do: s2
  defp repeat_state([s2, s1, s0 | _]) when s0 == s1 and s1 == s2 and s2 == :all_zeros, do: s2
  defp repeat_state(_), do: :mixed

  @doc false
  def set_new_pixel_at(enh_image, image, algor, {x, y}) do
    px = new_pixel_at(image, algor, {x, y})
    enh_image = set_pixel_at(enh_image, {x, y}, px)
    {px, enh_image}
  end

  defp new_pixel_at(image, algor, {x, y}) do
    for dy <- -1..1 do
      for dx <- -1..1 do
        {x + dx, y + dy}
      end
    end
    |> List.flatten()
    |> Enum.map(&(pixel_at(image, &1)))
    |> (fn pixels -> algor_index(pixels) end).()
    |> (fn i -> algor[i] end).()
  end

  defp algor_index(pixels) do
    Enum.reduce(pixels, 0b0, fn (px, acc) -> acc * 2 + px end)
  end

  defp set_pixel_at(image, {x, y}, px) do
    %Image{image | pixmap: Map.put(image.pixmap, {x, y}, px)}
  end

  @doc ~S"""
  Render image to text lines.
  """
  def render(image) do
    line_len = image.radius * 2 + 1
    image_points(image.radius)
    |> Enum.reduce([], fn (point, chars) ->
      char =
        case image.pixmap[point] do
          nil -> if image.infinity == :all_ones, do: 1, else: 0
          1   -> ?#
          0   -> ?.
        end
      [char | chars]
    end)
    |> Enum.reverse
    |> Enum.chunk_every(line_len)
    |> Enum.map(fn chars -> to_string(chars) end)
    |> Enum.join("\n")
    |> (fn text -> "#{text}\n" end).()
  end

  defp image_points(radius) do
    for y <- -radius..radius do
      for x <- -radius..radius do
        {x, y}
      end
    end
    |> List.flatten()
  end

  @doc ~S"""
  Return count of lit pixels in image.
  """
  def lit_count(image) do
    case image.infinity do
      :all_ones ->
        :infinite
      _ ->
        Map.values(image.pixmap)
        |> Enum.count(&(&1 == 1))
    end
  end

  @doc ~S"""
  Render image to image frame file.
  """
  # each source image pixel is rendered as 2x2 in the output file
  def visualize(image, dim, frame_n) do
    nnn = String.pad_leading(Integer.to_string(frame_n), 3, "0")
    path = "viz/frame#{nnn}.pbm"
    {:ok, file} = File.open(path, [:write])
    radius = div(dim, 2)  # image width 200px = 201 points [-100..100]
    n_points = (radius * 2) + 1
    px_per_line = n_points * 2  # 201 points = 402 pixels
    IO.binwrite(file, "P1\n# AoC 2021 Day 20\n#{px_per_line} #{px_per_line}\n")
    text =
      image_points(radius)
      |> Enum.reduce([], fn (point, chars) ->
        ch =
          case image.pixmap[point] do
            nil -> if image.infinity == :all_ones, do: ?1, else: ?0
            1   -> ?1
            0   -> ?0
          end
        [ch, 32, ch, 32 | chars]  # 2 pixels wide w/space delim
      end)
      |> Enum.reverse
      |> Enum.chunk_every(px_per_line * 2)  # 402 px per line = 804 chars
      |> Enum.map(&(to_double_string(&1)))
      |> Enum.join("\n")
      |> (fn text -> "#{text}" end).()
    IO.binwrite(file, "#{text}\n")
    File.close(path)
  end

  defp to_double_string(chars) do
    chars
    |> to_string()
    |> String.slice(1..-1)
    |> (fn line -> "#{line}\n#{line}" end).()
  end
end

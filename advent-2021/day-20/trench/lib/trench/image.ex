defmodule Trench.Image do
  @moduledoc """
  Image for `Trench`.
  """

  alias Trench.Image, as: Image

  defstruct radius: 0, pixmap: %{}

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
    # because it's an infinite canvas, return 0 when `nil`
    case image.pixmap[{x, y}] do
      1 -> 1
      _ -> 0
    end
  end

  @doc ~S"""
  Apply image-enhancement `algor` to `image`.
  """
  def apply(image, algor) do
    {_px, enh_image} = set_new_pixel_at(image, image, algor, {0, 0})
    apply(enh_image, image, algor, 1, image.radius)
  end
  defp apply(enh_image, image, algor, radius, min_radius) do
    #IO.puts("apply radius=#{radius} (min_radius=#{min_radius})")
    #  XXY  <- each row and column
    #  Y Y  <- is shortened/offset
    #  YXX  <- so no wasted overlap
    #
    # top and bottom rows
    {n_ones_x, enh_image} =
      -radius..(radius-1)
      |> Enum.reduce({0, enh_image}, fn (x, {n_ones, enh_image}) ->
        {px_top, enh_image} = set_new_pixel_at(enh_image, image, algor, {x, -radius})
        {px_bot, enh_image} = set_new_pixel_at(enh_image, image, algor, {x + 1, radius})
        {n_ones + px_top + px_bot, enh_image}
      end)
    # left and right columns
    {n_ones_y, enh_image} =
      -(radius-1)..radius
      |> Enum.reduce({0, enh_image}, fn (y, {n_ones, enh_image}) ->
        {px_left, enh_image} = set_new_pixel_at(enh_image, image, algor, {-radius, y})
        {px_right, enh_image} = set_new_pixel_at(enh_image, image, algor, {radius, y - 1})
        {n_ones + px_left + px_right, enh_image}
      end)
    cond do
      radius < min_radius ->
        apply(enh_image, image, algor, radius + 1, min_radius)
      (n_ones_x + n_ones_y) > 0 ->
        #IO.puts("  got n_ones x=#{n_ones_x} y=#{n_ones_y}")
        apply(enh_image, image, algor, radius + 1, min_radius)
      true ->
        %Image{enh_image | radius: radius}
    end
  end

  @doc false
  def set_new_pixel_at(enh_image, image, algor, {x, y}) do
    px = new_pixel_at(image, algor, {x, y})
    #IO.inspect({px, x, y}, label: "    px, {x, y}")
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
      case image.pixmap[point] do
        1 -> [?# | chars]
        0 -> [?. | chars]
      end
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
    Map.values(image.pixmap)
    |> Enum.count(&(&1 == 1))
  end
end

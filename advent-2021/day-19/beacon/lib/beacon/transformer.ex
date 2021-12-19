defmodule Beacon.Transformer do
  @moduledoc """
  Tensor and transformation functions for `Beacon`.

  h/t [How to get all 24 rotations of a 3-dimensional array?"](https://stackoverflow.com/a/50546727/291754)
  """

  def position_sum({i0, j0, k0}, {i1, j1, k1}) do
    {i0 + i1, j0 + j1, k0 + k1}
  end

  def position_difference({i0, j0, k0}, {i1, j1, k1}) do
    {i0 - i1, j0 - j1, k0 - k1}
  end

  def transforms(p) do
    for t <- 1..24, into: [], do: {t, transform(p, t)}
  end

  ### AXIS ROTATIONS ###

  def x({i, j, k}), do: {i, -k, j}
  def y({i, j, k}), do: {k, j, -i}
  def z({i, j, k}), do: {-j, i, k}

  ###
  # NOTE the function calls below are wrapped inside-out
  #      (so the rotations happen in the specified order)

  ### IDENTITY ###

  # 1.  I
  def transform(p, n) when n == 1, do: p

  ### ONE ROTATION ###

  # 2.  X = YXZ
  def transform(p, n) when n == 2, do: x(p)
  # 3.  Y = ZYX
  def transform(p, n) when n == 3, do: y(p)
  # 4.  Z = XZY
  def transform(p, n) when n == 4, do: z(p)

  ### TWO ROTATIONS ###

  # 5.  XX = XYXZ = YXXY = YXYZ = YXZX = YYZZ = YZXZ = ZXXZ = ZZYY
  def transform(p, n) when n == 5, do: x(x(p))
  # 6.  XY = YZ = ZX = XZYX = YXZY = ZYXZ
  def transform(p, n) when n == 6, do: y(x(p))
  # 7.  XZ = XXZY = YXZZ = YYYX = ZYYY
  def transform(p, n) when n == 7, do: z(x(p))
  # 8.  YX = XZZZ = YYXZ = ZYXX = ZZZY
  def transform(p, n) when n == 8, do: x(y(p))
  # 9.  YY = XXZZ = XYYX = YZYX = ZXYX = ZYXY = ZYYZ = ZYZX = ZZXX
  def transform(p, n) when n == 9, do: y(y(p))
  # 10. ZY = XXXZ = XZYY = YXXX = ZZYX
  def transform(p, n) when n == 10, do: y(z(p))
  # 11. ZZ = XXYY = XYZY = XZXY = XZYZ = XZZX = YYXX = YZZY = ZXZY
  def transform(p, n) when n == 11, do: z(z(p))

  ### THREE ROTATIONS ###

  # 12. XXX
  def transform(p, n) when n == 12, do: x(x(x(p)))
  # 13. XXY = XYZ = XZX = YZZ = ZXZ
  def transform(p, n) when n == 13, do: y(x(x(p)))
  # 14. XXZ = ZYY
  def transform(p, n) when n == 14, do: z(x(x(p)))
  # 15. XYX = YXY = YYZ = YZX = ZXX
  def transform(p, n) when n == 15, do: x(y(x(p)))
  # 16. XYY = YZY = ZXY = ZYZ = ZZX
  def transform(p, n) when n == 16, do: y(y(x(p)))
  # 17. XZZ = YYX
  def transform(p, n) when n == 17, do: z(z(x(p)))
  # 18. YXX = ZZY
  def transform(p, n) when n == 18, do: x(x(y(p)))
  # 19. YYY
  def transform(p, n) when n == 19, do: y(y(y(p)))
  # 20. ZZZ
  def transform(p, n) when n == 20, do: z(z(z(p)))

  ### FOUR ROTATIONS ###

  # 21. XXXY = XXYZ = XXZX = XYZZ = XZXZ = YZZZ = ZXZZ = ZYYX
  def transform(p, n) when n == 21, do: y(x(x(x(p))))
  # 22. XXYX = XYXY = XYYZ = XYZX = XZXX = YXYY = YYZY = YZXY = YZYZ = YZZX = ZXXY = ZXYZ = ZXZX = ZYZZ = ZZXZ
  def transform(p, n) when n == 22, do: x(y(x(x(p))))
  # 23. XYXX = XZZY = YXYX = YYXY = YYYZ = YYZX = YZXX = ZXXX
  def transform(p, n) when n == 23, do: x(x(y(x(p))))
  # 24. XYYY
  def transform(p, n) when n == 24, do: y(y(y(x(p))))
end

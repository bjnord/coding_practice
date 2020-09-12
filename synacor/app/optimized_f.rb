require_relative '../app/array_cache'
require_relative '../app/logic'

# 178b JT   R0 0x1793
# 178e ADD  R0 R1 0x0001
# 1792 RET
#
# 1793 JT   R1 0x17a0
# 1796 ADD  R0 R0 0x7fff
# 179a SET  R1 R7
# 179d CALL 0x178b
# 179f RET
#
# 17a0 PUSH R0
# 17a2 ADD  R1 R1 0x7fff
# 17a6 CALL 0x178b
# 17a8 SET  R1 R0
# 17ab POP  R0
# 17ad ADD  R0 R0 0x7fff
# 17b1 CALL 0x178b
# 17b3 RET

class OptimizedF
  def initialize(r7)
    @r7 = r7
    ArrayCache.clear
  end

  # NOTE ArrayCache doesn't protect stored complex objects from being
  #      subsequently modified by the caller! The following is carefully
  #      constructed to create "fresh" 2-element arrays every time.
  def f(r)
    if r[0] == 0
      return [Logic.add(r[1], 1), r[1]]
    elsif c = ArrayCache.read(r)
      return c.dup
    elsif r[1] == 0
      r0 = Logic.add(r[0], 0x7fff)
      r1 = @r7
      return f([r0, r1])  # TRO
    end
    r1 = Logic.add(r[1], 0x7fff)
    call1 = [r[0], r1]
    ret1 = f(call1)
    ArrayCache.write(call1, ret1)
    r1 = ret1[0]
    r0 = Logic.add(r[0], 0x7fff)
    f([r0, r1])  # TRO
  end
end

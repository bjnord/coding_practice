require_relative '../app/logic'

describe Logic do
  describe '#eq' do
    context 'with equal values' do
      it 'should be true (1)' do
        expect(Logic.eq(0x00, 0x00)).to be == 1
        expect(Logic.eq(0x4379, 0x4379)).to be == 1
      end
    end

    context 'with unequal values' do
      it 'should be false (0)' do
        expect(Logic.eq(0x01, 0x02)).to be == 0
        expect(Logic.eq(0x4379, 0x4378)).to be == 0
      end
    end
  end

  describe '#gt' do
    context 'with lesser values' do
      it 'should be false (0)' do
        expect(Logic.gt(0x00, 0x01)).to be == 0
        expect(Logic.gt(0x4379, 0x437a)).to be == 0
      end
    end

    context 'with equal values' do
      it 'should be false (0)' do
        expect(Logic.gt(0x00, 0x00)).to be == 0
        expect(Logic.gt(0x4379, 0x4379)).to be == 0
      end
    end

    context 'with greater values' do
      it 'should be true (1)' do
        expect(Logic.gt(0x02, 0x01)).to be == 1
        expect(Logic.gt(0x437b, 0x437a)).to be == 1
      end
    end
  end

  describe '#add' do
    context 'with no overflow' do
      it 'should calculate the correct values' do
        expect(Logic.add(0x02, 0x03)).to be == 0x05
        expect(Logic.add(0x4321, 0x3cde)).to be == 0x7fff
      end
    end

    context 'with overflow' do
      it 'should calculate the correct values' do
        expect(Logic.add(32758, 15)).to be == 5
        expect(Logic.add(0x4321, 0x3cdf)).to be == 0x0000
      end
    end
  end

  describe '#mult' do
    context 'with no overflow' do
      it 'should calculate the correct values' do
        expect(Logic.mult(0x02, 0x03)).to be == 0x06
        expect(Logic.mult(0x65, 0xbf)).to be == 0x4b5b
      end
    end

    context 'with overflow' do
      it 'should calculate the correct values' do
        expect(Logic.mult(32758, 15)).to be == 32618
        expect(Logic.mult(0x38f, 0x3df)).to be == 0x4691
      end
    end
  end

  describe '#mod' do
    it 'should calculate the correct values' do
      expect(Logic.mod(32767, 3)).to be == 1
      expect(Logic.mod(0x5432, 0xbf)).to be == 0xa2
    end
  end

  describe '#and' do
    it 'should calculate the correct values' do
      expect(Logic.and(0x3333, 0x1212)).to be == 0x1212
      expect(Logic.and(0x3333, 0x569a)).to be == 0x1212
      expect(Logic.and(0x5555, 0x7fff)).to be == 0x5555
      expect(Logic.and(0x5555, 0x1256)).to be == 0x1054
    end
  end

  describe '#or' do
    it 'should calculate the correct values' do
      expect(Logic.or(0x3333, 0x1212)).to be == 0x3333
      expect(Logic.or(0x3333, 0x569a)).to be == 0x77bb
      expect(Logic.or(0x5555, 0x7fff)).to be == 0x7fff
      expect(Logic.or(0x5555, 0x0000)).to be == 0x5555
    end
  end

  describe '#not' do
    it 'should calculate the correct values' do
      expect(Logic.not(0x1212)).to be == 0x6ded
      expect(Logic.not(0x569a)).to be == 0x2965
      expect(Logic.not(0x7fff)).to be == 0x0000
      expect(Logic.not(0x0000)).to be == 0x7fff
    end
  end
end

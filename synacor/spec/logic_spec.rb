require_relative '../app/logic'

describe Logic do
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
end

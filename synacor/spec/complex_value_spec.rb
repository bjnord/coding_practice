require_relative '../app/complex_value'

describe ComplexValue do
  context 'with an invalid register' do
    it 'should disallow the invalid register' do
      expect{ ComplexValue.new(0x8008) }.to raise_error(ComplexValueError, 'invalid value')
    end
  end

  describe '#register?' do
    context 'with a number' do
      let(:cvalue) { ComplexValue.new(0x1234) }
      it 'should be false' do
        expect(cvalue.register?).to be_falsey
      end
    end

    context 'with a register' do
      let(:cvalue) { ComplexValue.new(0x8002) }
      it 'should be true' do
        expect(cvalue.register?).to be_truthy
      end
    end
  end

  describe '#value' do
    context 'with a number' do
      let(:cvalue) { ComplexValue.new(0x1234) }
      it 'should return the number' do
        expect(cvalue.value).to be == 0x1234
      end
    end

    context 'with a register' do
      let(:cvalue) { ComplexValue.new(0x8002) }
      it 'should return the register number' do
        expect(cvalue.value).to be == 0x2
      end
    end
  end
end

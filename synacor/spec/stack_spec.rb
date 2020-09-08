require_relative '../app/stack'

describe Stack do
  describe '#push' do
    let(:stack) { Stack.new }
    it 'should disallow negative values' do
      expect{ stack.push(-1) }.to raise_error(StackError, 'negative value')
    end
    it 'should allow minimum value' do
      expect{ stack.push(0x0) }.not_to raise_error
    end
    it 'should allow maximum value' do
      expect{ stack.push(Stack::MAX_VALUE) }.not_to raise_error
    end
    it 'should disallow too-large values' do
      expect{ stack.push(Stack::MAX_VALUE+1) }.to raise_error(StackError, 'value overflow')
    end
  end

  describe '#pop' do
    context 'with a non-empty stack' do
      let(:stack) { Stack.new }
      before(:each) { [0x01, 0x02, 0x03].each{|v| stack.push(v) } }
      it 'should return the values in reverse order' do
        expect(stack.pop).to be == 0x03
        expect(stack.pop).to be == 0x02
        expect(stack.pop).to be == 0x01
      end
    end

    context 'with an empty stack' do
      let(:stack) { Stack.new }
      it 'should raise an error' do
        expect{ stack.pop }.to raise_error(StackError, 'empty stack')
      end
    end
  end
end

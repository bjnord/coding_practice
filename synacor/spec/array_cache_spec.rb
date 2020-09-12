require_relative '../app/array_cache'

describe Array do
  describe '#cache_key' do
    it 'should compute the cache key correctly' do
      expect([0x00, 0x00].cache_key).to be == 0x00000000
      expect([0x0a, 0x03].cache_key).to be == 0x00050003
      expect([0x5555, 0x2aaa].cache_key).to be == (0x2aaa8000 + 0x2aaa)
      expect([0x7ffe, 0x7ffd].cache_key).to be == (0x3fff0000 + 0x7ffd)
      expect([0x7fff, 0x7fff].cache_key).to be == 0x3fffffff
    end
    it 'should raise an error for negative values' do
      expect{ [-1].cache_key }.to raise_error RangeError, 'negative array element'
    end
    it 'should raise an error for too-large values' do
      expect{ [0x8000].cache_key }.to raise_error RangeError, 'array element too large'
    end
  end
end

describe ArrayCache do
  describe '#read' do
    context 'with an empty cache' do
      before(:each) { ArrayCache.clear }
      it 'should not find a key' do
        expect(ArrayCache.read([1, 2])).to be_nil
      end
      it 'should have size 0' do
        expect(ArrayCache.size).to be == 0
      end
    end

    context 'with one value in cache' do
      before(:each) do
        ArrayCache.clear
        ArrayCache.write([1, 2], [3, 4])
      end
      it 'should find the key' do
        expect(ArrayCache.read([1, 2])).to be == [3, 4]
      end
      it 'should not find other keys' do
        expect(ArrayCache.read([3, 4])).to be_nil
        expect(ArrayCache.read([2, 1])).to be_nil
      end
      it 'should have size 1' do
        expect(ArrayCache.size).to be == 1
      end
    end

    context 'with two values in cache' do
      before(:each) do
        ArrayCache.clear
        ArrayCache.write([5, 6], [7, 8])
        ArrayCache.write([0, 32767], [555, 1212])
      end
      it 'should find the keys' do
        expect(ArrayCache.read([0, 32767])).to be == [555, 1212]
        expect(ArrayCache.read([5, 6])).to be == [7, 8]
      end
      it 'should not find other keys' do
        expect(ArrayCache.read([555, 1212])).to be_nil
        expect(ArrayCache.read([7, 8])).to be_nil
        expect(ArrayCache.read([32767, 0])).to be_nil
        expect(ArrayCache.read([6, 5])).to be_nil
      end
      it 'should have size 2' do
        expect(ArrayCache.size).to be == 2
      end
    end

    context 'with a bad key' do
      it 'should raise an error' do
        expect{ ArrayCache.read(2) }.to raise_error ArrayCacheError, 'key must be Enumerable'
      end
    end
  end

  describe '#write' do
    context 'writing to an empty cache' do
      before(:each) do
        ArrayCache.clear
        ArrayCache.write([2, 3], [5, 7])
      end
      it 'should increase size to 1' do
        expect(ArrayCache.size).to be == 1
      end
    end

    context 'with a bad key' do
      it 'should raise an error' do
        expect{ ArrayCache.write(1, [5, 6]) }.to raise_error ArrayCacheError, 'key must be Enumerable'
      end
    end
  end
end

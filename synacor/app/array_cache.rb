class Array
  # expects 15-bit array elements
  def cache_key
    reduce(0) do |acc, v|
      raise RangeError, 'negative array element' if v < 0
      raise RangeError, 'array element too large' if v >= 0x8000
      acc * 0x8000 + v
    end
  end
end

class ArrayCacheError < StandardError ; end

class ArrayCache
  @@entries = {}
  @@misses = 0
  @@hits = 0

  def self.read(key)
    raise ArrayCacheError, 'key must be Enumerable' unless key.is_a?(Enumerable)
    if @@entries[key.cache_key]
      @@hits += 1
      @@entries[key.cache_key]
    else
      @@misses += 1
      nil
    end
  end

  def self.write(key, value)
    raise ArrayCacheError, 'key must be Enumerable' unless key.is_a?(Enumerable)
    @@entries[key.cache_key] = value
  end

  def self.clear
    @@entries = {}
    @@misses = 0
    @@hits = 0
  end

  def self.size
    @@entries.size
  end

  def self.dump
    missp = (@@misses * 100.0 / (@@misses + @@hits)).round(1)
    hitp = (@@hits * 100.0 / (@@misses + @@hits)).round(1)
    $stderr.puts "entries=#{@@entries.size} misses=#{@@misses}(#{missp}%) hits=#{@@hits}(#{hitp}%)"
  end
end

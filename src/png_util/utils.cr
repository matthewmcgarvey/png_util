module PNGUtil
  module Utils
    extend self

    def parse_integer(bytes)
      bytes.reduce(0) { |acc, byte| (acc << 8) + byte }
    end

    def bytes_to_uint32(bytes)
      bytes.reduce(0.to_u32) { |acc, byte| (acc << 8) + byte }
    end

    def paeth_predictor(a8, b8, c8)
      a = a8.to_i16
      b = b8.to_i16
      c = c8.to_i16

      p = a + b - c # inital estimate

      pa = (p - a).abs # distances to a, b, c
      pb = (p - b).abs
      pc = (p - c).abs

      case
      when pa <= pb && pa <= pc
        a.to_u8
      when pb <= pc
        b.to_u8
      else
        c.to_u8
      end
    end
  end
end

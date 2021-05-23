module PNGUtil
  # A `RGBA` is made up of four components:
  # `red`, `green`, `blue` and `alpha`,
  # each with a resolution of 16 bit.
  #
  # All 148 [Named CSS Colors](https://www.quackit.com/css/css_color_codes.cfm)
  # are available as constants.
  module RGBA
    DEFAULT = {r: 0_u16, g: 0_u16, b: 0_u16, a: 0_u16}
    alias Data = {r: UInt16, g: UInt16, b: UInt16, a: UInt16}

    # Create a `RGBA` struct from a tuple of n-bit red, green and blue values
    def self.from_rgb_n(values, n) : Data
      r, g, b = values
      red = scale_up(r, n)
      green = scale_up(g, n)
      blue = scale_up(b, n)
      new(red, green, blue)
    end

    def self.new(color : UInt16, a : UInt16 = UInt16::MAX) : Data
      new(color, color, color, a)
    end

    def self.new(r : UInt16, g : UInt16, b : UInt16, a : UInt16 = UInt16::MAX) : Data
      {r: r, g: g, b: b, a: a}
    end

    # Helper method,
    # scale a value `input`
    # from `from` bits resolution
    # to 16 bits.
    private def self.scale_up(input, from)
      return input.to_u16 if from == 16
      (input.to_f / (2 ** from - 1) * (2 ** 16 - 1)).round.to_u16
    end
  end
end

module PNGUtil
  struct Canvas
    getter width : Int32
    getter height : Int32
    getter pixels : Slice(RGBA::Data)

    def initialize(@width, @height)
      size = @width.to_i64 * @height
      check_size!(size)
      @pixels = Slice.new(size.to_i32, RGBA::DEFAULT)
    end

    # Get the value of pixel `(x, y)`
    # without checking if `(x, y)` is a valid position.
    def get(x, y)
      @pixels[x + @width * y]
    end

    # Set the value of pixel `(x, y)` to `color`
    # without checking if `(x, y)` is a valid position.
    def set(x, y, color)
      @pixels[x + @width * y] = color
    end

    # Short form for `get`
    def [](x, y)
      get(x, y)
    end

    # Short form for `set`
    def []=(x, y, color)
      set(x, y, color)
    end

    # Iterate over each row of the canvas
    # (a `Slice(RGBA)` of size `@width`).
    # The main usecase for this is
    # writing code that encodes images
    # in some file format.
    def each_row(&block)
      @height.times do |n|
        yield @pixels[n * @width, @width]
      end
    end

    # Two canvases are considered equal
    # if they are of equal size
    # and all their pixels are equal
    def ==(other)
      self.class == other.class &&
        @width == other.width &&
        @height == other.height &&
        @pixels == other.pixels
    end

    # very basic nearest neighbor image scaling algorithm
    def resize(new_width, new_height)
      new_size = new_width.to_i64 * new_height
      check_size!(new_size)
      new_pixels = Slice.new(new_size.to_i32, RGBA.new(0_u16, 0_u16, 0_u16, 0_u16))
      width_ratio = width.to_f / new_width
      height_ratio = height.to_f / new_height
      (0...new_height).each do |i|
        (0...new_width).each do |j|
          width_precision = (j * width_ratio).floor.to_i
          height_precision = (i * height_ratio).floor.to_i
          new_pixels[(i * new_width) + j] = pixels[(height_precision * width) + width_precision]
        end
      end
      @width = new_width
      @height = new_height
      @pixels = new_pixels
    end

    private def check_size!(size)
      if size > Int32::MAX
        raise "The maximum size of a canvas is #{Int32::MAX} total pixels"
      end
    end
  end
end

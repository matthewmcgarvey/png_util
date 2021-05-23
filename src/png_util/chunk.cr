require "digest/crc32"
require "./utils"

module PNGUtil
  struct Chunk
    getter type : String
    getter data : Bytes
    getter crc : UInt32

    # Parse chunk data **without** size.
    def self.parse(slice : Bytes)
      type = String.new slice[0, 4]
      crc = Utils.bytes_to_uint32(slice[slice.size - 4, 4])
      data = slice[4, slice.size - 8]

      expected_crc = Digest::CRC32.checksum(slice[0, slice.size - 4])
      raise "Incorrect checksum" unless crc == expected_crc

      Chunk.new(type, data, crc)
    end

    def initialize(@type, @data, @crc)
    end

    def size
      @data.size
    end

    # Write chunk data to *io* **with** size.
    def write(io : IO)
      io.write_bytes(size, IO::ByteFormat::BigEndian)
      io << @type
      io.write(@data)
      io.write_bytes(@crc, IO::ByteFormat::BigEndian)
    end
  end
end

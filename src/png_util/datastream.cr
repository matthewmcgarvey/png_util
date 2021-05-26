require "compress/zlib"
require "./utils"
require "./chunk"

module PNGUtil
  struct Datastream
    def self.read(path)
      File.open(path) do |file|
        read(file)
      end
    end

    def self.read(io : IO)
      unless io.read_bytes(UInt64, IO::ByteFormat::BigEndian) == PNGUtil::HEADER
        raise "Not a png file"
      end

      chunks = [] of Chunk

      loop do
        begin
          chunk_length = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)
        rescue IO::EOFError
          break
        end

        chunk_data = Bytes.new(chunk_length + 4 + 4)
        io.read_fully(chunk_data)

        chunks << Chunk.parse(chunk_data)
      end

      Datastream.new chunks
    end

    def initialize(@chunks : Array(Chunk))
    end

    def parse(png)
      @chunks.each { |chunk| png.parse_chunk(chunk) }
    end
  end
end

require "compress/zlib"
require "digest/crc32"
require "io/multi_writer"
require "./png_util/rgba"
require "./png_util/canvas"
require "./png_util/png"
require "./png_util/crc_io"

module PNGUtil
  extend self

  HEADER = 0x89504e470d0a1a0a

  def read(path : String)
    File.open(path, "rb") do |file|
      read(file)
    end
  end

  def read(io : IO)
    png = PNG.new

    Datastream.read(io)
      .parse(png)

    png.canvas
  end

  def write(canvas, path : String)
    File.open(path, "wb") do |file|
      write(canvas, file)
    end
  end

  def write(canvas, io : IO, **options)
    io.write_bytes(HEADER, IO::ByteFormat::BigEndian)

    crc_io = CrcIO.new
    multi = IO::MultiWriter.new(crc_io, io)

    # Write the IHDR chunk
    io.write_bytes(13_u32, IO::ByteFormat::BigEndian)
    multi << "IHDR"

    multi.write_bytes(canvas.width.to_u32, IO::ByteFormat::BigEndian)
    multi.write_bytes(canvas.height.to_u32, IO::ByteFormat::BigEndian)
    multi.write_byte(16_u8) # bit depth
    multi.write_byte(6_u8)  # rgb alpha
    multi.write_byte(0_u8)  # compression = deflate
    multi.write_byte(0_u8)  # filter = adaptive (only option)
    multi.write_byte(0_u8)  # interlacing = none

    multi.write_bytes(crc_io.crc.to_u32, IO::ByteFormat::BigEndian)
    crc_io.reset

    # Write the IDAT chunk with a dummy chunk size
    io.write_bytes(0_u32, IO::ByteFormat::BigEndian)
    multi << "IDAT"
    crc_io.size = 0

    Compress::Zlib::Writer.open(multi) do |deflate|
      buffer = Bytes.new(1 + canvas.width * 8)
      canvas.each_row do |col|
        buffer_ptr = buffer + 1 # The first byte is 0 => no filter
        col.each do |pixel|
          pixel.each do |_key, value|
            IO::ByteFormat::BigEndian.encode(value, buffer_ptr)
            buffer_ptr += 2
          end
        end
        deflate.write(buffer)
      end
    end

    # Go back and write the size
    io.seek(-(4 + 4 + crc_io.size), IO::Seek::Current)
    io.write_bytes(crc_io.size.to_u32, IO::ByteFormat::BigEndian)
    io.seek(0, IO::Seek::End)
    multi.write_bytes(crc_io.crc.to_u32, IO::ByteFormat::BigEndian)

    # Write the IEND chunk
    io.write_bytes(0_u32, IO::ByteFormat::BigEndian)
    multi << "IEND"
    multi.write_bytes(Digest::CRC32.checksum("IEND"), IO::ByteFormat::BigEndian)
  end
end

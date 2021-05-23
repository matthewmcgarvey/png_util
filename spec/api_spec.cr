require "spec"
require "../src/png_util"

describe PNGUtil do
  describe "resizing" do
    it "works" do
      canvas = PNGUtil.read("./spec/test.png")
      canvas.resize(120, 120)
      PNGUtil.write(canvas, "/tmp/test.png")
      new_canvas = PNGUtil.read("/tmp/test.png")
      new_canvas.height.should eq(120)
      new_canvas.width.should eq(120)
    end
  end
end

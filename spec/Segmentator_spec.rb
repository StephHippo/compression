require './Segmentator.rb'

describe Segmentator do
  describe "build_segments" do
    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(3, "testcases/camesawleft.txt")
      @seg.stream_characters()
    end

    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(8, "testcases/mango.txt")
      @seg.stream_characters()
    end

    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(2, "testcases/empty.txt")
      @seg.stream_characters()
    end
  end
end
require './Segmentator.rb'
require './publicize.rb'
require './spec/spec_helper.rb'


describe Segmentator do
  describe "stream_characters" do

    #Good Data
    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(3, "testcases/camesawleft.txt")
      @seg.stream_characters()
    end

    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(8, "testcases/mango.txt")
      @seg.stream_characters()
    end

    #Bad Data: empty text
    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(0, "testcases/empty.txt")
      @seg.stream_characters()
    end

    #Structured Basis, Bad Data: nonexistent file
    it "streams characters of a new file and compresses segments of size k" do
      @seg = Segmentator.new(3, "testcases/nonexistentfile.txt")
      @seg.stream_characters().should raise_error
    end
  end

  describe "build_segment" do
    context "c is punctuation, seg is length 0" do
      it "should calculate the compression of the c value and seg should be clear" do
        @segmentator = Segmentator.new(3, "testcases/mango.txt")
        #TODO: DON'T DELETE THIS
        #@segmentator.instance_eval{instance_variable_set(:@seg,)}
        Segmentator.publicize(:build_segment) do
          @segmentator.build_segment('.')
        end
        seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
        seg.eql? ''
      end
    end

    #Structured Basis: first if is true

    #Structured Basis: first if is false

    #Structured Basis: second if is true

    #Structured Basis: second if is false

    #Data Flow: nested if is true

    #Data Flow: nested if is false

    #Good Data: c is a str of length 1

    #Bad Data: c is an object (wrong type)

    #Equivalence Partitioning: seg length is greater than k

  end

  describe "calculate_compression" do
    #Check that both are asserted
  end

  describe "add_to_legend" do
    #Good Data, seg is a string

    #Bad Data, seg is an object

    #Structured Basis, legend does not have seg as a key

    #Structured Basis, legend has the seg as a key
  end

  describe "update_compression_order" do
    #Structured Basis, compression-order has the key

    #Structured Basis, compression-order doesn't have the key

    #Strutured Basis, compression order is empty

    #Structured Basis, compression order contains at least 1 key
  end

  describe "print_output" do
    #Good Data: seglistposition is a number in the range of a length

    #Bad Data: seglistposition is negative

  end

  describe "print_legend" do
    #Good Data: legend has at least one key-value pair

    #Bad Data: legend is empty
  end

  describe "list_string" do
    #assert that it calls traverse_list
  end

  describe "seg_list_position" do
    #Bad Data: segnum is not a number

    #Good Data: segnum is a number in the list

    #Error Guessing: segnum is a number not in the list

    #assert that it calls traverse_list

  end

  describe "traverse_list" do
    #Structured Basis: enters the while loop at least once

    #Structured Basis: never enters the while loop

    #Bad Data: Compvalue is an object

    #Good Data: Compression order is a graph

  end

  #TODO: Stress Test
end
require './Segmentator.rb'
require './publicize.rb'
require './spec/spec_helper.rb'


describe Segmentator do
  describe "stream_characters" do

    #Structured Basis: each each_char loop
    #Good Data
    it "streams characters of a file and compresses segments of size k" do
      @seg = Segmentator.new(3, "testcases/camesawleft.txt")
      @seg.stream_characters()
    end

    #Structured Basis: Nothing to stream so skips each_char loop
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
      lambda {@seg.stream_characters()}.should raise_error
    end
  end

  describe "build_segment" do
    #1. Structured Basis: first if is true
    #6: Data Flow: second if is false
    #7. Good Data: c is a str of length 1, seg length is less than k
    context "c is punctuation, seg is length 0" do
      it "should calculate the compression of the c value and seg should be clear" do
        @segmentator = Segmentator.new(3, "testcases/mango.txt")
        @segmentator.instance_eval{instance_variable_set(:@seg,'')}
        Segmentator.publicize(:build_segment) do
          @segmentator.build_segment('.')
        end
        seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
        seg.eql? ''
        #legend should contain c
        legend = @segmentator.instance_eval{instance_variable_get(:@legend)}
        legend.has_key? '.'
        #update_compression_order should have the c's segnum first
        co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
        co[legend['.']]["next"].should be nil
        co[legend['.']]["prev"].should be nil
      end
    end

    #1. Structured Basis, if is true
    #5. Nested if is true
    #7. Good Data: c is a str of length 1, seg length is less than k
    context "c is punctuation, but seg already contains some characters" do
       it "should calculate the compression for the seg that already contains chars and calculate the compression for c, then clear the seg" do
         @segmentator = Segmentator.new(3, "testcases/mango.txt")
         @segmentator.instance_eval{instance_variable_set(:@seg,'ab')}
         Segmentator.publicize(:build_segment) do
           @segmentator.build_segment('.')
         end
         seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
         seg.eql? ''
         #legend should contain c and seg
         legend = @segmentator.instance_eval{instance_variable_get(:@legend)}
         legend.has_key? '.'
         legend.has_key? 'ab'
         #compression_order should have the c's segnum as first
         #compression_order should have the seg's segnum as second
         co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
         co[legend['.']]["prev"].should be nil
         co[legend['.']]["next"].should be legend['ab']
         co[legend['ab']]["prev"].should be legend['.']
         co[legend['ab']]["next"].should be nil
       end
    end

    #2. Structured Basis: first if is false
    #3. Structured Basis: second if is true
    #7. Good Data: c is a str of length 1
    context "c is not a punctuation character, seg length is less than k" do
      it "should append c to the seg" do
        @segmentator = Segmentator.new(3, "testcases/mango.txt")
        @segmentator.instance_eval{instance_variable_set(:@seg,'ab')}
        Segmentator.publicize(:build_segment) do
          @segmentator.build_segment('c')
        end
        seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
        seg.eql? 'abc'
      end
    end

    #2. Structured Basis: first if is false
    #4. Structured Basis: second if is false
    #7. Good Data: c is a str of length 1
    context "c is not a punctuation character and seg length is not less than k" do
      it "should calculate the compression of the full seg" do
        @segmentator = Segmentator.new(3, "testcases/mango.txt")
        @segmentator.instance_eval{instance_variable_set(:@seg,'abc')}
        Segmentator.publicize(:build_segment) do
          @segmentator.build_segment('d')
        end
        seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
        seg.eql? 'd'
        #legend should contain c and seg
        legend = @segmentator.instance_eval{instance_variable_get(:@legend)}
        legend.has_key? 'abc'
        #update_compression_order should have the c's segnum first
        co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
        co[legend['abc']]["next"].should be nil
        co[legend['abc']]["prev"].should be nil
      end
    end

    #2. Structured Basis: first if is false
    #4. Structured Basis: second if is false
    #9. Equivalence Partition: seg length is 1 greater than k
    context "seg length is greater than k" do
      it "should raise an error" do
        @segmentator = Segmentator.new(3, "testcases/mango.txt")
        @segmentator.instance_eval{instance_variable_set(:@seg,'abcd')}
        Segmentator.publicize(:build_segment) do
          lambda {@segmentator.build_segment('e')}.should raise_error
        end
      end
    end

    #8. Bad Data: c is not a str, c is an object
    context "c is not a string" do
      it "should raise an error" do
        @segmentator = Segmentator.new(3, "testcases/mango.txt")
        @segmentator.instance_eval{instance_variable_set(:@seg,'ab')}
        Segmentator.publicize(:build_segment) do
          lambda {@segmentator.build_segment(Object.new)}.should raise_error
        end
      end
    end

    #1. Structured Basis: first if is true      X
    #2. Structured Basis: first if is false     X
    #3. Structured Basis: second if is true     X
    #4. Structured Basis: second if is false    X
    #5. Data Flow: nested if is true            X
    #6. Data Flow: nested if is false           X
    #7. Good Data: c is a str of length 1       X
    #8. Bad Data: c is an object (wrong type)   X
    #9. Equivalence Partitioning: seg length is greater than k    X

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
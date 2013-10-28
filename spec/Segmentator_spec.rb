require 'simplecov'
SimpleCov.start
require './Segmentator.rb'
require './publicize.rb'
require './spec/spec_helper.rb'


describe Segmentator do
  before(:each) do
    @segmentator = Segmentator.new(3, "testcases/mango.txt")
  end

  describe "stream_characters" do

    #asserts print_legend
    context "checking assert print_legend" do
      it "should print the legend after streaming all characters" do
        #Check that both are asserted
        Segmentator.publicize(:stream_characters) do
          @segmentator.should_receive(:print_legend)
          @segmentator.stream_characters
        end
      end
    end

    #asserts update_compression_order
    context "calls calculate_compression" do
      it "should call calculate compression on the final seg" do
        @segmentator.instance_eval{instance_variable_set(:@seg,'abc')}
        Segmentator.publicize(:calculate_compression) do
          seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
          @segmentator.should_receive(:update_compression_order)
          @segmentator.calculate_compression(seg)
        end
      end
    end

    #Structured Basis: each_char loop
    #Good Data
    it "streams characters of a file and compresses segments of size k" do
      out = capture_stdout do
        @segmentator.stream_characters()
      end
      out.should == "1\t\t1\t\t0\n2\t\t21\t\t1\n'Man':1 'go':2 \n"
    end

    #Structured Basis: Nothing to stream so skips each_char loop
    #Bad Data: empty text
    it "streams characters of a file and compresses segments of size k" do
      @segmentator = Segmentator.new(0, "testcases/empty.txt")
      out = capture_stdout do
        @segmentator.stream_characters()
      end
      out.should == "\n"
    end

    #Structured Basis: first if is true
    #Bad Data: nonexistent file
    context "tries to stream a nonexistent file" do
      it "should raise an error and exit" do
        @segmentator = Segmentator.new(3, "testcases/nonexistentfile.txt")
        lambda {@segmentator.stream_characters()}.should raise_error
      end
    end

    #Error guessing, inputting data out of order
    context "user enters k and file name backwards" do
      it "should raise an error" do
        @seg = Segmentator.new("testcases/mango.txt", 3)
        lambda {@seg.stream_characters()}.should raise_error
      end
    end
  end

  describe "build_segment" do
    #1. Structured Basis: first if is true
    #6: Data Flow: second if is false
    #7. Good Data: c is a str of length 1, seg length is less than k
    context "c is punctuation, seg is length 0" do
      it "should calculate the compression of the c value and seg should be clear" do
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
        @segmentator.instance_eval{instance_variable_set(:@seg,'abcd')}
        Segmentator.publicize(:build_segment) do
          lambda {@segmentator.build_segment('e')}.should raise_error
        end
      end
    end

    #8. Bad Data: c is not a str, c is an object
    context "c is not a string" do
      it "should raise an error" do
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
    #asserts update_compression_order
    context "both methods are called" do
      it "should pass seg and segnum to add_to_legend and calculate_compression" do
        #Check that both are asserted
        @segmentator.instance_eval{instance_variable_set(:@seg,'abc')}
        Segmentator.publicize(:calculate_compression) do
          seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
          @segmentator.should_receive(:add_to_legend)
          @segmentator.calculate_compression(seg)
        end
      end
    end

    #asserts update_compression_order
    context "both methods are called" do
      it "should pass seg and segnum to add_to_legend and calculate_compression" do
        #Check that both are asserted
        @segmentator.instance_eval{instance_variable_set(:@seg,'abc')}
        Segmentator.publicize(:calculate_compression) do
          seg = @segmentator.instance_eval{instance_variable_get(:@seg)}
          @segmentator.should_receive(:update_compression_order)
          @segmentator.calculate_compression(seg)
        end
      end
    end
  end

  describe "add_to_legend" do
    #1. Structured Basis: legend does not have seg as a key
    #3. Good Data: seg is a string
    #5. Data Flow: Defined-Used adding a legend key
    #6. Data Flow: Defined-Used incrementing segvalue
    context "seg is not a legend key" do
      it "should add the seg to the legend and assign it a segvalue" do
        seg = 'abc'
        segval = @segmentator.instance_eval{instance_variable_get(:@segvalue)}
        Segmentator.publicize(:add_to_legend) do
          @segmentator.add_to_legend(seg)
        end
        legend = @segmentator.instance_eval{instance_variable_get(:@legend)}
        legend.has_key? seg
        segval2 = @segmentator.instance_eval{instance_variable_get(:@segvalue)}
        segval2 == segval + 1
      end
    end

    #2. Structured Basis: legend has the seg as a key
    #3. Good Data: seg is a string
    #5. Data Flow: Defined-Used adding a legend key
    #6. Data Flow: Defined-Used incrementing segvalue
    context "seg is already a legend key" do
      it "should leave the legend unchanged" do
        h = {'abc' => 1}
        legend = @segmentator.instance_eval{instance_variable_set(:@legend, h)}
        legend = @segmentator.instance_eval{instance_variable_get(:@legend)}
        seg = 'abc'
        segval = @segmentator.instance_eval{instance_variable_get(:@segvalue)}
        legend.has_key? seg
        Segmentator.publicize(:add_to_legend) do
          @segmentator.add_to_legend(seg)
        end
        legend2 = @segmentator.instance_eval{instance_variable_get(:@legend)}
        legend2 == legend
        segval2 = @segmentator.instance_eval{instance_variable_get(:@segvalue)}
        segval2 == segval
      end
    end

    #4. Bad Data: seg is an object
    context "seg is not a string value" do
      it "should raise an error" do
        Segmentator.publicize(:add_to_legend) do
          lambda {@segmentator.add_to_legend(Object.new)}.should raise_error
        end
      end
    end

    #1. Structured Basis: legend does not have seg as a key     X
    #2. Structured Basis: legend has the seg as a key           X
    #3. Good Data: seg is a string                              X
    #4. Bad Data: seg is an object                              X
    #5. Data Flow: Defined-Used adding a legend key             X
    #6. Data Flow: Defined-Used incrementing segvalue           X

  end

  describe "update_compression_order" do
    #1. Structured Basis: if first if is true, compression-order has the key
    #3. Structured Basis: second if is true, compression order is empty
    #5. Good Data: segnum is a number in the compression order
    #7. Data Flow: Defined-Used compression order before/after values
    context "segnum is in the compression order" do
      it "moves segnum node to the front of the list and outputs the order" do
        legendvals = {'abc' => 1, 'def' => 2}
        @segmentator.instance_eval{instance_variable_set(:@legend, legendvals)}
        legend = @segmentator.instance_eval{instance_variable_get(:@legend)}

        co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:update_compression_order) {@segmentator.update_compression_order(1)}

        co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
        co[1]["next"] == 2
        co[1]["prev"] == nil
        co[2]["next"] == nil
        co[2]["prev"] == 1
      end
    end

    #1. Structured Basis: if first if is true, compression-order has the key
    #4. Structured Basis: second if is false, compression order contains at least 1 key
    #5. Good Data: segnum is a number in the compression order
    #7. Data Flow: Defined-Used compression order before/after values
    context "segnum is the only node to be added to the list" do
      it "adds it to the compression hash and moves to the front" do
        co = {1 => {"next" => nil, "prev" => nil}}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:update_compression_order) {@segmentator.update_compression_order(3)}

        co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
        co[1]["next"] == nil
        co[1]["prev"] == nil
      end
    end

    #2. Structured Basis: first if is false, compression-order doesn't have the key
    #3. Structured Basis: second if is true, compression order is empty
    #5. Good Data: segnum is a number in the compression order
    #7. Data Flow: Defined-Used compression order before/after values
    context "segnum is not in the compression order" do
      it "adds it to the compression hash and moves to the front" do

        co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:update_compression_order) {@segmentator.update_compression_order(3)}

        co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
        co[1]["next"] == nil
        co[1]["prev"] == 2
        co[2]["next"] == 1
        co[2]["prev"] == 3
        co[3]["next"] == 2
        co[3]["prev"] == nil
      end
    end

    #2. Structured Basis: first if is false, compression-order doesn't have the key
    #4. Structured Basis: second if is false, compression order contains at least 1 key
    #5. Good Data: segnum is a number that is in the compression order
    #7. Data Flow: Defined-Used compression order before/after values
    context "compression order is empty, this will be the first node" do
      it "adds a single node to the list" do
        co = {}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:update_compression_order) {@segmentator.update_compression_order(1)}

        co = @segmentator.instance_eval{instance_variable_get(:@compression_order)}
        co[1]["next"] == nil
        co[1]["prev"] == nil
      end
    end

    #7. Bad Data: segnum is an Object
    context "compression order is empty, this will be the first node" do
      it "adds a single node to the list" do
        co = {}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:update_compression_order) do
          lambda {@segmentator.update_compression_order(Object.new)}.should raise_error
        end
      end
    end

    #1. Structured Basis: first if is true, compression-order has the key               X
    #2. Structured Basis: first if is false, compression-order doesn't have the key     X
    #3. Structured Basis: second if is true, compression order is empty                 X
    #4. Structured Basis: second if is false, compression order contains at least 1 key X
    #5. Good Data: segnum is a number that is in the compression order                  X
    #6. Bad Data: segnum is a number not in the legend                                  X
    #7. Data Flow: Defined-Used compression order before/after values                   X
  end

  describe "print_output" do
    #1. Good Data: seglistposition is a number in the range of a length
    context "seglist position is a valid place in the list and has corresponding legend values" do
      it "should generate a line of the output table" do
        legendvals = {'abc' => 1, 'def' => 2, 'ghi' => 3}
        @segmentator.instance_eval{instance_variable_set(:@legend, legendvals)}

        seg = 'ghi'
        @segmentator.instance_eval{instance_variable_set(:@seg, seg)}

        co = {1 => {"next" => nil, "prev" => 2},
              2 => {"next" => 1, "prev" => 3},
              3 => {"next" => 2, "prev" => nil}}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:print_output) do
          out = capture_stdout do
            @segmentator.print_output(2)
          end
          out.should == "3\t\t321\t\t2\n"
        end
      end
    end

    #2. Bad Data: seglistposition is negative
    #1. Good Data: seglistposition is a number in the range of a length
    context "seglist position is a valid place in the list and has corresponding legend values" do
      it "should generate a line of the output table" do
        legendvals = {'abc' => 1, 'def' => 2, 'ghi' => 3}
        @segmentator.instance_eval{instance_variable_set(:@legend, legendvals)}

        seg = 'ghi'
        @segmentator.instance_eval{instance_variable_set(:@seg, seg)}

        co = {1 => {"next" => nil, "prev" => 2},
              2 => {"next" => 1, "prev" => 3},
              3 => {"next" => 2, "prev" => nil}}
        @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}

        Segmentator.publicize(:print_output) do
          lambda{@segmentator.print_output(-2)}.should raise_error
        end
      end
    end
  end

  describe "print_legend" do
    #Good Data: legend has at least one key-value pair
    context "legend has some valid values" do
      it "should output the formatted legend" do
        legendvals = {'abc' => 1, 'def' => 2, 'ghi' => 3}
        @segmentator.instance_eval{instance_variable_set(:@legend, legendvals)}

        Segmentator.publicize(:print_legend) do
          out = capture_stdout do
            @segmentator.print_legend()
          end
          out.should == "'abc':1 'def':2 'ghi':3 \n"
        end
      end
    end

    #Bad Data: legend is empty
    context "legend has some valid values" do
      it "should output the formatted legend" do
        legendvals = {}
        @segmentator.instance_eval{instance_variable_set(:@legend, legendvals)}

        Segmentator.publicize(:print_legend) do
          out = capture_stdout do
            @segmentator.print_legend()
          end
          out.should == "\n"
        end
      end
    end
  end

  describe "list_string" do
    #asserts traverse_list
    context "given a valid compression list" do
      it "should output the string representation of the list" do
        Segmentator.publicize(:list_string) do
          co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          @segmentator.should_receive(:traverse_list)
          @segmentator.list_string
        end
      end
    end

    #Good Data: returns the correct string
    context "given a valid compression list" do
      it "should output the string representation of the list" do
        Segmentator.publicize(:list_string) do
          co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          @segmentator.list_string.should == "21"
        end
      end
    end

    #Bad Data: compromised list with 2 "head" nodes
    context "given a compromised compression list" do
      it "should output the string representation of the list" do
        Segmentator.publicize(:list_string) do
          co = {1 => {"next" => nil, "prev" => nil}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          lambda{@segmentator.list_string}.should raise_error
        end
      end
    end
  end

  describe "seg_list_position" do
    #asserts traverse_list
    context "given a valid compression list" do
      it "should assert traverse list" do
        Segmentator.publicize(:seg_list_position) do
          co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          @segmentator.should_receive(:traverse_list)
          @segmentator.seg_list_position(1)
        end
      end
    end

    #Good Data: segnum is a number in the list
    context "given a valid compression list" do
      it "should return the order of the segment in the list" do
        Segmentator.publicize(:seg_list_position) do
          co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          @segmentator.seg_list_position(1)
        end
      end
    end

    #Bad Data: segnum is not a number
    context "given an object instead of an integer" do
      it "should raise an error" do
        Segmentator.publicize(:seg_list_position) do
          co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          lambda{@segmentator.seg_list_position(Object.new)}.should raise_error
        end
      end
    end
  end

  describe "traverse_list" do
    #1. Structured Basis: while loop walks down the whole list
    #4. Good Data: Compression order is a graph
    context "the value we're looking for is the tail of the list" do
      it "loops through the entire list" do
        Segmentator.publicize(:traverse_list) do
          ct = 0
          co = {1 => {"next" => nil, "prev" => 2}, 2 => {"next" => 1, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          @segmentator.traverse_list(nil){|nodenum| ct += 1}.should be 2
        end
      end
    end

    #2. Structured Basis: never enters the while loop
    #4. Good Data: Compression order is a graph
    context "the list has only one node" do
      it "should never enter the list" do
        Segmentator.publicize(:traverse_list) do
          ct = 0
          co = {1 => {"next" => nil, "prev" => nil}}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          @segmentator.traverse_list(nil){|nodenum| ct += 1}.should be 1
        end
      end
    end

    #3. Bad Data: Compvalue is an object
    context "the list is empty" do
      it "should never enter the list" do
        Segmentator.publicize(:traverse_list) do
          ct = 0
          co = {}
          @segmentator.instance_eval{instance_variable_set(:@compression_order, co)}
          lambda{@segmentator.traverse_list(nil){|nodenum| ct += 1}}.should raise_error
        end
      end
    end

    #1. Structured Basis: enters the while loop at least once
    #2. Structured Basis: never enters the while loop
    #3. Bad Data: Compvalue is an object
    #4. Good Data: Compression order is a graph

  end

  #TODO: Stress Test
end
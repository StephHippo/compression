
class Segmentator
#legend - a simple hash
#compression_order - an ordereddict (nested hash)
#seg - a mutable string
#segvalue - counter for tallying the placeholders in the legend hash


  def initialize(k, filename)
    @k = k
    @file = filename
    @legend = Hash.new
    @seg = ''
    @segvalue = 1
    @compression_order = Hash.new
  end

  #Passes each character of the file source to be added to a segment
  #  Runtime: O(c) where c is the number of characters in the stream

  #void stream_characters(File source)
  def stream_characters(filename)
    #if the source exists
    if File.exists?(@file)
      #open the source
      f = File.open(@file)
      puts "opened file"
      #stream each character to build_segment(char c)
      f.each_char {|c| build_segment(c)}
      #*Added code to compensate for no EOF character*
      calculate_compression(@seg) unless @seg.length == 0
      print_legend
    #else
    else
      #raise an error that “No source was found”
      raise "No source was found"
      #exit the program
      exit
    #endif
    end
  #end
  end

private
#Builds the newest segment value character by character and checks for punctuation characters
#  Runtime: O(n)
#	 Constant building of the segments
#  calculate_compression runs in linear time as explained below

#void build_segment(char c)
  def build_segment(c)
    #if c is a punctuation character
    if c =~ /[[:punct:]]|\s/
      #if |seg| != 0
      if @seg.length != 0
        #calculate_compression(seg)
        calculate_compression(@seg)
        #seg ← ‘’
        @seg = ''
        #calculate_compression(c)
        calculate_compression(c)
      #endif
      end
    elsif @seg.length < @k
      #append c to seg
      @seg << c
    elsif @seg.length == @k
      #calculate_compression(seg)
      puts "calculating the compression for #{@seg}"
      calculate_compression(@seg)
      #seg ← ‘’
      @seg = c
    #endif
    end
  end

  # Was anticipating an EOF character like in C, forgetting that it's not a thing in ruby
  # This pseudocode has been implemented inside the stream_characters method
  #  at the end of the input
  #  if |seg| != 0
  #  calculate_compression(seg)
  #  endif
  #  end
  #
  # Whenever you add to the legend, you must also update the compression order in the ordered dictionary, so encapsulated to reduce duplicated code.
  # Runtime: O(n)
  #  Constant Hash insert for legend
  #  Linear time for update_compression_order, explained below
  #
  #  void calculate_compression(seg)
  def calculate_compression(seg)
    #add_to_legend(seg)				                (add seg to the legend)
    add_to_legend(seg)
    #update_compression_order(legend[seg])		(update the ordered dictionary)
    update_compression_order(@legend[seg])
  #end
  end

  #Inserts a new seg to the legend and increment the segment key number. If the segment is already in the hash, it does nothing
  #Runtime: O(1)
  #Constant Hash insertion
  #
  #void add_to_legend(String seg)
  def add_to_legend(seg)
    #if seg isn’t already a key in the Hash legend
    unless @legend.has_key? seg
      #legend[seg] ← segvalue
      @legend[seg] = @segvalue
      #increment the segvalue by 1
      @segvalue += 1
    #endif
    end
  #end
  end


  # The compression order is a nested hash to represent an ordereddict. The first set of keys each map to another hash that contain a next and previous key that store a value of the next seg in the list
  # Run_time: O(n) where n is the number of segments in the ordereddict
  #	Constant ordered dictionary lookup
  #	Constant ordered dictionary update
  #	Linear seglistposition lookup
  #
  #  void update_compression_order(String seg)
  def update_compression_order(segnum)

    #if seg is already a key in the top-level of the dictionary
    if @compression_order.has_key? segnum
      indexes = Hash[@compression_order.map.with_index.to_a]
      seglistposition = indexes[segnum]
    else
      seglistposition = @compression_order.keys.length
      @compression_order[segnum] = {"next" => nil, "prev" => nil}
    end

    #move key to the front if it isn't the only key
    if @compression_order.keys.length > 1
      #update the old head’s previous value to seg
      former_head = @compression_order.find{|key, hash| hash["prev"].nil?}
      head_key = former_head[0]
      @compression_order[head_key]["prev"] = segnum

      #update the seg’s previous and next nodes’ previous and next values
      segprev = @compression_order[segnum]["prev"]
      segnext = @compression_order[segnum]["next"]
      @compression_order[segprev]["next"] = segnext unless segprev.nil?
      @compression_order[segnext]["prev"] = segprev unless segnext.nil?

      #move seg to the front of the list
      @compression_order[segnum]["next"] = head_key
      @compression_order[segnum]["prev"] = nil
    end

    #print_output(seglistposition)
    print_output(seglistposition)
  #end
  end

  #prints out both the legend and the compressed code order
  #Runtime: O(n)
  #	constant access and printing for printing an element in the legend
  #	linear printing of the most recent compressed list
  #	constant printing of the seglistposition (already passed in)
  #
  #  void print_output(seglistposition)
  def print_output(seglistposition)
    #print legend[seg]
    puts "Input: #{@legend[@seg]}\n"
    #print_compression_order()
    print_compression_order
    #print seglistposition
    puts "Output: #{seglistposition}."
  #end
  end


  # prints legend by traversing a double linked list represented by the ordered dictionary
  # Runtime: O(n) where n is the number of segments in the ordereddict
  #
  #void print_legend()
  def print_legend
    #for each key-value pair in the hash concatenate the key and the value into a string
    str = ""
    @legend.each do |key, value|
      str << "'#{key}':#{value} "
    end
    #print the string
    puts str
  #end
  end

  #Traverses the ordereddict to give the full compression order
  #Runtime: O(n) where n is the number of segments in the list.

  #void print_compression_order()
  def print_compression_order
    #beginning with the key with a previous value of null
    head = @compression_order.find{|key, hash| hash["prev"].nil?}
    nodenum = head.first
    while !(@compression_order[nodenum]["next"].nil?)
      #Traverse the double linked list by following the next value
      puts nodenum
      #print next values until end of list is reached
      nodenum = @compression_order[nodenum]["next"]
    end
    puts nodenum
    #end
  end
end

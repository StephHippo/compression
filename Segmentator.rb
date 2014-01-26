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
  def stream_characters
    if File.exists?(@file)
      f = File.open(@file)
      f.each_char {|c| build_segment(c)}
      calculate_compression(@seg) unless @seg.length == 0
      print_legend
    else
      raise "No source was found"
      exit
    end
  end

#private
	#Builds the newest segment value character by character and checks for punctuation characters
	#  Runtime: O(n)
	#	 Constant building of the segments
	#  calculate_compression runs in linear time as explained below
  def build_segment(c)
	  raise "Segment length is greater than limit k, #{@seg} and #{@k}" unless @seg.length <= @k
	  raise "More than one character passed to build_segment: #{c}" unless c.length == 1
	  if c =~ /[[:punct:]]|\s/
      calculate_compression(@seg) unless @seg.length == 0
      @seg = c
      calculate_compression(@seg)
      @seg = ''
    elsif @seg.length < @k
      @seg << c
		elsif @seg.length == @k
      calculate_compression(@seg)
      @seg = c
		end
  end

  # Whenever you add to the legend, you must also update the compression order in the ordered dictionary, so encapsulated to reduce duplicated code.
  # Runtime: O(n)
  #  Constant Hash insert for legend
  #  Linear time for update_compression_order, explained below
  def calculate_compression(seg)
    add_to_legend(seg)
    update_compression_order(@legend[seg])
  end

  #Inserts a new seg to the legend and increment the segment key number. If the segment is already in the hash, it does nothing
  #Runtime: O(1)
  #Constant Hash insertion
  def add_to_legend(seg)
    raise "Segment is not a string" unless (seg.is_a? String)
    #if seg isn’t already a key in the Hash legend
    unless @legend.has_key? seg
      @legend[seg] = @segvalue
      @segvalue += 1
    end
  end

  # The compression order is a nested hash to represent an ordereddict. The first set of keys each map to another hash that contain a next and previous key that store a value of the next seg in the list
  # Run_time: O(n) where n is the number of segments in the ordereddict
  #	Constant ordered dictionary lookup
  #	Constant ordered dictionary update
  #	Linear seglistposition lookup
  def update_compression_order(segnum)
		raise "Not a valid segment number #{segnum}." unless ((segnum.is_a? Fixnum) && (segnum >= 0))
    #if seg is already a key in the top-level of the dictionary
    if @compression_order.has_key? segnum
      seglistposition = seg_list_position(segnum)
      #indexes = Hash[@compression_order.keys.map.with_index.to_a]
      #seglistposition = indexes[segnum]
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

    print_output(seglistposition)
  end

  #prints out both the legend and the compressed code order
  #Runtime: O(n)
  #	constant access and printing for printing an element in the legend
  #	linear printing of the most recent compressed list
  #	constant printing of the seglistposition (already passed in)
  def print_output(seglistposition)
		raise "Invalid list position" unless ((seglistposition >= 0) && (seglistposition.is_a? Fixnum))
    str = ""
    str << "#{@legend[@seg]}\t\t"
    str << list_string
    str << "\t\t#{seglistposition}\n"
    puts str
  #end
  end


  # prints legend by traversing a double linked list represented by the ordered dictionary
  # Runtime: O(n) where n is the number of segments in the ordereddict
  def print_legend
    str = ""
    @legend.each do |key, value|
      str << "'#{key}':#{value} "
    end
    puts str
  end

  #Traverses the ordereddict to give the full compression order
  #Runtime: O(n) where n is the number of segments in the list.
  def list_string
    str = ''
    traverse_list(nil) {|nodenum| str << nodenum.to_s}
    str
  end

  #return the position of the number in the list
  def seg_list_position(segnum)
    pos = 0
    traverse_list(segnum) {|nodenum| pos += 1}
    pos
  end

  def traverse_list(compvalue)
    head = @compression_order.find{|key, hash| hash["prev"].nil?}
    nodenum = head.first

    while(@compression_order[nodenum]["next"] != compvalue)
      yield nodenum
      nodenum = @compression_order[nodenum]["next"]
    end

    yield nodenum

  end
end

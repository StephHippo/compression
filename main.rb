require './Segmentator.rb'

begin

  unless ARGV[0].nil? || ARGV[1].nil?
    k = ARGV[0].to_i
    file = ARGV[1]
  else
    puts "What is the value of k?"
    k = gets
    k = k.to_i
    puts "What is the name of the file?"
    file = gets
    file = file.delete("\n")
  end

  segmentator = Segmentator.new(k, file)
  segmentator.stream_characters()

end
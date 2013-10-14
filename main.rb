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
  puts "k is #{k} and file is #{file}"
  puts "Found file" if File.exists?(file)
  segmentator = Segmentator.new(k, file)
  segmentator.stream_characters(file)

end
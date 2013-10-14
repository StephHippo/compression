all:
	ruby -c Segmentator.rb
	ruby -c main.rb

test:
	rspec spec

rdoc:
	rm -r doc
	rdoc
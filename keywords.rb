#!/usr/bin/ruby
# Encoding: utf-8
require 'stemmify'

# Keywords assumes that short words are not likely to be important.
# Change this value to set the minimum word length.
MinLength = 5

# We generally only need a handful of keywords to perform a useful
# search.  Change this value to set how many will be used.
MaxWords = 10

# Holds an individual word.
class Word
  attr_accessor :name, :count, :stem

  def initialize(name)
    @name = name
    @count = 1
    @stem = name.stem
  end
end

# Collects words into groups based on their stem.
class Stem
  attr_accessor :name, :instances, :shortest, :count

  def initialize(name)
    @name = name
    @count = 0
    @shortest = nil
    @instances = Array.new
  end

  # Handles the maintenance of finding another word with the same stem.
  def add(word)
    @instances << word
    @count += word.count
    @instances.each do |i|
      if @shortest == nil || @shortest.length > i.name.length
        @shortest = i.name
      end
    end
  end
end

# We need a file name
if ARGV.length < 1
  puts <<USAGE
Usage:
  ruby #{__FILE__} <file.txt>

USAGE
  exit
end
inputname = ARGV[0]

# Grab the words we're going to ignore.
commonwords = File.readlines("c.txt")
commonwords = commonwords.collect { |cw| cw.strip }

# Assume that any word that isn't short or common to most correspondence
# is of interest.
message = Hash.new
File.foreach(inputname) do |s|
  s = s.chop.downcase
  s = s.gsub(/\p{^Alpha}/, ' ')
  s.split(' ').each do |w|
    next if commonwords.include?(w) || w.length < MinLength
    if message[w] == nil
      message[w] = Word.new(w)
    else
      wd = message[w]
      wd.count += 1
    end
  end
end

# Collect the words by stem.
stems = Hash.new
message.each_value do |w|
  s = w.stem
  stem = nil
  if stems[s] == nil
    stem = Stem.new(s)
    stems[s] = stem
  else
    stem = stems[s]
  end
  stem.add(w)
end

# Sort by frequency.
stems = stems.to_a.collect { |kv| kv[1] }.sort { |a,b| a.count <=> b.count }

# Grab the most frequent
n = [MaxWords, stems.length].min
stems[-n..-1].each { |s| puts s.shortest + " (" + s.count.to_s + ")" }


#!/usr/bin/ruby
# Encoding: utf-8
require 'net/http'
require 'uri'
require 'stemmify'

# This is only a toy.  Do not use for anything resembling production work.
# The program's basic premise is to take a text, grab the most frequent
# uncommon words, and determine if Snopes has a verdict.

# Keywords assumes that short words are not likely to be important.
# Change this value to set the minimum word length.
MIN_LENGTH = 5

# We generally only need a handful of keywords to perform a useful
# search.  Change this value to set how many will be used.
MAX_WORDS = 10

# Just pulling out the keywords isn't very useful.  In this case,
# we'll check Snopes to see if they have a source and use
# DuckDuckGo's non-JavaScript search for the actual search.
SEARCH_SITE = 'https://duckduckgo.com/html/?q=site%3A'
SEARCH_TARGET = 'snopes.com'
BASE_SEARCH_URL = SEARCH_SITE + SEARCH_TARGET + '+'

# Holds an individual word.
class Word
  @name = nil
  @count = nil
  @stem = nil

  attr_reader :name, :count, :stem

  def initialize(name)
    @name = name
    @count = 1
    @stem = name.stem
  end

  def add
    @count += 1
  end
end

# Collects words into groups based on their stem.
class Stem
  @name = nil
  @instances = nil
  @shortest = nil
  @count = nil

  attr_reader :count, :shortest

  def initialize(name)
    @name = name
    @count = 0
    @shortest = ''
    @instances = []
  end

  # Handles the maintenance of finding another word with the same stem.
  def add(word)
    @instances << word
    @count += word.count
    @instances.each do |instance|
      name = instance.name
      @shortest = name if @shortest == '' || @shortest.length > name.length
    end
  end
end

# Utility class to mediate web access
class Httper
  @url = nil

  def initialize(html)
    @url = URI.parse(html)
  end

  # Simple--possibly oversimplified--routine to send an HTTP request and
  # filter out lines that fail to match a pattern.
  def get_lines(filter)
    result = Net::HTTP.start(@url.host, @url.port, use_ssl: @url.scheme == 'https') do |http|
      http.get(@url.to_s)
    end
    return [''] unless result.is_a?(Net::HTTPSuccess)
    result.body.split("\n").select { |line| line =~ filter }
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
commonwords = File.readlines('c.txt').map { |cw| cw.strip }

# Assume that any word that isn't short or common to most correspondence
# is of interest.
message = {}
File.foreach(inputname) do |s|
  s.chop.downcase.gsub(/\p{^Alpha}/, ' ').split(' ').each do |w|
    next if commonwords.include?(w) || w.length < MIN_LENGTH
    if message[w].nil?
      message[w] = Word.new(w)
    else
      wd = message[w]
      wd.add
    end
  end
end

# Collect the words by stem.
stems = {}
message.each_value do |w|
  s = w.stem
  stem = nil
  if stems[s].nil?
    stem = Stem.new(s)
    stems[s] = stem
  else
    stem = stems[s]
  end
  stem.add(w)
end

# Sort by frequency.
stems = stems.to_a.map { |kv| kv[1] }.sort { |a, b| a.count <=> b.count }

# Grab the most frequent keywords for the search string.
n = [MAX_WORDS, stems.length].min
puts stems[-n..-1].map { |s| s.shortest }.join(' ')
url = BASE_SEARCH_URL + stems[-n..-1].map { |s| s.shortest }.join('+')

# Get the first search result and find the verdict.
lines = Httper.new(url).get_lines(/<a rel="nofollow" class="large" /)
parts = lines[0].split('"')
lines = Httper.new(parts[5]).get_lines(/<NOINDEX><TABLE>/)
lines.each { |l| puts l.gsub(/<[^>]*>/, '') }

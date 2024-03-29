#!/usr/bin/env ruby

#
# Output a single random line from a given file, stable for a given day.
#
# Usage:
#
# % daily-message.rb <filename|directory> [date]
#
# Examples:
#
# % daily-message.rb /usr/share/dict/words
# > tomfoolishness
# % daily-message.rb /usr/share/dict/words 2019-08-20
# > Bolognese
#

require "date"
require "find"

usage = "usage: #{$0} <filename|directory> [date]"

RANDOM_KEY = 8675309  # changing this changes the stable random order for all days
START_DATE = Date.parse("2019-08-16") # this is the epoch, from which we compute a stable date offset

# choose a permutation of `list` uniformly at random, destructively alter `list`
def permute!(list)
  srand(RANDOM_KEY)
  0.upto(list.length-1) do |current|
    swap_index = current + rand(list.length - current)
    list[current], list[swap_index] = list[swap_index], list[current]
  end
end

# which message do we choose for this specific date?
def chosen_message(on_date, list)
  delta = (on_date - epoch).to_i
  offset = (delta + list.length) % list.length
  list[offset]
end

# when do we consider the epoch, for stable date computations
def epoch
  START_DATE
end

# read a text file of messages, one per line, returning an array of messages (no newlines)
def read_message_file(location)
  File.readlines(location).map {|line| line.chomp }.reject {|line| line.empty? }
end

# read all message files in a directory; return sorted array of all messages
def read_message_directory(location)
  messages = []
  Find.find(location) do |path|
    next if File.directory?(path)
    messages += read_message_file(path)
  end
  messages.sort
end

# read and return array of all messages at a (file or directory) location
def retrieve_messages(location)
  if File.directory?(location)
    read_message_directory(location)
  else
    read_message_file(location)
  end
end

messages = []
if message_file = ARGV.shift
  begin
    messages = retrieve_messages(message_file)
  rescue Errno::ENOENT
    STDERR.puts "File not found: #{message_file}\n#{usage}"
    exit 1
  end
else
  STDERR.puts usage
  exit 1
end

if input_date = ARGV.shift
  date = Date.parse(input_date)
else
  date = Date.today
end

permute!(messages)

puts chosen_message(date, messages)



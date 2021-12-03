#!/usr/bin/env ruby

count = 0
last_number = nil

File.readlines(ARGV[0]).each do |line|
  current_number = line.to_i
  
  if last_number.nil? == false && current_number > last_number
    count += 1
  end
  
  last_number = current_number
end

puts "Increases: #{count.to_s}"

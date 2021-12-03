#!/usr/bin/env ruby

count = 0
window = []
last_window_sum = nil


File.readlines(ARGV[0]).each do |line|
  current_number = line.to_i

  window.push(current_number)
  window.shift() if window.count > 3  
  
  if window.count == 3
    current_window_sum = window.sum
    
    if last_window_sum.nil? == false && current_window_sum > last_window_sum
      count += 1
    end
    
    last_window_sum = current_window_sum
  end
end

puts "Increases: #{count.to_s}"

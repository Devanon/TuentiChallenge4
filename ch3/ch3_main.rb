#! /usr/bin/env ruby

cases_no = gets.chomp.to_i

cases_no.times do 
  input = gets.chomp.split(' ')
  
  i1 = (input[0].to_i) ** 2
  i2 = (input[1].to_i) ** 2

  puts Math.sqrt(i1 + i2).round(2)
end


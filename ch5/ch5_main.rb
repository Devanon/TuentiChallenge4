#! /usr/bin/env ruby

require 'digest'

# Calculate neighbours for a cell given its index
def neighbours(cell_number)
  neighbours = []
  
  #left, right
  neighbours << cell_number - 1 unless (cell_number % 8) == 0
  neighbours << cell_number + 1 unless (cell_number % 8) == 7
  #up, down
  neighbours << cell_number - 8 unless cell_number < 8
  neighbours << cell_number + 8 unless cell_number > 55
  #up-left, up-right
  neighbours << cell_number - 9 unless (cell_number % 8) == 0 or cell_number < 8
  neighbours << cell_number - 7 unless (cell_number % 8) == 7 or cell_number < 8
  #down-left, down-right
  neighbours << cell_number + 7 unless (cell_number % 8) == 0 or cell_number > 55
  neighbours << cell_number + 9 unless (cell_number % 8) == 7 or cell_number > 55 

  neighbours  
end


# MAIN
current_state = ''
next_state = Array.new(64, 0)

gen_counter = 1
gens_hash = {}

# Get initial state from input
8.times do
  current_state << gets.chomp
end
# Store it on the hash
gens_hash[Digest::SHA1.hexdigest(current_state)] = 0

# Convert string to array
current_state = current_state.split('')


# Loop 105 times calculating generations
while gen_counter < 105

  # Scan current generation counting neighbours
  64.times do |i|
    if current_state[i] == 'X'
      neighbours(i).each do |cell|
        next_state[cell] += 1
      end
    end
  end

  # Create next gen
  next_state.each_with_index do |count, index|
    if count == 3 and current_state[index] == '-'
      next_state[index] = 'X'
    elsif count < 2 or count > 3
      next_state[index] = '-'
    else
      next_state[index] = current_state[index]
    end
  end

  current_state = next_state.dup
  next_state = Array.new(64, 0)

  hash = Digest::SHA1.hexdigest(current_state.join(''))

  if gens_hash[hash] == nil # No repetition
    gens_hash[hash] = gen_counter

  else # Loop found
    puts gens_hash[hash].to_s + ' ' + (gen_counter - gens_hash[hash]).to_s
    exit 0
  end
  
  gen_counter += 1
end

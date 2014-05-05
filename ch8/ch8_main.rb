#! /usr/bin/env ruby

State = Struct.new(:score, :changes, :array)

def read_state_from_stdin()
  state = []
    # 1st line
  state << gets.chomp.split(',').each { |v| v.gsub!(/ /,'') }
  state.flatten!
  # 2nd line
  input = gets.chomp.split(',').each { |v| v.gsub!(/ /,'') }
  state[3] = input[2]
  state[7] = input[0]
  # 3rd line
  input = gets.chomp.split(',').each { |v| v.gsub!(/ /,'') }
  state[4] = input[2]
  state[5] = input[1]
  state[6] = input[0]

  return state.map { |v| v.to_sym }
end

def calculate_score(current_state, end_state)
  score = 0
  8.times do |i|
    score += 2 if current_state[i] == end_state[i]
    #score += 1 if current_state[(i-1)%8] == end_state[i] or current_state[(i+1)%8] == end_state[i]
  end
end


# MAIN

# Get number of cases
num_of_cases = gets.chomp.to_i

num_of_cases.times do
  # Get the initial and final states from stdin
  gets # Skip empty line
  init_state = read_state_from_stdin
  gets # Skip empty line
  end_state = read_state_from_stdin
  
  best_move = 1.0/0
  pending_states = []
  pending_states << State.new(calculate_score(init_state, end_state), 0, init_state)
  evaluated_states = []

  while !pending_states.empty?

    current_state = pending_states.shift
    next if current_state.changes >= best_move
    
    if current_state.array == end_state and current_state.changes < best_move
      best_move = current_state.changes
    end

    8.times do |i|
      temp = current_state.array.dup
      temp[i], temp[(i+1)%8] = temp[(i+1)%8], temp[i]
      if !evaluated_states.include?(temp.join.hash)
        pending_states << State.new(calculate_score(temp, end_state), current_state.changes + 1, temp)
      end
    end
    pending_states.sort_by! { |v| -v.score }
    
    evaluated_states << current_state.array.join.hash
  end

  puts best_move
end

#! /usr/bin/env ruby

require 'pry'

class String

  # Returns true if both strings only differ in one character
  def mutable_to? string
    one_change = false
    string.split('').each_with_index do |char, i|
      next if self[i] == char
      if not one_change
        one_change = true
      else
        return false
      end
    end
    return one_change
  end
end

Node = Struct.new :state, :no_of_changes, :output

class SkinChanger
  def initialize(init_state, end_state, safe_states)
    @end_state = end_state
    @safe_states = safe_states
  
    @pending_nodes = []
    @pending_nodes << Node.new(init_state, 0, init_state)

    # Value to avoid evaluating useless nodes
    @min_changes = 1.0/0 # Infinity
    
    @best_move = ''
  end

  def run
    while @pending_nodes.length != 0
      node = @pending_nodes.shift # Grab a node from the list of pending
      next if node.no_of_changes >= @min_changes # Skip if useless

      # Node is in final state
      if node.state == @end_state
        #puts 'Possible solution: ' << node.output
        length = node.output.scan(/->/).length
        if length < @min_changes
          @min_changes = length
          @best_move = node.output
        end
      end
      
      # Create all the posibilities from this node
      @safe_states.each do |st|
        if node.state.mutable_to?(st) && !node.output.include?(st)
          @pending_nodes << Node.new(st, node.no_of_changes + 1, node.output + '->' << st)
        end
      end
    end

    #puts '-----------------'
    puts @best_move
  end
end


# MAIN

init_state = gets.chomp
end_state = gets.chomp

# Store safe states
safe_states = []
while !STDIN.eof?
  safe_states << gets.chomp
end

sc = SkinChanger.new init_state, end_state, safe_states
sc.run

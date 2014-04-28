#! /usr/bin/env ruby

=begin
EXPLANATION
-----------
The data structure used to store the map as it is being drawn is an array of arrays.
Each horizontal line of the output will be stored as an array of chars. This way it is
possible to use coordinates while drawing.

@map = [
[["/", "#", "-", "-", "-", "-", "\\"],  #output line 1
 ["|", " ", " ", " ", " ", " ", "|"],   #output line 2
 ["|", " ", " ", " ", " ", " ", "|"],   #output line 3
 ["|", " ", " ", " ", " ", " ", "|"],   #output line 4
 ["|", " ", " ", " ", " ", " ", "|"],   #output line 5
 ["|", " ", " ", " ", " ", " ", "|"],   #output line 6
 ["\\", "-", "-", "-", "-", "-", "/"]]  #output line 7
] 

This data structure starts empty, and will be resized during execution as needed.
=end

class CircuitDrawer
  
  def initialize()
    @mov_dir = :right
    @coord_x = @coord_y = 0
    @max_x = @max_y = 0
    @map = [[]] # Array of arrays
  end

  # Makes the correct turn given the curve symbol and the current
  # movement direction
  def turn(curve_symbol)
    case curve_symbol
    when "\\"
      case @mov_dir
      when :up
        @mov_dir = :left
      when :right
        @mov_dir = :down
      when :down
        @mov_dir = :right
      when :left
        @mov_dir = :up
      end

    when "\/"
      case @mov_dir
      when :up
        @mov_dir = :right
      when :right
        @mov_dir = :up
      when :down
        @mov_dir = :left
      when :left
        @mov_dir = :down  
      end

    else
      puts 'ERROR: Wrong curve symbol used'
      exit -1
    end
  end

  # Changes the coordinates (coord_x & coord_y) based on the current
  # movement direction and increments the size of the arrays used to
  # store the data when moving out of bounds
  def move()
    case @mov_dir
    when :right
      if @coord_x == @max_x
        @max_x += 1 # Moving out of bounds. No need to do anything because Ruby rocks! :P
      end
      @coord_x += 1
    
    when :up
      if @coord_y == 0
        @map.unshift [] # Moving out of bounds. Adds a new line to the top
        @max_y += 1
      else
        @coord_y -= 1
      end
    
    when :down
      if @coord_y == @max_y
        @max_y += 1
        @map.push [] # Moving out of bounds. Adds a new line to the bottom
      end
      @coord_y += 1
    
    when :left
      if @coord_x == 0
        @map.each do |a| # Moving out of bounds. Adds a new line to the left
          a.unshift ' ' 
        end
        @max_x += 1
      else
        @coord_x -= 1
      end
    end
  end

  def run
    input = gets.chomp

    i = input =~ /#/
    if i != 0
      input = input[i..-1] + input[0...i] # Reorder input so first char is start/finishing line
    end

    input.split('').each do |c|
      # Draw
      if @mov_dir == :up || @mov_dir == :down
        char = c == '-' ? '|' : c
      else
        char = c
      end
      @map[@coord_y][@coord_x] = char
      
      # Turn
      if c =~/(\\|\/)/
        turn(c)
      end 
      
      # Move
      move()
    end
  end

  def draw_map
    @map.each do |y| # Expand all lines to max length needed
      if y[@max_x] == nil
        y[@max_x] = ' '
      end
    end

    @map.map! do |y|
      y.map! do |v|
        v == nil ? ' ' : v # Change nil values in the arrays into spaces
      end
      y.join # Convert each array into a line
    end

    puts @map # Glue together all the lines
  end

end

cd = CircuitDrawer.new
cd.run
cd.draw_map

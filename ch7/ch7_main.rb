#! /usr/bin/env ruby
require 'json'

# Read phone call log and build a data structure of contacts
call_log = File.open 'phone_call.log', 'r'
calls = call_log.readlines

contacts_hash = Hash.new{ |hash, key| hash[key] = Hash.new } # key = caller number, data = hash {key = called, data = contact_time}

calls.each_with_index do |call_data, index|
  tel_numbers = call_data.chomp.split ' '
  tel_numbers.map! { |n| n.to_i }

  tel_numbers.each_with_index do |tel, j|
    contacts_hash[tel][tel_numbers[(j + 1) % 2]] = index unless contacts_hash[tel][tel_numbers[(j + 1) % 2]]
  end
end

# Get terrorist phone numbers from stdin
terr1 = gets.chomp.to_i
terr2 = gets.chomp.to_i

contact_time = -1 # Time of contact between the terrorists

pending_tels = [] # Ordered list of telephones waiting for being evaluated on the search for contact
pending_tels[0] = [terr1, -1]
index_first_pending = 0
index_last_pending = 0

evaluated_tels = [] # To avoid repeating scan of the same tel

while index_first_pending <= index_last_pending

  while not (tel = pending_tels[index_first_pending]) && index_first_pending <= index_last_pending # Skip empty spaces in the array
    index_first_pending += 1
  end
  pending_tels[index_first_pending] = nil
  
  if tel[0] == terr2
    contact_time = tel[1] unless tel[1] < contact_time
    puts 'Connected at ' << contact_time.to_s
    exit 0
  end

  contacts_hash[tel[0]].each_pair do |key, value|
    pending_tels[value] = [key, value] unless evaluated_tels.include? key
  
    # Update indexes
    index_first_pending = value if value < index_first_pending
    index_last_pending = value if value > index_last_pending
  end

  evaluated_tels << tel[0]
end

puts 'Not connected'

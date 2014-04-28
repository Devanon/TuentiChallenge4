#! /usr/bin/env ruby

require 'sqlite3'

STUDENTS_FILE = 'students.txt'
DB_NAME = 'students.db'

def create_db db_name

  db = SQLite3::Database.new db_name
  db.execute 'CREATE TABLE Students(
    id      INT PRIMARY KEY,
    name    TEXT,
    gender  TEXT,
    age     INT,
    study   TEXT,
    year    INT)'

  students_list = File.open STUDENTS_FILE, 'r'
  students_list.each_line do |line|
    student = line.split(',')
    student[2] = student[2].to_i
    student[4] = student[4].to_i

    db.execute 'INSERT INTO Students(name, gender, age, study, year) VALUES (?, ?, ?, ?, ?)',
      student[0], student[1], student[2], student[3], student[4]
  end
  
  students_list.close
  db.close

end


## MAIN

if not File.exists? DB_NAME
  create_db DB_NAME
end

db = SQLite3::Database.open DB_NAME

tests_cases_no = gets.chomp.to_i

tests_cases_no.times do |i|
  anon_student_info = gets.chomp.split ','

  possible_students = db.execute 'SELECT name FROM Students WHERE gender=? AND age=? AND study=? AND year=?',
    anon_student_info[0], anon_student_info[1], anon_student_info[2], anon_student_info[3]

  print "Case ##{i+1}: "
  if possible_students.length == 0
    puts 'NONE'
  else
    puts possible_students.sort.join','
  end
end

require 'json'
require 'sqlite3'

quizArray = []

begin

  db = SQLite3::Database.open "quizzes.sqlite"
  stm = db.prepare "SELECT * FROM quiz1"
  rs = stm.execute
  rs.each do |question|
    quizArray.push(question)
  end

rescue SQLite3::Exception => e
  puts "Error occured"
  puts e

ensure
  stm.close if stm
  db.close if db
end

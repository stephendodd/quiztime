require 'sinatra'
require 'json'
require 'sqlite3'

questionArray = []
userArray = []

begin

  db = SQLite3::Database.open "quizzes.sqlite"
  stm = db.prepare "SELECT * FROM quiz1"

  rs = stm.execute
  rs.each do |question|
    questionArray.push(question)
  end

  users = db.prepare "SELECT * FROM users WHERE quiz == 1"
  usersResult = users.execute
  usersResult.each do |user|
    jsonUser = {"alias": user[1], "score": user[2]}
    userArray.push(jsonUser);
  end

rescue SQLite3::Exception => e
  puts "Error occured"
  puts e

ensure
  stm.close if stm
  users.close if users
  db.close if db
end

get '/' do
  File.new('public/index.html').read
end

get '/quiz1' do

  content_type :json
  {quiz: questionArray}.to_json

end

get '/1/scores' do

  userArray.sort_by! do |e|
    e[:score]
  end
  content_type :json
  {scores: userArray}.to_json

end

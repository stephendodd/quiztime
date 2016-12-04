require 'sinatra'
require 'json'
require 'sqlite3'

userArray = []

begin

  db = SQLite3::Database.open "quizzes.sqlite"

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
  users.close if users
  db.close if db
end

get '/' do
  File.new('public/index.html').read
end

get '/1/scores' do

  userArray.sort_by! do |e|
    e[:score]
  end
  content_type :json
  {scores: userArray}.to_json

end

get '/quiz/:quizNo' do
  questionArray = []
  quizString = "quiz#{params[:quizNo]}"

  begin

    db2 = SQLite3::Database.open "quizzes.sqlite"
    stm = db2.prepare "SELECT * FROM #{quizString}"

    rs = stm.execute
    rs.each do |question|
      questionArray.push(question)
    end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    stm.close if stm
    db2.close if db2
  end

  content_type :json
  {quiz: questionArray}.to_json

end

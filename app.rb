require 'sinatra'
require 'json'
require 'sqlite3'

get '/' do
  File.new('public/index.html').read
end

get '/alias/:alias/:currentquiz/:score' do
  puts params[:alias]
  db = SQLite3::Database.open "quizzes.sqlite"

  #puts db.execute( "SELECT 1 FROM users WHERE alias = #{params[:alias]}")

  db.execute( "INSERT INTO users ( quiz, alias, score ) VALUES ( ?, ?, ? )", [params[:currentquiz], params[:alias], params[:score]])

end

get '/scores/:quizNo' do

  userArray = []

  begin

    db = SQLite3::Database.open "quizzes.sqlite"

    users = db.prepare "SELECT * FROM users WHERE quiz == #{params[:quizNo]}"
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

get '/noquiz' do
  noQuizzes = 0
  begin
    db3 = SQLite3::Database.open "quizzes.sqlite"
    stm3 = db3.prepare "SELECT count(*) FROM sqlite_master WHERE type = 'table'"
    rs3 = stm3.execute
    rs3.each do |res|
      noQuizzes = res[0]-1
    end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    stm3.close if stm3
    db3.close if db3
  end
  content_type :json
  {noQuiz: noQuizzes}.to_json
end

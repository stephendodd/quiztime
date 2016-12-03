require 'sinatra'
require 'json'
require 'sqlite3'

questionArray = []

begin

  db = SQLite3::Database.open "quizzes.sqlite"
  stm = db.prepare "SELECT * FROM quiz1"
  rs = stm.execute
  rs.each do |question|
    questionArray.push(question)
  end

rescue SQLite3::Exception => e
  puts "Error occured"
  puts e

ensure
  stm.close if stm
  db.close if db
end

get '/' do
  File.new('public/index.html').read
end

get '/quiz1' do

  content_type :json
  {quiz: questionArray}.to_json

end

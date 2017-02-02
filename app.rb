require 'sinatra'
require 'json'
require 'sqlite3'

get '/' do
  File.new('public/index.html').read
end

get '/quizzes' do

  quizzes = []

  begin
    db3 = SQLite3::Database.open "quizzes.sqlite"
    stm3 = db3.prepare "SELECT * FROM quizzes"
    rs3 = stm3.execute
    rs3.each_hash do |res|
      quizzes.push(
        name: res["name"],
        id: "#{res['id']}"
      )
    end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    stm3.close if stm3
    db3.close if db3
  end
  content_type :json
  {quizzes: quizzes}.to_json

end

get '/alias/:alias/:currentquiz/:score' do
  puts params[:alias]
  db = SQLite3::Database.open "quizzes.sqlite"
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

get '/quiznew/:quizNo' do
    File.new('public/quiz.html').read
end

get '/quiz/:quizNo' do
  questionArray = []
  newQuestionArray = []
  optionArray = []
  questionJson = {}
  quizString = "quiz#{params[:quizNo]}"

  begin

    quizDB = SQLite3::Database.open "quizzes.sqlite"
    quizDB.results_as_hash = true
    questionsQuery = quizDB.prepare "SELECT questions.text, answers.answer, questions.answer_id FROM questions, answers where answers.question_id = questions.id AND questions.quiz_id =#{params[:quizNo]}"
    questionsQueryResult = questionsQuery.execute
    questionsQueryResult.each_with_index do |question, index|

      if index%4 == 0 && index != 0
        newQuestionArray.push(questionJson)
        questionJson = {}
      end

      if questionJson[:question] != question["text"]
        questionJson = {}
        questionJson[:question] = question["text"]
        questionJson[:answer] = question["answer_id"]
      end
      questionJson["option#{index%4+1}"] = question["answer"]

    end
    newQuestionArray.push(questionJson)

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    questionsQuery.close if questionsQuery
    quizDB.close if quizDB

  end

  content_type :json
  p "questionArray#{questionArray}"
  {quiz: newQuestionArray}.to_json

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

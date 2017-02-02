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
    questionsQuery = quizDB.prepare "SELECT questions.text, answers.text, questions.answer_id FROM questions, answers where answers.question_id = questions.id AND questions.quiz_id =#{params[:quizNo]}"
    questionsQueryResult = questionsQuery.execute
    p questionsQueryResult
    questionsQueryResult.each_with_index do |question, index|

      if index%4 == 0 && index != 0
        p "it happened"
        newQuestionArray.push(questionJson)
        questionJson = {}
      end

      if questionJson[:question] != question[0]
        questionJson = {}
        questionJson[:question] = question[0]
        questionJson[:answer] = question[2]
      end
      questionJson["option#{index%4+1}"] = question[1]

    end
    newQuestionArray.push(questionJson)
    p "newQuestionArray#{newQuestionArray}"
      #stm = quizDB.prepare "SELECT * FROM #{quizString}"

      #rs = stm.execute
      #rs.each do |question|
      #  questionArray.push(question)
      #end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
  #  stm.close if stm
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

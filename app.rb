require 'sinatra'
require 'json'
require 'sqlite3'

get '/' do
  File.new('public/index.html').read
end

get '/quizzes' do

  quizzes = []

  begin
    quizDB = SQLite3::Database.open "quizzes.sqlite"
    quizzesQuery = quizDB.prepare "SELECT * FROM quizzes"
    quizzesQueryResult = quizzesQuery.execute
    quizzesQueryResult.each_hash do |quiz|
      quizzes.push(
        name: quiz["name"],
        id: "#{quiz['id']}"
      )
    end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    quizzesQuery.close if quizzesQuery
    quizDB.close if quizDB
  end
  content_type :json
  {quizzes: quizzes}.to_json

end

get '/alias/:alias/:currentquiz/:score' do
  quizDB = SQLite3::Database.open "quizzes.sqlite"
  quizDB.execute( "INSERT INTO users ( quiz, alias, score ) VALUES ( ?, ?, ? )", [params[:currentquiz], params[:alias], params[:score]])
end

get '/scores/:quizNo' do

  userArray = []

  begin

    quizDB = SQLite3::Database.open "quizzes.sqlite"

    users = quizDB.prepare "SELECT * FROM users WHERE quiz == #{params[:quizNo]}"
    usersResult = users.execute
    usersResult.each_hash do |user|
      jsonUser = {"alias": user["alias"], "score": user["score"]}
      userArray.push(jsonUser);
    end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    users.close if users
    quizDB.close if quizDB
  end

  userArray.sort_by! do |e|
    e[:score]
  end
  content_type :json
  {scores: userArray}.to_json

end

get '/quiz/:quizNo' do
    File.new('public/quiz.html').read
end

get '/quizjson/:quizNo' do
  questionArray = []
  newQuestionArray = []
  optionArray = []
  questionJson = {}
  quizString = "quiz#{params[:quizNo]}"

  begin

    quizDB = SQLite3::Database.open "quizzes.sqlite"
    quizDB.results_as_hash = true
    questionsQuery = quizDB.prepare "SELECT questions.text, answers.answer, questions.answer_id, answers.question_id FROM questions, answers where answers.question_id = questions.id AND questions.quiz_id =#{params[:quizNo]}"
    questionsQueryResult = questionsQuery.execute
    previousQuestionID = 1
    questionIndex = 0
    questionsQueryResult.each_with_index do |question, index|
    #questionIndex = questionIndex || 0

      #Check if question has changed
      if (question["question_id"] != previousQuestionID && index!=0)

        newQuestionArray.push(questionJson)
        questionIndex = 0
        questionJson = {}

      end

      questionJson[:question] = questionJson[:question] || question["text"]
      questionJson[:answer] = questionJson[:answer] || question["answer_id"]

      questionJson["option#{questionIndex+1}"] = question["answer"]

      previousQuestionID = question["question_id"]
      questionIndex+=1

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
  {quiz: newQuestionArray}.to_json

end

  get '/noquiz' do
    noQuizzes = 0
    begin
      quizDB = SQLite3::Database.open "quizzes.sqlite"
      noQuizQuery = quizDB.prepare "SELECT COUNT(*) FROM quizzes"
      noQuizQueryResult = noQuizQuery.execute
      noQuizQueryResult.each do |res|
        noQuizzes = res[0]
      end

  rescue SQLite3::Exception => e
    puts "Error occured"
    puts e

  ensure
    noQuizQuery.close if noQuizQuery
    quizDB.close if quizDB
  end
  content_type :json
  {noQuiz: noQuizzes}.to_json
end

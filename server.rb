require "rubygems"
require "sinatra"
require "sinatra/reloader" if development?
require "dm-core"
require "dm-migrations"
require "dm-postgres-adapter"

def active_page?(path='')
  request.path_info == '/' + path
end

# DataMapper::Logger.new($stdout, :debug) 
# DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}users.db")
# DataMapper.setup(:students, "sqlite3:///#{Dir.pwd}students.db")
# DataMapper.setup(:comments, "sqlite3:///#{Dir.pwd}comments.db")

#postgres://localhost/postgresql-animate-62078
DataMapper::Logger.new($stdout, :debug) 

DataMapper.setup(:default,ENV['postgres://tqemjvdlvmyfrv:0dc0fee410187ba18fb1ffa0f7254ed89c66d3ff4dbe9958835a5781b0d99920@ec2-54-243-107-66.compute-1.amazonaws.com:5432/dmavmb07cui1v'] || 'postgres://localhost/postgresql-animate-62078')
#DataMapper.setup(:default, "postgres://localhost/onurb")
DataMapper.setup(:students, "postgres://localhost/students")
DataMapper.setup(:comments, "postgres://localhost/comments")


#DB table definitions
class Student
	include DataMapper::Resource 
	property :id,   Serial  
	property :firstname, String, :required => true
	property :surname, String, :required => true
end

class Comment
	include DataMapper::Resource 
	property :id,   Serial  
	property :ownername, String, :required => true
	property :content, String, :required => true
	property :created_at, DateTime
end
	DataMapper.finalize.auto_upgrade!

get '/hello' do 
	"<h1>hello, this is my first sinatra web application<h1>"
end
#routes for HTML pages
get "/" do
	@title = 'Home'
	erb :home
end

#routes for Students
get '/students' do
	@title = 'Students'
	@students = Student.all
	erb :students
end

get '/student/:id' do |id|
	@student = Student.get!(id)

	erb :student_details
end

get '/students/new' do
	@title = 'Students'
	erb :add_student
end

post '/student/add' do
  	student = Student.new(firstname:params["name"], surname:params["surname"])

  	if student.save
		redirect '/students'
	else
		redirect '/students/new'
	end
end

put '/student/:id' do |id|
	student = Student.get!(id)
	changedStudent = student.update!(firstname:params["name"], surname:params["surname"])
	  
	if changedStudent
	   redirect "/students"
	else
	   redirect "/student/#{id}"
	end
end

delete '/student/:id' do |id|
	student = Student.get!(id)
	student.destroy!
	redirect "/students"
end

#routes for Comments
get '/comments' do
	@title = 'Comments'
	@comments = Comment.all

	p @comments 
	erb :comments
end

get '/comment/:id' do |id|
	@comment = Comment.get!(id)

	erb :comment_details
	
end

post '/comment/add' do
	comment = Comment.new(ownername:params["ownername"], content:params["content"],created_at:Time.now)

	if comment.save
		redirect '/comments'
	end
	
end

delete '/comment/:id' do |id|
	comment = Comment.get!(id)
	comment.destroy!
	redirect "/comments"
	
end

#route for Video
get '/video' do
	erb :video
end

#routes for Login
get '/login' do
	erb :home, :layout => :login_layout
end

post '/login' do
	username = params[:username]
	password = params[:password] 
end

get '/*' do
   "<h1>404, Wrong Request</h1>" 
end




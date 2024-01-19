require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'
require 'yaml'
require 'bcrypt'

configure do
  enable :sessions
  set :session_secret, "3619d4360dc051e2b3e789b4e874854348810d8eca8efa4e8aa2656296948e6c"
end

SUPPORTED_FILETYPES = [".md", ".txt"]

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  contents = File.read(path)
  case File.extname(path)
  when ".md"
    erb render_markdown(contents)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    contents
  end
end

def signed_in?
  session.key?(:username)
end

def require_signed_in_user
  unless signed_in?
    session[:message] = "You must be signed in to do that."
    redirect "/"
  end
end

def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
                       File.expand_path("../test/users.yml", __FILE__)
                     else
                       File.expand_path("../users.yml", __FILE__)
                     end
  YAML.load_file(credentials_path)
end

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

def validate_new(filename)
  if filename.strip.empty?
    session[:message] = "A name is required."
    status 422
    erb :new
  elsif !SUPPORTED_FILETYPES.include?(File.extname(filename))
    session[:message] = "That file extension type is not currently supported."
    status 422
    erb :new
  else
    create_new(filename, "")
  end
end

def create_new(filename, contents)
  file_path = File.join(data_path, filename)
  File.write(file_path, contents)

  session[:message] = "#{filename} has been created."
  redirect "/"
end

get "/" do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map { |filepath| File.basename(filepath) }
  erb :index
end

get "/new" do
  require_signed_in_user

  erb :new
end

get "/users/signin" do
  erb :signin
end

post "/users/signin" do
  username = params[:username]

  if valid_credentials?(username, params[:password])
    session[:username] = username
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end

post "/users/signout" do
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/"
end

get "/:filename" do
  file_name = params[:filename]
  file_path = File.join(data_path, file_name)

  if File.exist?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{file_name} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  require_signed_in_user

  @file_name = params[:filename]
  file_path = File.join(data_path, @file_name)
  @contents = File.read(file_path)

  erb :edit
end

post "/create" do
  require_signed_in_user

  filename = params[:filename].to_s
  validate_new(filename)
end

post "/duplicate" do
  require_signed_in_user

  file_name = params[:filename].to_s
  new_file_name = File.basename(file_name, ".*") + "-1" + File.extname(file_name)

  file_path = File.join(data_path, file_name)
  contents = File.read(file_path)

  create_new(new_file_name, contents)
end

post "/:filename" do
  require_signed_in_user

  file_name = params[:filename]
  file_path = File.join(data_path, file_name)

  File.write(file_path, params[:content])

  session[:message] = "#{file_name} has been updated."
  redirect "/"
end

post "/:filename/delete" do
  require_signed_in_user

  file_name = params[:filename]
  file_path = File.join(data_path, file_name)

  File.delete(file_path)
  session[:message] = "#{file_name} has been deleted."
  redirect "/"
end

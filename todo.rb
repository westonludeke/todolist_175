=begin

// Todo list //

0. Confirm site works fully
1. Push to Heroku
2. Maybe - Check on Rack version
3. Maybe - Check on Rack-protection version
4. Maybe - Fix jquery issues

=end

require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

# enable ability to have sessions
configure do 
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

# when new session started, create empty lists array
before do 
  session[:lists] ||= []
end

helpers do 
  # setup instance variables for session's master list and individual todo lists
  def setup_instance_variables(list_id=nil, todo_id=nil)
    @list_id = list_id.to_i unless nil
    @todo_id = todo_id.to_i unless nil
    @master_list = session[:lists]
    @requested_list = session[:lists][@list_id] unless @list_id == nil
  end

  # error handling if new list name is invalid
  def error_for_list_name(name)
    if session[:lists].any? { |list| list[:name] == name }
      "The list name must be unique"
    elsif (1..100).cover?(name.size) == false
      "The list name must be between 1 and 100 characters"
    end
  end

  # error handling if new todo name is invalid
  def error_for_todo(name)
    if (1..100).cover?(name.size) == false
      "The todo's name must be between 1 and 100 characters"
    end
  end

  def size_of_todo_list(list)
    list[:todos].size
  end

  def number_of_incomplete_todos(list)
    i = 0
    list[:todos].each do |hsh|
      hsh.each { |key, value| i += 1 if key == :completed && value == false }
    end
    i 
  end

  def list_completed?(list)
    number_of_incomplete_todos(list) == 0 && size_of_todo_list(list) > 0
  end

  def list_class(list)
    "complete" if list_completed?(list)
  end

  def sort_lists(master_list, &block)
    complete_lists, incomplete_lists = master_list.partition { |list| list_completed?(list) }

    incomplete_lists.each(&block)
    complete_lists.each(&block)
  end

  def sort_todos(todos, &block)
    complete_todos, incomplete_todos = todos.partition { |todo| todo[:completed] }

    incomplete_todos.each(&block)
    complete_todos.each(&block)
  end

  def next_todo_id(todos)
    max = todos.map { |todo| todo[:id] }.max || 0
    max + 1
  end
end

get "/" do 
  redirect "/lists"
end

# redirecting to correct URL
get "/lists/" do 
  redirect "/lists"
end

# Show master list of all todo lists
get "/lists" do
  setup_instance_variables
  erb :lists, layout: :layout
end

# Render new list form
get "/lists/new" do 
  erb :new_list, layout: :layout
end

# Create a new todo list
post "/lists" do
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] == nil ? @list_id = 0 : @list_id = session[:lists].size 
    session[:lists] << { list_id: @list_id, name: list_name, todos: [] } 
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

# View a specific todo list
get "/lists/:list_id" do
  setup_instance_variables(params['list_id'])
  
  if @list_id <= @master_list.length && @list_id >= 0
    erb :single_todo_list, layout: :layout
  else 
    session[:error] = "The specified todo list was not found"
    redirect "/lists"  
  end
end

# Edit an existing todo list
get "/lists/:list_id/edit" do
  setup_instance_variables(params['list_id'])

  @list = session[:lists][@list_id]
  erb :edit_todo_list, layout: :layout
end

# Update existing todo list's name
post "/lists/:list_id" do 
  setup_instance_variables(params['list_id'])
  list_name = params[:list_name].strip
  
  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_todo_list, layout: :layout
  else
    @requested_list[:name] = list_name
    session[:success] = "The list name has been updated."
    redirect "/lists/#{@list_id}"
  end
end

# Delete an individual todo list
post "/lists/:list_id/delete" do 
  setup_instance_variables(params['list_id'])

  @master_list.delete_at(@list_id)

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/lists"
  else
    session[:success] = "The list has been deleted."
    redirect "/lists"
  end
end

# Add a new item to a todo list
post "/lists/:list_id/todos" do
  setup_instance_variables(params['list_id'])
  text = params[:todo].strip

  error = error_for_todo(text)
  if error 
    session[:error] = error 
    erb :single_todo_list, layout: :layout
  else
    id = next_todo_id(@requested_list[:todos])
    @requested_list[:todos] << { id: id, name: text, completed: false }
    session[:success] = "The todo has been successfully added."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a single todo item
post "/lists/:list_id/:todo_id/delete_todo" do 
  setup_instance_variables(params['list_id'], params['todo_id'])

  @requested_list[:todos].reject! { |todo| todo[:id] == @todo_id }

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    status 204
  else
    session[:success] = "The todo has been deleted."
    redirect "/lists/#{@list_id}"
  end
end

# Mark a single todo as complete/incomplete
post "/lists/:list_id/:todo_id/toggle" do 
  setup_instance_variables(params['list_id'], params['todo_id'])

  is_completed = params[:completed] == 'true'

  todo = @requested_list[:todos].find { |todo| todo[:id] == @todo_id }
  todo[:completed] = is_completed

  session[:success] = "The todo status has changed."
  redirect "/lists/#{@list_id}"
end

# Mark all todos as complete
post "/lists/:list_id/toggle_all" do 
  setup_instance_variables(params['list_id'])

  @requested_list[:todos].each { |todo| todo[:completed] = true }

  session[:success] = "All todos are now completed."
  redirect "/lists/#{@list_id}"
end

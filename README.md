# Todo List - RB175

### Project Overview:

Created a todo list app in Sinatra, Ruby, HTML, and CSS as part of Launch School's RB175 course. 

[The project is live on Heroku here](https://vast-gorge-88966.herokuapp.com). 

Notes: The CSS files and images were developed by Launch School. All of the Ruby, Sinatra, HTML, and Javscript code is my own written as part of the course. Students are given instructions and implement the app on their own based on the parameters in the instructions.

Bug: If a todo list is deleted and several other todo lists remain, it causes problems due to how the different lists are shown on the site. I need to go back and fix this in the future.

### Goals of the Project:

* Learn how state is data that persists over time

* Learn about how *sessions* provide a way to store data that will persist between subsequent HTTP requests. This data is associated with a specific user by storing a cookie in their browser. In Sinatra, the session data itself is also stored in this cookie, but this is configurable and not always the case with other web frameworks.

* Data that is submitted to the server often needs to be validated to ensure it meets the requirements of the application. In this lesson we built server-side validation as we performed the validation logic on the server.

* Messages that need to be displayed to the user on their next request and then deleted can be stored in the session. This kind of message is often referred to as a flash message.

* Content from within a view template can be stored under a name and retrieved later using content_for and yield_content.

* GET requests should only request data. Any request that modifies data should be over POST or another non-GET method.

* Web browsers don't support request methods other than GET or POST in HTML forms, so there are times when a developer has to use POST even when another method would be more appropriate.

* View helpers provide a way to extract code that determines what HTML markup is generated for a view.

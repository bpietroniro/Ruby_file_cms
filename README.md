# Overview
This is a simple file-based content management system written in Ruby. My aim with the project was to practice translating high-level requirements into implementation steps. Below are some notes I took to track my progress and stay organized.

## Editing Document Content

### Requirements
- When a user views the index page, they should see an “Edit” link next to each document name.
- When a user clicks an edit link, they should be taken to an edit page for the appropriate document.
- When a user views the edit page for a document, that document's content should appear within a textarea.
- When a user edits the document's content and clicks a “Save Changes” button, they are redirected to the index page and are shown a message.

### Implementation
1) Add a link in `index.erb` next to each document name
    - the link should make a `GET` request to `'/:filename/edit/'`
2) Make a new view template called edit.erb
    - make a `textarea` within a form
    - display the document's current text in that area
    - add a "Save Changes" button
3) The "Save Changes" button should make a `POST` request to `'/:filename/edit/'`
    - this should write changes to the appropriate file in `cms.rb`
    - and then show a `session[:success]`
    - and then redirect to `"/"`


## Deleting Documents

### Requirements
- When a user views the index page, they should see a "delete" button next to each document.
- When a user clicks a "delete" button, the application should delete the appropriate document and display a message: "$FILENAME has been deleted".

### Implementation
1) Add a link in `index.erb` next to the Edit button
    - the link should make a `POST` request to `'/:filename/delete'`
2) Make a new route for `POST '/:filename/delete'`
    - in this route, add some functionality that deletes the file
    - show a message
    - reroute to homepage


## Signing In and Out

### Requirements
- When a signed-out user views the index page of the site, they should see a "Sign In" button.
- When a user clicks the "Sign In" button, they should be taken to a new page with a sign in form. The form should contain a text input labeled "Username" and a password input labeled "Password". The form should also contain a submit button labeled "Sign In".
- When a user enters the username "admin" and password "secret" into the sign in form and clicks the "Sign In" button, they should be signed in and redirected to the index page. A message should display that says "Welcome!".
- When a user enters any other username and password into the sign in form and clicks the "Sign In" button, the sign in form should be redisplayed and an error message "Invalid credentials" should be shown. The username they entered into the form should appear in the username input.
- When a signed-in user views the index page, they should see a message at the bottom of the page that says "Signed in as $USERNAME.", following by a button labeled "Sign Out".
- When a signed-in user clicks this "Sign Out" button, they should be signed out of the application and redirected to the index page of the site. They should see a message that says "You have been signed out.".

### Implementation
1) Add a "Sign In/Out" button to `index.erb`
2) Create a new view template for the sign-in page
    - add sign-in form with two text inputs labeled "Username" and "Password"
    - add a submit button labeled "Sign In"
3) Add a route to `cms.rb` to handle the sign-in page
    - redirect to index page upon successful authentication
    - upon invalid authentication:
        - display a message
        - redisplay the sign-in form
        - use the previously entered username as default text for username input field
4) (The full truth is that I veered off the golden path of note taking here and went rogue... oops)


## Restricting Actions to Sign-In Users

### Requirements
- When a signed-out user attempts to perform the following actions, they should be redirected back to the index and shown a message that says "You must be signed in to do that.":
    - Visit the edit page for a document
    - Submit changes to a document
    - Visit the new document page
    - Submit the new document form
    - Delete a document

### Implementation
1) Create a method for the redirecting and message displaying 
2) Create a method for determining whether or not the user is signed in
3) In each of the situations described above, call (2) and then as necessary (1)
4) Write tests


## Storing User Accounts in an External File

### Requirements
An administrator should be able to modify the list of users who may sign into the application by editing a configuration file in their text editor.

### Implementation
1) Create a YAML file to store user credentials
2) Load the file to validate user input when signing in

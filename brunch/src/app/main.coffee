window.app = {}
app.controllers = {}
app.models = {}
app.collections = {}
app.views = {}

MainController = require('controllers/main_controller').MainController
User = require('models/user').User
UserMenu = require('views/shared/user_menu').UserMenu
LoginView = require('views/login/show').LoginView
HomeView = require('views/home/index').HomeView

# app bootstrapping on document ready
$(document).ready ->

  ### could be used to switch console output ###
  app.debug_mode = true
  app.debug = () ->
    console.log "DEBUG:", arguments if app.debug_mode
  
  app.initialize = ->
  
    # current user
    app.current_user = new User()
    
    # initialize the user menu
    #user_menu = new UserMenu()
    login = new LoginView()
    
    ### the password hack ###
    ###
    Normally a webserver would return user information for a current session. But there is no such thing in buddycloud.
    To achieve an auto-login we do a little trick here. Once a user has signed in, his browser asks him to store 
    the password for him. If the user accepts that, the login form will get filled automatically the next time he signs in.
    So when something is typed into the form on document ready we know that it must be the stored password and can just submit the form.
    ###
    el = $('#home_login_pwd')
    pw = el.val()
    unless pw.length > 0
      # no prefilled password so we show the login
      login.show()
      
      # the home view sould display some additional info in the future
      #app.views.home = new HomeView()
    else
      # prefilled password detected, sign in the user automatically
      $('#login_form').trigger "submit"
  
  app.controllers.main = new MainController()
  app.initialize()
  Backbone.history.start()
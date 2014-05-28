#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'sidekiq/web'

Diaspora::Application.routes.draw do
  if Rails.env.production?
    mount RailsAdmin::Engine => '/admin_panel', :as => 'rails_admin'
  end

  constraints ->(req) { req.env["warden"].authenticate?(scope: :user) &&
                        req.env['warden'].user.admin? } do
    mount Sidekiq::Web => '/sidekiq', :as => 'sidekiq'
  end

  get "/atom.xml" => redirect('http://blog.diasporafoundation.org/feed/atom') #too many stupid redirects :()

  get 'oembed' => 'posts#oembed', :as => 'oembed'
  # Posting and Reading
  resources :reshares

  resources :status_messages, :only => [:new, :create]

  resources :posts do
    member do
      get :next
      get :previous
      get :interactions
    end

    resources :likes, :only => [:create, :destroy, :index ]
    resources :participations, :only => [:create, :destroy, :index]
    resources :comments, :only => [:new, :create, :destroy, :index]
  end

  get 'p/:id' => 'posts#show', :as => 'short_post'
  get 'posts/:id/iframe' => 'posts#iframe', :as => 'iframe'

  # roll up likes into a nested resource above
  resources :comments, :only => [:create, :destroy] do
    resources :likes, :only => [:create, :destroy, :index]
  end

  resources :comments do
    put :update
  end

  # Streams
  get "participate" => "streams#activity", :as => "activity_stream" # legacy
  get "explore" => "streams#multi", :as => "stream"                 # legacy

  get "activity" => "streams#activity", :as => "activity_stream"
  get "stream" => "streams#multi", :as => "stream"
  get "public" => "streams#public", :as => "public_stream"
  get "followed_tags" => "streams#followed_tags", :as => "followed_tags_stream"
  get "mentions" => "streams#mentioned", :as => "mentioned_stream"
  get "liked" => "streams#liked", :as => "liked_stream"
  get "commented" => "streams#commented", :as => "commented_stream"
  get "aspects" => "streams#aspects", :as => "aspects_stream"

  get  'aspects/teacher/:id' => 'aspects#teacher'
  get  'aspects/add' => 'aspects#add'
  post 'aspects/join' => 'aspects#join'
  
  resources :aspects do
    put :toggle_contact_visibility    
  end
  
  get 'bookmarklet' => 'status_messages#bookmarklet'

  resources :photos, :except => [:index, :show] do
    put :make_profile_photo
  end

  get 'moodle' => "moodle#assignments"   
  
  resources :courses

  post 'grades/parse' => 'grades#parse'
  resources :grades

  resources :courses

  get 'quiz_assignments/publish' => 'quiz_assignments#publish'
  get 'quiz_assignments/performance' => 'quiz_assignments#performance'
  get 'quiz_assignments/quiz_assessments/:id' => 'quiz_assessments#show'
  resources :quiz_assignments

  resources :quiz_assessments

  resources :o_embed_caches

  resources :contents

  resources :documents

  resources :quizzes

  resources :questions

  get 'questions/clone/:id' => 'questions#clone'

	#Search
	get 'search' => "search#search"

  get 'conversations/teacher_new' => 'conversations#teacher_new'
  resources :conversations do
    resources :messages, :only => [:create, :show]
    delete 'visibility' => 'conversation_visibilities#destroy'    
  end

  get 'notifications/read_all' => 'notifications#read_all'
  resources :notifications, :only => [:index, :update] do
  end

  resources :assignments
  get 'assignment_assessments/publish' => 'assignment_assessments#publish'
  get 'assignment_assessments/performance' => 'assignment_assessments#performance'
  resources :assignment_assessments

  resources :reports

  resources :quizzes
  
  resources :tags, :only => [:index]

  resources "tag_followings", :only => [:create, :destroy, :index]

  get 'tags/:name' => 'tags#show', :as => 'tag'

  resources :apps, :only => [:show]

  #Cubbies info page

  resource :token, :only => :show

  # Users and people

  resource :user, :only => [:edit, :update, :destroy], :shallow => true do
    get :getting_started_completed
    get :export
    get :export_photos
  end

  controller :users do
    get 'public/:username'          => :public,           :as => 'users_public'
    match 'getting_started'         => :getting_started,  :as => 'getting_started'
    #match 'privacy'                 => :privacy_settings, :as => 'privacy_settings'
    get 'getting_started_completed' => :getting_started_completed
    get 'confirm_email/:token'      => :confirm_email,    :as => 'confirm_email'
  end

  # This is a hack to overide a route created by devise.
  # I couldn't find anything in devise to skip that route, see Bug #961
  match 'users/edit' => redirect('/user/edit')

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :password      => "devise/passwords",
                                      :sessions      => "sessions"}

  #legacy routes to support old invite routes
  get 'users/invitation/accept' => 'invitations#edit'
  get 'invitations/email' => 'invitations#email', :as => 'invite_email'
  get 'users/invitations' => 'invitations#new', :as => 'new_user_invitation'
  post 'users/invitations' => 'invitations#create', :as => 'new_user_invitation'

  get 'login' => redirect('/users/sign_in')

  scope 'admins', :controller => :admins do
    match :user_search
    get   :admin_inviter
    get   :weekly_user_stats
    get   :correlations
    get   :stats, :as => 'pod_stats'
    get   "add_invites/:invite_code_id" => 'admins#add_invites', :as => 'add_invites'
    get   :add_teacher
  end

  resource :profile, :only => [:edit, :update]
  resources :profiles, :only => [:show]


  resources :contacts,           :except => [:update, :create] do
    get :sharing, :on => :collection
  end
  resources :aspect_memberships, :only  => [:destroy, :create]
  resources :share_visibilities,  :only => [:update]
  resources :blocks, :only => [:create, :destroy]

  get 'i/:id' => 'invitation_codes#show', :as => 'invite_code'

  get 'people/refresh_search' => "people#refresh_search"
  resources :people, :except => [:edit, :update] do
    resources :status_messages
    resources :photos
    get :contacts
    get "aspect_membership_button" => :aspect_membership_dropdown, :as => "aspect_membership_button"
    get :hovercard

    member do
      get :last_post
    end

    collection do
      post 'by_handle' => :retrieve_remote, :as => 'person_by_handle'
      get :tag_index
    end
  end
  get '/u/:username' => 'people#show', :as => 'user_profile'
  get '/u/:username/profile_photo' => 'users#user_photo'


  # Federation

  #controller :publics do
  #  get 'webfinger'             => :webfinger
  #  get 'hcard/users/:guid'     => :hcard
  #  get '.well-known/host-meta' => :host_meta
  #  post 'receive/users/:guid'  => :receive
  #  post 'receive/public'       => :receive_public
  #  get 'hub'                   => :hub
  #end



  # External

  #resources :services, :only => [:index, :destroy]
  #controller :services do
  #  scope "/auth", :as => "auth" do
  #    match ':provider/callback' => :create
  #    match :failure
  #  end
  #  scope 'services' do
  #    match 'inviter/:provider' => :inviter, :as => 'service_inviter'
  #    match 'finder/:provider'  => :finder,  :as => 'friend_finder'
  #  end
  #end

  scope 'api/v0', :controller => :apis do
    get :me
  end

  namespace :api do
    namespace :v0 do
      get "/users/:username" => 'users#show', :as => 'user'
      get "/tags/:name" => 'tags#show', :as => 'tag'
    end
  end

  get 'community_spotlight' => "contacts#spotlight", :as => 'community_spotlight'
  # Mobile site

  get 'mobile/toggle', :to => 'home#toggle_mobile', :as => 'toggle_mobile'

  # Help
  get 'help' => 'help#getting_help', :as => 'faq_getting_help'
  
  scope path: "/help/faq", :controller => :help, :as => 'faq' do
    get :account_and_data_management
    get :aspects
    get :mentions
    get :miscellaneous
    get :pods
    get :posts_and_posting
    get :private_posts
    get :private_profiles
    get :public_posts
    get :public_profiles
    get :resharing_posts
    get :sharing
    get :tags
  end

  #Protocol Url
  get 'protocol' => redirect("http://wiki.diasporafoundation.org/Federation_Protocol_Overview")

  # Startpage
  root :to => 'home#show'
end

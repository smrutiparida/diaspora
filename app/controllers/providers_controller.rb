#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ProvidersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :html

  def create
  	@consumer_key = 'lmnop-sandbox'
    @consumer_secret = 'lmnop123'

  	# Initialize TP object with OAuth creds and post parameters
	provider = IMS::LTI::ToolProvider.new(@consumer_key, @consumer_secret, params)
	Rails.logger.info(provider.to_json)
	# Verify OAuth signature by passing the request object
	if provider.valid_request?(request)
	  Rails.logger.info("valid request")
	  @user= User.find_by_email(provider.lis_person_contact_email_primary)
	  unless @user.present?
	    ##signs up using lis_person_contact_email_primary,roles, lis_person_name_given, lis_person_name_family, "tool_consumer_instance_guid" => ISB, username => email, password => RANDOM
	    #{"username"=>"temp30", "email"=>"temp30@lmnop.in", "password"=>"temp123", "password_confirmation"=>"temp123", "person"=>{"profile"=>{"role"=>"student", "location"=>"PSBB, Chennai"}}}
	    user_params = signup_params(provider)
	  	@user = User.build(user_params)
	    if @user.save
	      if user_params[:person][:profile][:role] == 'teacher'
	        self.aspects.create(:name => provider.context_title, :folder => "Classroom", :code => create_short_code(provider.context_title))
	      #elsif user_params[:person][:profile][:role] = 'student'
	      end    
	      sign_in_and_redirect(:user, @user)
	      Rails.logger.info("event=registration status=successful user=#{@user.diaspora_handle}")
	    end    
      end
	    ##if teacher
	      ##creates the course
	    ##if student  
	      ##joins the course mapped to the moodle course_id
	        ##if join fails, explain that course is not yet created by the instructore here    
	   #elseif existing user
	      #find user details by email
	      #set devise token     
	else
	  # handle invalid OAuth
	  Rails.logger.info("invalid request")
	  redirect_to :back
	end
  end

  #this is for writing grade
  def update
  	if provider.outcome_service?
	  # ready for grade write-back
	else
	  # normal tool launch without grade write-back
	end

	# post the score to the Moodle, score should be a float >= 0.0 and <= 1.0
	# this returns an OutcomeResponse object
	response = provider.post_replace_result!(score)
	if response.success?
	  # grade write worked
	elsif response.processing?

	elsif response.unsupported?

	else
	  # failed
	end
  end	

  private
  
  def create_short_code(course_name)
  	all_words = course_name.split
  	code = ""
  	all_words.each { |x| code += x.slice(0,1)}
  	code = course_name.slice(0,3) if code.length < 2
  	code += Time.now.year
  	code
  end
   	
  def signup_params(provider)
  	user_params = {}
  	user_params[:username] = provider.lis_person_contact_email_primary
  	user_params[:email] = provider.lis_person_contact_email_primary
  	token = SecureRandom.hex(6)
  	user_params[:password] = token
  	user_params[:password_confirmation] = token
    user_params[:person] = {}
    user_params[:person][:profile] = {}
    if provider.roles.include? 'instructor'
      user_params[:person][:profile][:role] = 'teacher'
    elsif provider.roles.include? 'learner'    	
      user_params[:person][:profile][:role] = 'student'
    if provider.lis_outcome_service_url == 'http://school.demo.moodle.net/mod/lti/service.php'
      user_params[:person][:profile][:location] = "ISB, Hyderabad"
    user_params[:person][:profile][:first_name] = provider.lis_person_name_given
    user_params[:person][:profile][:last_name] = provider.lis_person_name_family
    user_params[:person][:profile][:full_name] = provider.lis_person_name_full
  	return user_params
  end	
  	
  	
end



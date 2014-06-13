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

	# Verify OAuth signature by passing the request object
	if provider.valid_request?(request)
	  @user= User.find_by_email(provider.lis_person_contact_email_primary)
	  unless @user.present?
	    user_params = signup_params(provider)
	  	@user = User.build(user_params)
	    @user.save
	  end  
	  create_or_join_course() 	    
	  sign_in_and_redirect(:user, @user)
	  Rails.logger.info("event=registration or signin status=successful user=#{@user.diaspora_handle}")   
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
  
  def create_or_join_course(provider, user)
  	user_aspect = user.aspects.where(:name => provider.context_title).first
  	return if user_aspect
  	      
  	#a teacher is the first member in the course and others then joins it  
    if provider.roles.include? 'instructor'
	  ##creates the course, can not happen that it is already created by a student
	  self.aspects.create(:name => provider.context_title, :folder => "Classroom", :code => create_short_code(provider.context_title))
	elsif provider.roles.include? 'learner'
      #joins the course mapped to the moodle course_id or create a course and joins it
      teacher_aspect = Aspect.where(:code => create_short_code(provider.context_title))
      if teacher_aspect
      	teacher_user = User.find(teacher_aspect.user_id)
        create_and_share_aspect(teacher_user, current_user, teacher_aspect)
      end  
    end
  end

  def create_short_code(course_name, id)
  	all_words = course_name.split
  	code = ""
  	all_words.each { |x| code += x.slice(0,1)}
  	code = course_name.slice(0,3) if code.length < 2
  	code += id.to_s
  	code
  end
   	
  def signup_params(provider)
  	user_params = {}
  	user_params[:username] = provider.lis_person_contact_email_primary.split('@')[0] + "_isb"
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
    end  
    if provider.lis_outcome_service_url == 'http://school.demo.moodle.net/mod/lti/service.php'
      user_params[:person][:profile][:location] = "ISB, Hyderabad"
    end  
    user_params[:person][:profile][:first_name] = provider.lis_person_name_given
    user_params[:person][:profile][:last_name] = provider.lis_person_name_family
    user_params[:person][:profile][:full_name] = provider.lis_person_name_full
  	user_params
  end	
  	
  	
end



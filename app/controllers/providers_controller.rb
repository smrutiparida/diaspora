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
    session[:launch_params] = params
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
      flash[:error] = t('devise.failure.invalid')
  	  Rails.logger.info("invalid request")
  	  redirect_to new_user_session_path
  	end
  end

  #this is for writing grade
  def grade

    report_data = Report.where(:aspect_id => params[:id])
    unless report_data.nil?
      report_data.each { |r| @data2.push([r.name, r.q_asked, r.q_answered, r.q_resolved, r.q_score])}
    end 


    if session['launch_params']
      key = session['launch_params']['oauth_consumer_key']
    else
      flash[:error] = "Please "
      return erb :error
    end

    @tp = IMS::LTI::ToolProvider.new(key, $oauth_creds[key], session['launch_params'])

    if !@tp.outcome_service?
      show_error "This tool wasn't launched as an outcome service"
      return erb :error
    end

    # post the given score to the TC
    res = @tp.post_replace_result!(params['score'])

    if res.success?
      @score = params['score']
      @tp.lti_msg = "Message shown when arriving back at Tool Consumer."
      erb :assessment_finished
    #elsif response.processing?

    #elsif response.unsupported?  
    else
      @tp.lti_errormsg = "The Tool Consumer failed to add the score."
      show_error "Your score was not recorded: #{res.description}"
      return erb :error
    end
  end	

  private
  
  def create_or_join_course(provider, user)
    short_code = create_short_code(provider.context_title, provider.context_id)
    #code for an aspect is unique
  	user_aspect = user.aspects.where(:name => provider.context_title, :code => short_code).first
  	return if user_aspect.present?
  	      
  	## RULE: a teacher is the first member in the course and others then joins it  
    ## teachercreates the course, can not happen that it is already created by a student
    ## student joins the course mapped to the moodle course_id or create a course and joins it
    if provider.roles.include? 'instructor'
	    self.aspects.create(:name => provider.context_title, :folder => "Classroom", :code => short_code, :admin_id => provider.context_id)
	  elsif provider.roles.include? 'learner'
      teacher_aspect = Aspect.where(:code => short_code, :admin_id => provider.context_id)
      if teacher_aspect
      	teacher_user = User.find(teacher_aspect.user_id)
        create_and_share_aspect(teacher_user, current_user, teacher_aspect)
      else
        flash[:notice] = "The course has not been created by the Instructor!"  
      end  
    end
  end

  def create_short_code(course_name, id)
  	all_words = course_name.split
  	code = ""
  	all_words.each { |x| code += x.slice(0,1)}
  	code = course_name.slice(0,3) if code.length < 2
  	code += "-" + id.to_s
  	code
  end
   	
  def signup_params(provider)
  	user_params = {}
  	user_params[:username] = get_user_name(provider.lis_person_contact_email_primary)
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
    #if provider.lis_outcome_service_url == 'http://school.demo.moodle.net/mod/lti/service.php'
    #TODO: This is hard coded for the time being
    user_params[:person][:profile][:location] = "ISB, Hyderabad"
    #end  
    user_params[:person][:profile][:first_name] = provider.lis_person_name_given
    user_params[:person][:profile][:last_name] = provider.lis_person_name_family
    user_params[:person][:profile][:full_name] = provider.lis_person_name_full
  	user_params
  end	
  
  def get_user_name(email)
    potential_name = email.split('@')[0]
    existing_username_count = User.where("username LIKE '#{potential_name}%'").count
    return potential_name if existing_username_count == 0
    
    begin
      potential_name = potential_name + "_" + existing_username_count.to_s
      user = User.find_by_username(potential_name)
      existing_username_count += 1
    end while user.present?
    
    potential_name
  end	
  	
end



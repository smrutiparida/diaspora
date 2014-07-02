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
    # session[:launch_params] = params
  	provider = IMS::LTI::ToolProvider.new(@consumer_key, @consumer_secret, params)

  	# Verify OAuth signature by passing the request object
  	if provider.valid_request?(request)
  	  @user = User.find_by_email(provider.lis_person_contact_email_primary)
  	  unless @user.present?
  	    user_params = signup_params(provider)
  	  	@user = User.build(user_params)
  	    @user.save!
  	  end  
  	  aspect_data = create_or_join_course(provider, @user) 	    
      #Workers::UpdateGrade.perform_async(provider, aspect_data) if provider.outcome_service? and aspect_data and @user.role == "student"
      perform_grade_post(provider, aspect_data) if provider.outcome_service? and aspect_data and @user.role == "student"
  	  sign_in_and_redirect(:user, @user)
  	  Rails.logger.info("event=registration or signin status=successful user=#{@user.diaspora_handle}")   
  	else
  	  # handle invalid OAuth
      flash[:error] = t('devise.failure.invalid')
  	  Rails.logger.info("invalid request")
  	  redirect_to new_user_session_path
  	end
  end
  
  private

  def perform_grade_post(provider, aspect)
    Rails.logger.info("posting grade")
    report_data = Report.where(:aspect_id => aspect.id)
    unless report_data.nil?
      max_score = report_data.maximum(:q_score)
      my_report = report_data.where(:person_id => aspect.user.person.id).first

      final_score = 0
      final_score = (my_report.q_score.to_f / max_score).round(2) if my_report and max_score > 0
      Rails.logger.info("final score is " + final_score.to_s)
      res = provider.post_replace_result!(final_score) 
      if res.success?
        Raills.logger.info(provider.lti_msg)
      else
        Rails.logger.info(provider.lti_errormsg)
    end 
  end  

  #this is for writing grade
  #def grade
  #  @consumer_key = 'lmnop-sandbox'
  #  @consumer_secret = 'lmnop123'

  #  return render :json => {"success" => true, "message" => "Grade published successfully!"}
    

  #  if session['launch_params']
  #    key = session['launch_params']['oauth_consumer_key']
  #  else
  #    return render :json => {"success" => true, "message" => "Could not validate credentials. Please login to LMS."}
  #  end

  #  @tp = IMS::LTI::ToolProvider.new(key, @consumer_secret, session['launch_params'])

  #  if !@tp.outcome_service?
  #    return render :json => {"success" => true, "message" => "LMNOP do not have necessary permission to publish grade!"} 
  #  end

  #  # post the given score to the TC
  #  report_data = Report.where(:aspect_id => params[:a_id])
  #  unless report_data.nil?
  #    report_data.each do |r|
  #      #@data2.push([r.name, r.q_asked, r.q_answered, r.q_resolved, r.q_score])
  #    end
  #    res = @tp.post_replace_result!(params['score'])  
  #  end 

  #  message = ""
  #  if res.success?
  #    message = "Grade published successfully!"
  #  #elsif response.processing?
  #  #elsif response.unsupported?  
  #  else
  #    message = "Your score was not recorded: #{res.description}"
  #  end

  #  respond_to do |format|
  #    format.json { render :json => {"success" => true, "message" => message} }
  #  end
  #end	
  
  def create_or_join_course(provider, user)
    short_code = create_short_code(provider.context_id, provider.resource_link_id)
    #code for an aspect is unique
  	user_aspect = user.aspects.where(:code => short_code).first
  	return user_aspect if user_aspect

  	## RULE: a teacher is the first member in the course and others then joins it  
    ## teachercreates the course, can not happen that it is already created by a student
    ## student joins the course mapped to the moodle course_id or create a course and joins it
    group_name = provider.resource_link_title
    if group_name == ""
      flash[:notice] = "Discussion group name cannot be empty!"
      return nil
    end  
    
    new_aspect = nil
    if provider.roles.include? 'instructor' and user.role == "teacher"
      begin
	      new_aspect = user.aspects.create!(:name => group_name, :folder => "Classroom", :code => short_code, :admin_id => provider.context_id, :order_id => provider.resource_link_id)
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = "Discussion group name is not unique!"
      end
	  elsif provider.roles.include? 'learner' and user.role == "student"
      teacher_aspect = Aspect.where(:order_id => provider.resource_link_id, :admin_id => provider.context_id).first
      if teacher_aspect
      	teacher_user = User.find(teacher_aspect.user_id)
        create_and_share_aspect(teacher_user, user, teacher_aspect)
        new_aspect = user.aspects.where(:name => teacher_aspect.name, :code => teacher_aspect.code).first
      else
        flash[:notice] = "The course has not been created by the Instructor!"  
      end
    else
      flash[:notice] = "Yous course is not created. Please check your role!"      
    end
    new_aspect
  end

  def create_short_code(id, link_id)
  	#all_words = course_name.split
  	#code = ""
  	#all_words.each { |x| code += x.slice(0,1)}
  	#code = course_name.slice(0,3) if code.length < 2
  	id.to_s + "-" + link_id.to_s
  	#code
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
    user_params[:person][:profile][:location] = "TEP, ISB Hyderabad"
    #end  
    user_params[:person][:profile][:first_name] = provider.lis_person_name_given
    user_params[:person][:profile][:last_name] = provider.lis_person_name_family
    user_params[:person][:profile][:full_name] = provider.lis_person_name_full
  	user_params
  end	
  
  def get_user_name(email)
    potential_name = email.split('@')[0]
    existing_username_count = User.where("username LIKE '#{potential_name}%'").count
    return potential_name if existing_username_count == 0 and potential_name.downcase != 'admin'
    
    begin
      potential_name = potential_name + "_" + existing_username_count.to_s
      user = User.find_by_username(potential_name)
      existing_username_count += 1
    end while user.present?
    
    potential_name
  end	
  	
end



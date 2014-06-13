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

	  #if new_user
	    ##signs up using lis_person_contact_email_primary,roles, lis_person_name_given, lis_person_name_family, "tool_consumer_instance_guid" => ISB, username => email, password => RANDOM
	    ##if teacher
	      ##creates the course
	    ##if student  
	      ##joins the course mapped to the moodle course_id
	        ##if join fails, explain that course is not yet created by the instructore here
	    #set devise token    
	   #elseif existing user
	      #find user details by email
	      #set devise token     
	  #@user= User.find_by_email(provider.)
	else
	  # handle invalid OAuth
	  Rails.logger.info("invalid request")
	end
	redirect_to_stream
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

  def new_signup
  	@user = User.build(user_params)
    if @user.save
      sign_in_and_redirect(:user, @user)
      Rails.logger.info("event=registration status=successful user=#{@user.diaspora_handle}")
    end
  end	
  	
end

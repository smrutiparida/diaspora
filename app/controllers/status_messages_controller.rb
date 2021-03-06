#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  before_filter :remove_getting_started, :only => [:create]

  respond_to :html,
             :mobile,
             :json

  layout 'application', only: :bookmarklet

  # Called when a user clicks "Mention" on a profile page
  # @param person_id [Integer] The id of the person to be mentioned
  def new
    @person = nil
    if params[:person_id] && @person = Person.where(:id => params[:person_id]).first
      @aspect = :profile
      @contact = current_user.contact_for(@person)
      @aspects_with_person = []
      if @contact
        @aspects_with_person = @contact.aspects
        @aspect_ids = @aspects_with_person.map{|x| x.id}
        gon.aspect_ids = @aspect_ids
        @contacts_of_contact = @contact.contacts
        render :layout => nil
      end
    else
      @aspect = :all
      @aspects = params[:a_id].blank? ? current_user.aspects : Aspect.where(:id => params[:a_id]) 
      @aspect_ids = @aspects.map{ |a| a.id }
      gon.aspect_ids = @aspect_ids
    end
  end

  def bookmarklet
    @aspects = current_user.aspects
    @aspect_ids = @aspects.map{|x| x.id}
  end

  def create
    #s_ids = Array.new
    #s_ids.push(params[:aspect_ids])
    #Rails.logger.info(*params[:aspect_ids])
    params[:status_message][:aspect_ids] = [*params[:aspect_ids]]
    #params[:status_message][:user_anonymity] = (params[:user_anonymity] == "true") ? true : false
    normalize_public_flag!
    services = [*params[:services]].compact

    @status_message = current_user.build_post(:status_message, params[:status_message])
    @status_message.build_location(:address => params[:location_address], :coordinates => params[:location_coords]) if params[:location_address].present?
    @status_message.attach_photos_by_ids(params[:photos])
    @status_message.attach_documents_by_ids(params[:Document])
    @status_message.get_assignments_by_ids(params[:Assignment])
    @status_message.get_quizzes_by_ids(params[:Quiz])

    if @status_message.save
      aspects = current_user.aspects_from_ids(destination_aspect_ids)
      current_user.add_to_streams(@status_message, aspects)
      receiving_services = Service.titles(services)

      #disabling dispatch as services are not part of the student-teacher architecture
      current_user.dispatch_post(@status_message, :url => short_post_url(@status_message.guid), :service_types => receiving_services)

      #this is done implicitly, somewhere else, but it doesnt work, says max. :'(
      @status_message.photos.each do |photo|
        current_user.dispatch_post(photo)
      end
      
      #add status message to a course
      course_params = {:post_id => @status_message.id, :type => "Post", :module_id => params[:s_id]}
      current_user.build_post(:course, course_params).save

      current_user.participate!(@status_message)

      if coming_from_profile_page? && !own_profile_page? # if this is a post coming from a profile page
        flash[:notice] = successful_mention_message
      end

      respond_to do |format|
        format.html { redirect_to :back }
        format.mobile { redirect_to stream_path }
        format.json { render :json => PostPresenter.new(@status_message, current_user), :status => 201 }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to :back }
        format.mobile { redirect_to stream_path }
        format.json { render :nothing => true , :status => 403 }
      end
    end
  end

  private

  def destination_aspect_ids
    if params[:status_message][:public] || params[:status_message][:aspect_ids].first == "all_aspects"
      current_user.aspect_ids
    else
      params[:aspect_ids]
    end
  end

  def successful_mention_message
    t('status_messages.create.success', :names => @status_message.mentioned_people_names)
  end

  def coming_from_profile_page?
    request.env['HTTP_REFERER'].include?("people")
  end

  def own_profile_page?
    request.env['HTTP_REFERER'].include?("/people/" + params[:status_message][:author][:guid].to_s)
  end

  def normalize_public_flag!
    # mobile || desktop conditions
    sm = params[:status_message]
    public_flag = (sm[:aspect_ids] && sm[:aspect_ids].first == 'public') || sm[:public]
    public_flag.to_s.match(/(true)|(on)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag
    public_flag
  end

  def remove_getting_started
    current_user.disable_getting_started
  end
end

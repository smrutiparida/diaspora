class GradesController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show]
  respond_to :html, :json, :js

  def index    
    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end

  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    all_my_posts = Post.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => params[:id]})
    all_my_post_guid = all_my_posts.map{|a| a.guid}
    @data = {}
    @temp = []

    if @teacher
      @assignments = Assignment.where(:status_message_guid => all_my_post_guid, :is_result_published => true).order(:updated_at)
      all_assignment_ids = @assignments.map{|a| a.id}
      @all_assessments = AssignmentAssessment.where(:assignment_id => all_assignment_ids, :is_checked => true).order(:diaspora_handle, :assignment_id)
      unless @all_assessments.nil?
        @all_assessments.each do |c|
          if !@data.has_key?(c.diaspora_handle)
            @data[c.diaspora_handle] = {}
          end  
          @data[c.diaspora_handle][c.assignment_id] = c.points
        end
      end  
      Rails.logger.info(@data.to_json)
      @t = []
      @t.push("Name")
      @assignments.each{|a| @t.push(a.name)}
      temp.push(t)
      
      @data.each do |key, value|
        @t1 = []
        @t1.push(key)
        @assignments.each do |a|
          value.has_key?(a.id) ? @t1.push(value[a.id]) : @t1.push(0)
        end
        temp.push(@t1)    
      end  
      Rails.logger.info(@temp.to_json)
    else      
      opts = {}
      if params[:a_id]
        opts[:by_members_of] = params[:a_id]
      end  
      
      all_my_posts = current_user.visible_shareables(Post, opts)
      all_my_post_guid = all_my_posts.map{|a| a.guid}
      
      @assignments = Assignment.where(:status_message_guid => all_my_post_guid)
      @quizzes = Quiz.where(:status_message_guid => all_my_post_guid)
      @documents += Document.where(:status_message_guid => all_my_post_guid)
    end
  end
end
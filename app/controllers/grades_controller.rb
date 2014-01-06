require 'csv'
class GradesController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :parse]
  respond_to :html, :json, :js

  def index    
    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end

  def new
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def parse
    Rails.logger.info("inside")
    Rails.logger.info(request.raw_post.force_encoding('BINARY'))
    file_name = params[:qqfile]
    file = Tempfile.new(file_name)
    # put data into this file from raw post request
    file.print request.raw_post.force_encoding('BINARY')

    file.close
    @data = []
    Rails.logger.info(file.path.to_s)
    CSV.foreach(file.path) do |row|
      Rails.logger.info(row.to_json)
      @data.push(row)      
    end
    respond_to do |format|
      format.json {render :json => @data.to_json}
    end 
  end

  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    
    @data = {}
    @temp = []

    if @teacher  
      all_my_posts = Post.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => params[:id]})
      all_my_post_guid = all_my_posts.map{|a| a.guid}
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
      @t0 = []
      @t0.push(t('username'))
      @assignments.each{|a| @t0.push(a.name)}
      Rails.logger.info(@t0.to_json)
      @temp.push(@t0)
      
      @data.each do |key, value|
        @t1 = []
        @t1.push(key)
        @assignments.each do |a|
          value.has_key?(a.id) ? @t1.push(value[a.id]) : @t1.push(0)
        end
        @temp.push(@t1)    
      end  
      Rails.logger.info(@temp.to_json)
    else  
      opts = {}
      if params[:a_id]
        opts[:by_members_of] = params[:id]
      end
      all_my_posts = current_user.visible_shareables(Post, opts)
      all_my_post_guid = all_my_posts.map{|a| a.guid}
      @assignments = Assignment.where(:status_message_guid => all_my_post_guid, :is_result_published => true)
      all_assignment_ids = @assignments.map{|a| a.id}
      @all_assessments = AssignmentAssessment.where(:assignment_id => all_assignment_ids, :is_checked => true, :diaspora_handle => current_user.diaspora_handle).order(:assignment_id)    
      @temp.push(['Assignment Name', 'Total Points', 'My Points']) 
      @all_assessments.each{|a| @data[a.assignment_id] = a.points}
      
      unless @assignments.nil?
        @assignments.each do |a|
          @t0 = []
          @t0.push(a.name)
          @t0.push(a.comments_count)
          @t0.push(@data[a.id])
          @temp.push(@t0)
        end
      end  
      Rails.logger.info(@temp.to_json)
    end
  end
end
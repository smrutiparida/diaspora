#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StreamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :save_selected_aspects, :only => :aspects
  before_filter :redirect_unless_admin, :only => :public

  respond_to :html,
             :mobile,
             :json

  def aspects
    aspect_ids = (session[:a_ids] || [])
    @stream = Stream::Aspect.new(current_user, aspect_ids,
                                 :max_time => max_time)
    stream_responder
  end

  def public
    stream_responder(Stream::Public)
  end

  def activity
    stream_responder(Stream::Activity)
  end

  def multi
      stream_responder(Stream::Multi)
  end

  def commented
    stream_responder(Stream::Comments)
  end

  def liked
    stream_responder(Stream::Likes)
  end

  def mentioned
    stream_responder(Stream::Mention)
  end

  def followed_tags
    gon.preloads[:tagFollowings] = tags
    stream_responder(Stream::FollowedTag)
  end

  private

  def stream_responder(stream_klass=nil)
    if stream_klass.present?
      @stream ||= stream_klass.new(current_user, :max_time => max_time)
    end
    
    
    #below logic will filter courses by modules
    all_aspects = (session[:a_ids] || []) 
    if all_aspects.length > 0
      my_aspect_id = current_user.role == "teacher" ? all_aspects[0] : get_my_teacher_aspect_id(all_aspects[0])
      @all_course_modules = Content.where(:aspect_id => my_aspect_id).order(:created_at)
      Rails.logger.info(@all_course_modules.to_json)
      all_course_modules_guid = @all_course_modules.map{|a| a.id}
      all_my_courses = Course.where(:module_id => all_course_modules_guid).order(:module_id)
      @stream.stream_posts.each do |p|
        ele_array = all_my_courses.select { |ele|  ele.post_id == p.id }
        @stream.stream_posts.delete(p) if ele_array.length == 0
      end    
    end      
    #      :aspect_visibilities => {:aspect_id => params[:a_id]})
    #else
    #  all_my_posts = Post.joins(:aspect_visibilities).where(
    #      :aspect_visibilities => {:aspect_id => current_user.aspect_ids})  
    #end  
    #all_my_post_guid = all_my_posts.map{|a| a.guid}
    
    @assignments = nil #Assignment.where(:status_message_guid => all_my_post_guid, :is_result_published => false)
    @quizzes = nil #QuizAssignment.where(:status_message_guid => all_my_post_guid)
    
    respond_with do |format|
      format.html { render 'streams/main_stream' }
      format.mobile { render 'streams/main_stream' }
      format.json { render :json => @stream.stream_posts.map {|p| LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user)) }}
    end
  end

  def save_selected_aspects
    if params[:a_ids].present?
      session[:a_ids] = params[:a_ids]
    end
  end
end

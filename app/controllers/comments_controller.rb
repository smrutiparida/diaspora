#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :except => [:index]

  respond_to :html,
             :mobile,
             :json

  rescue_from ActiveRecord::RecordNotFound do
    render :nothing => true, :status => 404
  end

  def create
    post = current_user.find_visible_shareable_by_id(Post, params[:post_id])
    @comment = current_user.comment!(post, params[:text]) if post

    if @comment
      respond_to do |format|
        format.json{ render :json => CommentPresenter.new(@comment), :status => 201 }
        format.html{ render :nothing => true, :status => 201 }
        format.mobile{ render :partial => 'comment', :locals => {:post => @comment.post, :comment => @comment} }
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def update
    @comment = Comment.find(params[:c_id])
    @comment.is_endorsed = !@comment.is_endorsed
    @comment.save
    
    render :nothing => true, :status => 202
  end

  def destroy
    @comment = Comment.find(params[:id])
    if current_user.owns?(@comment) || current_user.owns?(@comment.parent)
      current_user.retract(@comment)
      respond_to do |format|
        format.js { render :nothing => true, :status => 204 }
        format.json { render :nothing => true, :status => 204 }
        format.mobile{ redirect_to :back }
      end
    else
      respond_to do |format|
        format.mobile { redirect_to :back }
        format.any(:js, :json) {render :nothing => true, :status => 403}
      end
    end
  end

  def new
    render :layout => false
  end

  def index
    find_post
    raise(ActiveRecord::RecordNotFound.new) unless @post

    @comments = @post.comments.for_a_stream
    like_posts_for_stream(@comments)

    respond_with do |format|
      format.json  { render :json => CommentPresenter.as_collection(@comments), :status => 200 }
      format.mobile{render :layout => false}
    end
  end

  private

  def find_post
    if user_signed_in?
      @post = current_user.find_visible_shareable_by_id(Post, params[:post_id])
    else
      @post = Post.find_by_id_and_public(params[:post_id], true)
    end
  end

  def like_posts_for_stream!(comments)
    return comments unless current_user

    likes = Like.where(:author_id => current_user.person_id, :target_id => comments.map(&:id), :target_type => "Comment")

    like_hash = likes.inject({}) do |hash, like|
      hash[like.target_id] = like
      hash
    end

    comments.each do |comment|
      comment.user_like = like_hash[comment.id]
    end
  end
end

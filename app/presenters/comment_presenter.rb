class CommentPresenter < BasePresenter
  def initialize(comment, current_user = nil)
    @comment = comment
    @current_user = current_user
  end

  def as_json(opts={})
    {
      :id => @comment.id,
      :guid => @comment.guid,
      :text  => @comment.text,
      :author => @comment.author.as_api_response(:backbone),
      :created_at => @comment.created_at,
      :is_endorsed => @comment.is_endorsed,
      :likes_count => @comment.likes_count,
      :likes => filter_like(@comment).as_api_response(:backbone),
    }
  end

  def filter_like(comment)
    like = Like.where(:author_id => @current_user.person_id, :target_id => comment.id, :target_type => "Comment").first
    #return [] if user_like.nil?
    like
  end   

  #def like_posts_for_stream!(comments)

  #  like = Like.where(:author_id => current_user.person_id, :target_id => comment.id, :target_type => "Comment").first
  #  like

  #  like_hash = likes.inject({}) do |hash, like|
  #    hash[like.target_id] = like
  #    hash
  #  end

  #  comments.each do |comment|
  #    comment.user_like = if like_hash.has_key?(comment.id) ? like_hash[comment.id] : Like.new
  #  end
  #  Rails.logger.info(comments.to_json)
  #end
end
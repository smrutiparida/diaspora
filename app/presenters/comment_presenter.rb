class CommentPresenter < BasePresenter
  def initialize(comment)
    @comment = comment
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
      :likes => [user_like].compact,
    }
  end

  def user_like
    @comment.like_for(@current_user).try(:as_api_response, :backbone)
  end

end
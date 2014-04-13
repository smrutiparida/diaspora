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
      :is_endorsed => @comment.is_endorsed
    }
  end
end
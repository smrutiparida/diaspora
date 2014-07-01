class LastThreeCommentsDecorator
  def initialize(presenter)
    @presenter = presenter
  end

  def as_json(options={})
    @presenter.as_json.tap do |post|
      post[:interactions].merge!(:comments => CommentPresenter.collection_json(@presenter.post.last_three_comments, @presenter))
    end
  end
end
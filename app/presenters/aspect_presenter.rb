class AspectPresenter < BasePresenter
  def initialize(aspect)
    @aspect = aspect
  end

  def as_json
    { :id => @aspect.id,
      :name => @aspect.name,
      :folder => @folder,
      :admin_id => @admin_id,
    }
  end

  def to_json(options = {})
    as_json.to_json(options)
  end
end
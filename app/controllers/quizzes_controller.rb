class QuizzesController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :index]
  respond_to :html, :json, :js

  def create
  	
    respond_to do |format|

      # Used for normal requests to contacts#index and subsequent infinite scroll calls
      format.html { get_question_bank }

      # Used by the mobile site
      format.mobile { set_question_bank }

      # Used to populate mentions in the publisher
      format.json {
      #  aspect_ids = params[:aspect_ids] || current_user.aspects.map(&:id)
      #  @people = Person.all_from_aspects(aspect_ids, current_user).for_json
      #  render :json => @people.to_json
      }
    end
  end

  private 

  def get_question_bank
  	@questions = Question.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
	@questions = @questions.for_a_stream.paginate(:page => params[:page], :per_page => 100)
    @questions_size = @questions.length
  end	
end  
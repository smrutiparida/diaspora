#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ReportsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html,
             :js,
             :json

  def show   
  	@data =[['Work',     11],['Eat',      2], ['Commute',  2], ['Watch TV', 2],['Sleep',    7]]
  	@data2 = [['Work',     11],['Eat',      2], ['Commute',  2], ['Watch TV', 2],['Sleep',    7]]
    respond_to do |format|
	  format.html
	end 
	@aspect_assessments = AspectAssessment.find(params[:a_id])
	#data for the aspect id, rank all memebers based on data in aspect_assessments table
	#columns needed -> aspect_id, person_id, qs_asked, qs_answered, answsers_marked_right, score, answers_resolved
	@data_for_score_table = []
	@status_assessment_table = StatusAssessment.find(params[:a_id])
	#have resolved_Date and closed_date added to the POST table
	#aspect_id, total_respolved, total_marked_right, total_open, total_posts, total_anonymous
	@data_for_open_conversations = []
	@data_for_closed_conversations = []
	@data_for_anonymous_questions = []

	if current_user.role == "teacher"
	  @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
	  unless @assignment_assessments.nil?
	    @assignment_assessments.each do |c|
	      c.is_checked ? @data2.push([c.diaspora_handle, c.points]) : next
	      @key = c.points.to_s + " marks"
	      @temp.has_key?(@key) ? @temp[@key] = @temp[@key] + 1 : @temp[@key] = 1          
	    end
	  end    
	end

	@temp.each { |key,value| @data.push([key, value])}
	Rails.logger.info(@data.to_json)
	Rails.logger.info(@data2.to_json)
	#respond_to do |format|
	#  format.js
	#end
  end  
end 
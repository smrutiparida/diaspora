class CoursesController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :parse]
  respond_to :html, :json, :js

  def index    
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end
	
  def show
  	@all_course_modules = Content.where(:aspect_id => params[:id]).order(:created_at)
    Rails.logger.info(@all_course_modules.to_json)
  	all_course_modules_guid = @all_course_modules.map{|a| a.id}
    all_my_courses = Course.where(:module_id => all_course_modules_guid).order(:module_id)
    @all_formatted_courses = format_course(all_my_courses)
    respond_to do |format|
      format.js
    end 
  end

  def create
  	@course = current_user.build_post(:course, course_params)
  	@course_content = Content.find(@course.module_id)
  	if @course.save
      respond_to do |format|
        format.js
      end
    end
  end

  def course_params
    params.require(:course).permit(:module_id, :post_id, :type)
  end

  private

  def format_course(all_courses)
    data_dict = { 1 => [["Type", "Name"],["Assignment", "<a href='1'>This is a dummy assignment with ver long header</a>"],["Header", "THis is another course with no link nothing."]]}
    data_dict
  end
end
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
    all_my_courses = Course.where(:aspect_id => params[:id]).order(:module_id)
    @temp = format_course(all_my_courses)
    respond_to do |format|
      format.js
    end 
  end
end
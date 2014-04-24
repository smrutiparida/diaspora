class ContentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :new, :create]
  respond_to :html, :json, :js

  def index    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    my_aspect_id = current_user.role == "teacher" ? params[:id] : get_my_teacher_aspect_id(params[:id])
    @all_course_modules = Content.where(:aspect_id => my_aspect_id).order(:created_at)
    
    respond_to do |format|
      format.json do
        render :json => @all_course_modules.to_json
      end
    end
       
  end

  def new   
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def create
    @new_module = current_user.build_post(:content, content_params)  

  	if @new_module.save
      respond_to do |format|
        format.js
      end
    end
  end    
	
  def content_params
    params.require(:content).permit(:name, :a_id)
  end

  def get_my_teacher_aspect_id(student_aspect_id)
    aspect = Aspect.find(student_aspect_id)
    contacts_in_aspect = aspect.contacts.includes(:aspect_memberships).all    
    all_person_guid = contacts_in_aspect.map{|a| a.person_id}
    
    teacher_in_contact = Person.joins(:profile).where('profiles.person_id' => all_person_guid, 'profiles.role' => 'teacher').first
    
    unless teacher_in_contact.blank?
      @user_aspect = teacher_in_contact.owner.aspects.where(:name => aspect.name).first
    end
    @user_aspect.id
  end
  
end
class CoursesController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :parse, :create]
  respond_to :html, :json, :js

  def index    
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    

    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end
	
  def show
    my_aspect_id = current_user.role == "teacher" ? params[:id] : get_my_teacher_aspect_id(params[:id])
  	@all_course_modules = Content.where(:aspect_id => my_aspect_id).order(:created_at)
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
      @response = @course.as_api_response(:backbone)
      @response[:success] = true
      @response[:message] = "Course created successfully."
      respond_to do |format|
        format.js
      end
    end
  end

  def course_params
    params.require(:course).permit(:module_id, :post_id, :type)
  end

  private
  
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

  def format_course(all_courses)
    @data_dict = {}
    unless all_courses.nil?
      all_courses.each do |course|
        if !@data_dict.has_key?(course.module_id)
          @data_dict[course.module_id] = []
          @data_dict[course.module_id].push(["Type", "Name"])
        end  
        temp = []
        
        if course.type == 'Assignment'
          temp.push(course.type)
          assignment = Assignment.find(course.post_id)
          temp.push("<a target='_blank' href='/assignment_assessments/"+ assignment.id.to_s + "'>" + assignment.name + "</a>")
        elsif course.type == "Quiz"
          temp.push(course.type)
          quiz = Quiz.joins(:quiz_assignments).where('quiz_assignments.id' => course.post_id).first
          temp.push("<a target='_blank' href='/quiz_assignments/"+ course.post_id.to_s + "'>" + quiz.title + "</a>")
        elsif course.type == "Document"
          temp.push(course.type)
          file = Document.find(course.post_id)
          temp.push("<a target='_blank' href='"+ file.remote_path + file.remote_name + "'>" + file.processed_doc + "</a>")
        elsif course.type == "OEmbedCache"
          extern_link = OEmbedCache.find(course.post_id)
          if extern_link.url.blank?
            temp.push("Text")
            temp.push(extern_link.data)
          else
            temp.push("Link")  
            temp.push("<a target='_blank' href='"+ extern_link.url + "'>" + extern_link.data + "</a>")
          end  
        end  
        @data_dict[course.module_id].push(temp)
      end
    end  
    @data_dict
  end
end
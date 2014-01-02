class AssignmentAssessmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :index, :destroy, :show]
  respond_to :html, :json, :js

  def new
    @assignment = Assignment.find(params[:assign_id])
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true
    @assignment = Assignment.find(params[:id])
    @teacher_info = Person.includes(:profile).where(diaspora_handle: @assignment.diaspora_handle).first
    @assignment_assessments = nil
    @assignment_assessment = nil
    if @teacher
      @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
      @assignment_assessment = AssignmentAssessment.where(:assignment_id => @assignment.id).first
    else
      @assignment_assessment = AssignmentAssessment.where(:assignment_id => @assignment.id, :diaspora_handle => current_user.diaspora_handle).first
    end

    @authors = {}
    @assignment_assessments.each { |c| @authors[c.id] = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first }

    
    respond_to do |format|
      format.html      
    end
  end

  def create
    rescuing_document_errors do
      if remotipart_submitted?
        @assignment_assessment = current_user.build_post(:assignment_assessment, assignment_assessment_params)
        if @assignment_assessment.save
          respond_to do |format|
            format.json { render :json => {"success" => true, "message" => 'Assignment submitted successfully.'} }
          end
        else
          respond_with @assignment_assessment, :location => assignment_assessments_path, :error => message
        end
      else
        legacy_create    
      end  
    end
  end

  private

  def file_handler(params)
    # For XHR file uploads, request.params[:qqfile] will be the path to the temporary file
    # For regular form uploads (such as those made by Opera), request.params[:qqfile] will be an UploadedFile which can be returned unaltered.
    if not request.params[:qqfile].is_a?(String)
      params[:qqfile]
    else
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      #get file content length
      att_content_length = (request.content_length.to_i == 0) ? 0 : request.content_length.to_i
      # create tempora##l file
      file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
      # put data into this file from raw post request
      file.print request.raw_post.force_encoding('BINARY')

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
      Tempfile.send(:define_method, "content_length") {return att_content_length}
      file
    end
  end
  
  def assignment_assessment_params
    params.require(:assignment_assessment).permit(:assignment_id, :user_file)
  end

  def legacy_create
    params[:assignment_assessment][:user_file] = file_handler(params)

    @assignment_assessment = current_user.build_post(:assignment_assessment, params[:assignment_assessment])

    if @assignment_assessment.save      
      respond_to do |format|
        format.json{ render(:layout => false , :json => {"success" => true, "data" => 'Assignment uploaded successfully.' })}
      end
    else
      respond_with @assignment_assessment, :location => assignment_assessments_path, :error => message
    end
  end

  def rescuing_document_errors
    begin
      yield
    rescue TypeError
      message = I18n.t 'documents.create.type_error'
      respond_with @assignment_assessment, :location => assignment_assessments_path, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'documents.create.integrity_error'
      respond_with @assignment_assessment, :location => assignment_assessments_path, :error => message

    rescue RuntimeError => e
      message = I18n.t 'documents.create.runtime_error'
      respond_with @assignment_assessment, :location => assignment_assessments_path, :error => message
      raise e
    end
  end

end
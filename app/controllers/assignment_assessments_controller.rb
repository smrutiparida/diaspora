class AssignmentAssessmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :index, :destroy, :show, :update, :publish, :performance]
  respond_to :html, :json, :js

  def new
    @assignment = Assignment.find(params[:assign_id])
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def publish
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true
    @assignment_assessments = nil
    @assignment = Assignment.find(params[:a_id])
    if @teacher and !@assignment.is_result_published      
      @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
      unless @assignment_assessments.nil?
        @assignment_assessments.each { 
          |c| @recipient = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first
          opts = {}
          opts[:participant_ids] = @recipient.id
          opts[:message] = { text: "Assignment result has been published."}
          opts[:subject] = "Assignment published."
          @conversation = current_user.build_conversation(opts)

          if @conversation.save
            Postzord::Dispatcher.build(current_user, @conversation).post
          end
        }
        assessment_hash = {}
        assessment_hash[:is_result_published] = true
        @assignment.update_attributes!(assessment_hash)
      end
    end
    respond_to do |format|
      format.json { render :json => {"success" => true, "message" => 'Assignment published successfully.'} }
    end  
  end

  def performance
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true
    @assignment_assessments = nil
    @assignment = Assignment.find(params[:a_id])
    @data = []
    @data2 = []
    @temp = {}
    if @teacher      
      @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
      unless @assignment_assessments.nil?
        @assignment_assessments.each do |c|
          c.is_checked ? @data2.push([c.diaspora_handle ,c.points]) : next
          temp[c.points] = temp[c.points] + 1 
        end
      end    
    end

    @temp.each { |key,value| @data.push([key, val])}
    Rails.logger.info(data.to_json)
    Rails.logger.info(data2.to_json)
    respond_to do |format|
      format.js
    end
  end

  def update
    @assignment_assessment = AssignmentAssessment.find(params[:id])
    Rails.logger.info(@assignment_assessment.to_json)
    assessment_hash = assignment_assessment_params
    assessment_hash[:points] = assessment_hash[:points].to_i
    assessment_hash[:is_checked] = true
    assessment_hash[:checked_date] = Time.now
    Rails.logger.info(assessment_hash.to_json)

    if @assignment_assessment.update_attributes!(assessment_hash)
      redirect_to '/assignment_assessments/' + @assignment_assessment.assignment_id.to_s + '?s_id=' + @assignment_assessment.id.to_s
    else
      flash[:error] = I18n.t 'aspects.update.failure', :name => @aspect.name
    end    
  end

  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true
    @assignment = Assignment.find(params[:id])
    @teacher_info = Person.includes(:profile).where(diaspora_handle: @assignment.diaspora_handle).first
    @assignment_assessments = nil
    @assignment_assessment = nil 

    @authors = {}
    if @teacher
      @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
      if params[:s_id]
        @assignment_assessment = AssignmentAssessment.where(:id => params[:s_id], :assignment_id => @assignment.id).first
        @student = Person.includes(:profile).where(diaspora_handle: @assignment_assessment.diaspora_handle).first
        Rails.logger.info(@student.to_json)
        Rails.logger.info(@assignment_assessment.to_json)
      else  
        @assignment_assessment = AssignmentAssessment.where(:assignment_id => @assignment.id).first
      end  
      unless @assignment_assessments.nil?
        @assignment_assessments.each { |c| @authors[c.id] = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first }
      end
    else
      @assignment_assessment = AssignmentAssessment.where(:assignment_id => @assignment.id, :diaspora_handle => current_user.diaspora_handle).first        
      unless @assignment_assessment.nil?
        @authors[@assignment_assessment.id] = Person.includes(:profile).where(diaspora_handle: @assignment_assessment.diaspora_handle).first
      end
    end

    
    respond_to do |format|
      format.js
      format.any(:json, :html) { render }
    end
  end

  def create
    rescuing_document_errors do
      Rails.logger.info("Line 41")
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
        Rails.logger.info("Line 52")
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
      Rails.logger.info("Line 66")
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
      Rails.logger.info("Line 83")
      file
    end
  end
  
  def assignment_assessment_params
    params.require(:assignment_assessment).permit(:assignment_id, :user_file, :points, :comments)
  end

  def legacy_create
    params[:assignment_assessment][:user_file] = file_handler(params)
    Rails.logger.info("Line 92")
    @assignment_assessment = current_user.build_post(:assignment_assessment, params[:assignment_assessment])
    Rails.logger.info(@assignment_assessment.to_json)
    if @assignment_assessment.save
      #redirect_to '/assignment_assessments/' + @assignment_assessment.assignment_id.to_s      
      respond_to do |format|
        format.json { render :json => {"success" => true, "message" => 'Assignment submitted successfully.'} }
        format.html{ render(:layout => false , :json => {"success" => true}.to_json )}
      end
    else
      Rails.logger.info("Line 103")
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
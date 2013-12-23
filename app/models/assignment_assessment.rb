class AssignmentAssessment < ActiveRecord::Base

  mount_uploader :unprocessed_doc, UnprocessedDocument

  def self.diaspora_initialize(params = {})
    assignment_assessment = self.new
    assignment_assessment.assignment_id = params[:assignment_id]
    assignment_assessment.diaspora_handle = params[:diaspora_handle]
    assignment_assessment.submission_date = DateTime.now
    assignment_assessment.filename = params[:user_file].original_filename()
    assignment_assessment.size = params[:user_file].content_length()
    
    assignment_assessment.random_string = SecureRandom.hex(10)
        
    assignment_assessment.unprocessed_doc.store! params[:user_file]
    assignment_assessment.filepath = assignment_assessment.unprocessed_doc.url
    
    assignment_assessment
  end
end   
class AssignmentAssessment < ActiveRecord::Base

  mount_uploader :unprocessed_doc, UnprocessedDocument

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    assignment_assessment = self.new
    assignment_assessment.assignment_id = params[:assignment_id]
    assignment_assessment.diaspora_handle = params[:diaspora_handle]
    assignment_assessment.submission_date = DateTime.now
    assignment_assessment.filename = params[:user_file].original_filename()
    assignment_assessment.size = params[:user_file].content_length()
    
    assignment_assessment.random_string = SecureRandom.hex(10)
        
    doc_file = params.delete(:user_file)
    Rails.logger.info(doc_file)
    assignment_assessment.unprocessed_doc.store! doc_file
    Rails.logger.info(assignment_assessment.to_json)
    assignment_assessment.filepath = assignment_assessment.unprocessed_doc.url
    assignment_assessment.delete("unprocessed_doc")
    Rails.logger.info("Model exit")
    assignment_assessment
  end
end   
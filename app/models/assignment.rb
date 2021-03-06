class Assignment < ActiveRecord::Base
  include Diaspora::Federated::Shareable
  include Diaspora::Commentable
  include Diaspora::Shareable

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at
    t.add :submission_date
    t.add lambda { |assignment|
            assignment.subdate(assignment.submission_date)
          }, :as => :sub_date
    t.add lambda { |assignment|
            assignment.submonth(assignment.submission_date)
          }, :as => :sub_month    
    t.add :author
    t.add :name
    t.add :description
    t.add :pending
    t.add :comments_count, :as => :points    
  end

  xml_attr :name
  xml_attr :description
  xml_attr :status_message_guid

  belongs_to :status_message, :foreign_key => :status_message_guid  , :primary_key => :guid
  has_many   :documents, :foreign_key => :document_id, :primary_key => :id
  validates_associated :status_message
  delegate :author_name, to: :status_message, prefix: true

  validate :ownership_of_status_message

  before_destroy :ensure_user_assignment
  after_destroy :clear_empty_status_message

  
  def subdate(date = nil)    
    if date
      Rails.logger.info(date.to_s)
      DateTime.parse(date.to_s).strftime("%d")
    end
  end

  def submonth(date = nil)
    if date
      DateTime.parse(date.to_s).strftime("%b")
    end  
  end  

  def clear_empty_status_message
    if self.status_message_guid && self.status_message.text_and_photos_and_documents_blank_and_assignments_blank_and_quiz_assignments_blank?
      self.status_message.destroy
    else
      true
    end
  end

  def ownership_of_status_message
    message = StatusMessage.find_by_guid(self.status_message_guid)
    if self.status_message_guid && message
      self.diaspora_handle == message.diaspora_handle
    else
      true
    end
  end

  def self.diaspora_initialize(params = {})
    assignment = self.new #params.to_hash.slice(:name, :description, :submission_date)
    assignment.name = params[:name]
    assignment.description = params[:description]
    assignment.file_upload = false unless params[:file_upload]
    assignment.author = params[:author]
    assignment.public = params[:public] if params[:public]
    assignment.pending = params[:pending] if params[:pending]
    assignment.diaspora_handle = assignment.author.diaspora_handle
    assignment.comments_count = params[:comments_count]
    
    #submission_date is turning out to be null.. need fixing
    #assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y %I:%M:%S %p')
    assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y')
        
    assignment
  end

  def find_all_assignments_for_library
     # if I am a student
     # all assignments that is shared in an aspect I am a member of.
     # 
     
     Post.joins(:aspect_memberships).where(conditions)

    if opts[:by_members_of]
      query = query.joins(:contacts => :aspect_memberships).where(
        :aspect_memberships => {:aspect_id => opts[:by_members_of]})
    end   
  end
  scope :on_statuses, lambda { |post_guids|
    where(:status_message_guid => post_guids)
  }
end


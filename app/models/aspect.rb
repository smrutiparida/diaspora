#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Aspect < ActiveRecord::Base
  belongs_to :user

  has_many :aspect_memberships, :dependent => :destroy
  has_many :contacts, :through => :aspect_memberships

  has_many :aspect_visibilities
  has_many :posts, :through => :aspect_visibilities, :source => :shareable, :source_type => 'Post'
  has_many :photos, :through => :aspect_visibilities, :source => :shareable, :source_type => 'Photo'
  has_many :documents, :through => :aspect_visibilities, :source => :shareable, :source_type => 'Document'
  has_many :assignments, :through => :aspect_visibilities, :source => :shareable, :source_type => 'Assignment'
  has_many :quiz_assignments, :through => :aspect_visibilities, :source => :shareable, :source_type => 'QuizAssignment'

  validates :name, :presence => true, :length => { :maximum => 50 }

  validates_uniqueness_of :name, :scope => :user_id, :case_sensitive => false

  before_validation do
    name.strip!
  end

  def to_s
    name
  end

  def << (shareable)
    case shareable
      when Post
        self.posts << shareable
      when Photo
        self.photos << shareable
      when Document
        self.documents << shareable
      when Assignment
        self.assignments << shareable  
      when QuizAssignment
        self.quiz_assignments << shareable  
      else
        raise "Unknown shareable type '#{shareable.class.base_class.to_s}'"
    end
  end
  
  def to_beautify
    name.to_s + ' (' + code.to_s + ')'
  end

  def self.patching_up
    inviter = User.find(236)
    inviter_aspect = Aspect.find(202)

    contacts_in_aspect = inviter_aspect.contacts.includes(:aspect_memberships, :person => :profile).all     
    all_person_guid = contacts_in_aspect.map{|a| a.person_id}   
    person_in_contacts = Person.where(:id => all_person_guid)
    person_in_contacts.each do |present_person|
      person_in_contacts.each do |existing_member|
        contact = present_person.owner.contacts.find_or_initialize_by_person_id(existing_member.id)
        if contact.valid?
          Rails.logger.info(contact.to_json)
          posts = Post.where(:author_id => contact.person_id).joins(:aspects).where(:aspects => {:name => inviter_aspect.name}).limit(100)
          p = posts.map do |post|
            s = ShareVisibility.where(:contact_id => contact.id, :shareable_id => post.id, :shareable_type => 'Post')
            l = nil
            if s.empty?
              l = ShareVisibility.new(:contact_id => contact.id, :shareable_id => post.id, :shareable_type => 'Post') 
              #ShareVisibility.import([:contact_id, :shareable_id, :shareable_type], [contact.id, post.id, 'Post'])
            end
            Rails.logger.info(l.to_json)
            l
          end
          Rails.logger.info(p.to_json)
          ShareVisibility.import(p.compact) unless p.compact.empty?
          Rails.logger.info(p.compact.to_json)
        else
          Rails.logger.info("contact not valid")  
        end  
      end 
    end  
  end  
end


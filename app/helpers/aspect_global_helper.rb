#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspect_membership_dropdown(contact, person, hang, aspect=nil)
    aspect_membership_ids = {}
    group_aspects = all_aspects.where(:folder => 'Classroom')
    selected_aspects = group_aspects.select{|aspect| contact.in_aspect?(aspect)}
    selected_aspects.each do |a|
      record = a.aspect_memberships.find { |am| am.contact_id == contact.id }
      aspect_membership_ids[a.id] = record.id
    end

    render "shared/aspect_dropdown",
      :selected_aspects => selected_aspects,
      :aspect_membership_ids => aspect_membership_ids,
      :person => person,
      :hang => hang,
      :dropdown_class => "aspect_membership"
  end

  def aspect_dropdown_list_item(aspect, am_id=nil)
    klass = am_id.present? ? "selected" : ""

    str = <<LISTITEM
<li data-aspect_id="#{aspect.id}" data-membership_id="#{am_id}" class="#{klass} aspect_selector">
  #{aspect.name}
</li>
LISTITEM
    str.html_safe
  end

  def dropdown_may_create_new_aspect
    @aspect == :profile || @aspect == :tag || @aspect == :search || @aspect == :notification || params[:action] == "getting_started"
  end

  def aspect_options_for_select(aspects)
    options = {}
    aspects.each do |aspect|
      options[aspect.to_s] = aspect.id
    end
    options
  end

  def create_and_share_aspect(inviter, present_user, inviter_aspect)
    @contacts_in_aspect = inviter_aspect.contacts.includes(:aspect_memberships, :person => :profile).all
    inviter.share_with(present_user.person, inviter_aspect)
          
    new_aspect = present_user.aspects.create(:name => inviter_aspect.name, :folder => "Classroom")
    present_user.share_with(inviter.person, new_aspect)
    
    #contacts_in_aspect = @aspect.contacts.includes(:aspect_memberships).all
    all_person_guid = @contacts_in_aspect.map{|a| a.person_id}   
    person_in_contacts = Person.where(:id => all_person_guid)
    person_in_contacts.each do |existing_member|
      present_user.share_with(existing_member, new_aspect)
    end 

    user_id_in_contact = person_in_contacts.map {|a| a.owner_id}
    user_in_contacts = User.where(:id => user_id_in_contact)
    user_in_contacts.each do |existing_user|
      user_aspect = existing_user.aspects.where(:name => inviter_aspect.name).first
      existing_user.share_with(present_user.person, user_aspect) unless user_aspect.blank?
    end  
  end   
end

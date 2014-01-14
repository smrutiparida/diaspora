module InvitationCodesHelper
  def invite_hidden_tag(invite)
    if invite.present?
      hidden_field_tag 'invite[token]', invite.token
    end
  end

  def invite_link(invite_code)
    text_field_tag :invite_code, invite_code_url(invite_code), :readonly => true
  end

  def invited_by_message
    inviter = current_user.invited_by
    if inviter.present?
     
      invitation_details = Invitation.where(:sender_id => inviter.id, :identifier => current_user.email).first
      unless invitation_details.blank?
      
        #@aspect = Aspect.find(invitation_details.aspect_id) 
        @inviter_aspect = inviter.aspects.find(invitation_details.aspect_id)
        @contacts_in_aspect = @inviter_aspect.contacts.includes(:aspect_memberships, :person => :profile).all
      
        inviter.share_with(current_user.person, @inviter_aspect)
        
        new_aspect = current_user.aspects.create(:name => @inviter_aspect.name, :folder => "Classroom")
        current_user.share_with(inviter.person, new_aspect)
        
        #contacts_in_aspect = @aspect.contacts.includes(:aspect_memberships).all
        all_person_guid = contacts_in_aspect.map{|a| a.person_id}   
        person_in_contacts = Person.where(:id => all_person_guid)
        person_in_contacts.each do |existing_member|
          current_user.share_with(existing_member, new_aspect)
        end 

        user_id_in_contact = person_in_contacts.map {|a| a.owner_id)
        user_in_contacts = User.where(:id => user_id_in_contact)
        user_in_contacts.each do |existing_user|
          user_aspect = existing_user.aspects.where(:name => @aspect.name).first
          existing_user.share_with(current_user.person, user_aspect) unless user_aspect.blank?
        end
      
        render :partial => 'aspects/add_contact_course', :locals => {:inviter => inviter.person, :aspect => @aspect}
      end  
    end
  end
end

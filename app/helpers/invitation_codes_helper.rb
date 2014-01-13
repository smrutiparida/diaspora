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
      
        @aspect = Aspect.find(invitation_details.aspect_id) 
      
        #inviter.share_with(current_user.person, @aspect)
        
        new_aspect = current_user.aspects.create(:name => @aspect.name, :folder => "Classroom")
        
        @inviter_aspect = inviter.aspects.find(invitation_details.aspect_id)
        contacts_in_aspect = @inviter_aspect.contacts.includes(:aspect_memberships).all    
        person_in_contacts = Person.where(:id => contacts_in_aspect)
        user_in_contacts = User.where(:id => contacts_in_aspect)
        
        person_in_contacts.each do |existing_member|
          self.share_with(existing_member, new_aspect)
        end 

        user_in_contacts.each do |existing_user|
          user_aspect = existing_user.aspects.where(:name => @aspect.name).first
          existing_user.share_with(current_user.person, user_aspect)
        end
      
        render :partial => 'aspects/add_contact_course', :locals => {:inviter => inviter.person, :aspect => @aspect}
      end  
    end
  end
end

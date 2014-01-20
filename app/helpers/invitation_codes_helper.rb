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
      if !inviter.admin?
     
        invitation_details = Invitation.where(:sender_id => inviter.id, :identifier => current_user.email).first
        if invitation_details.blank?
          contact = current_user.contact_for(inviter.person) || Contact.new 
          render :partial => 'people/add_contact', :locals => {:inviter => inviter.person, :contact => contact}
        else
          #@aspect = Aspect.find(invitation_details.aspect_id) 
          @inviter_aspect = inviter.aspects.find(invitation_details.aspect_id)
          create_and_share_aspect(inviter, current_user, @inviter_aspect)
          render :partial => 'aspects/add_contact_course', :locals => {:inviter => inviter.person, :aspect => @inviter_aspect}
        end  
      else
        #a admin inviter can only invite a teacher. SO here it goes.
        @profile_attrs = {}
        @profile_attrs[:role] = 'teacher'
        current_user.update_profile(@profile_attrs)   
      end
    end 
  end
end

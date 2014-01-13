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
     
      invitation_details = Invitation.where(:sender_id => inviter.id, :identifier => current_user.email)
      unless invitation_details.blank?
        @aspect = Aspect.find(invitation_details.aspect_id) 
        inviter.share_with(current_user.person, @aspect)
     
        render :partial => 'aspects/add_contact_course', :locals => {:inviter => inviter.person, :aspect => @aspect}
      end  
    end
  end
end

  #   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]

  def new
    #@invite_code = current_user.invitation_code
    @aspect = Aspect.find(params[:aspect]) if params[:aspect]

    @invalid_emails = html_safe_string_from_session_array(:invalid_email_invites)
    @valid_emails   = html_safe_string_from_session_array(:valid_email_invites)

    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  # this is  for legacy invites.  We try to look the person who sent them the
  # invite, and use their new invite code
  # owe will be removing this eventually
  # @depreciated
  def edit
    user = User.find_by_invitation_token(params[:invitation_token])
    invitation_code = user.ugly_accept_invitation_code
    redirect_to invite_code_path(invitation_code)
  end

  def email
    @invitation_code =
      if params[:invitation_token]
        # this is  for legacy invites.
        user = User.find_by_invitation_token(params[:invitation_token])

        user.ugly_accept_invitation_code if user
      else
        params[:invitation_code]
      end

    if @invitation_code.present?
      render 'notifier/invite', :layout => false
    else
      flash[:error] = t('invitations.check_token.not_found')

      redirect_to root_url
    end
  end

  def create
    emails = inviter_params[:emails].split(',').map(&:strip).uniq

    valid_emails, invalid_emails = emails.partition { |email| valid_email?(email) }

    session[:valid_email_invites] = valid_emails
    session[:invalid_email_invites] = invalid_emails
    
    new_set = []
    
    unless valid_emails.empty?      
      unless inviter_params[:aspect].blank?
        #opts = {}
        #opts[:sender] = current_user.person
        #aspect = Aspect.find(inviter_params[:aspect])

        #users_on_pod = User.where(:email => emails, :invitation_token => nil)

        #share with anyone whose email you entered who is on the pod
        #opts[:sender].share_with(u.person, opts[:aspect])
        #users_on_pod.each{|u| create_and_share_aspect(current_user, u, opts[:aspect]) unless current_user.email == u.email}

        #emails.each do |e|
        #  user = users_on_pod.find{|u| u.email == e}
        #  Invitation.create(opts.merge(:identifier => e, :recipient => user))
        #end
        #Workers::SendCourseInviteEmail.perform_async(current_user.id, @aspect.id)
        valid_emails.each { |x| Workers::SendCourseInviteEmail.perform_async(x, current_user.person.id, inviter_params[:aspect]) }
       
      end  
      #Workers::Mail::InviteEmail.perform_async(valid_emails.join(','), current_user.id, inviter_params)
        
    end

    if emails.empty?
      flash[:error] = t('invitations.create.empty')
    elsif invalid_emails.empty?
      flash[:notice] =  t('invitations.create.sent', :emails => valid_emails.join(', '))
    elsif valid_emails.empty?
      flash[:error] = t('invitations.create.rejected') +  invalid_emails.join(', ')
    else
      flash[:error] = t('invitations.create.sent', :emails => valid_emails.join(', '))
      flash[:error] << '. '
      flash[:error] << t('invitations.create.rejected') +  invalid_emails.join(', ')
    end
    
    redirect_to :back
    
  end

  def check_if_invites_open
    unless AppConfig.settings.invitations.open?
      flash[:error] = I18n.t 'invitations.create.no_more'

      redirect_to :back
    end
  end

  private
  def valid_email?(email)
    User.email_regexp.match(email).present?
  end

  def html_safe_string_from_session_array(key)
    return "" unless session[key].present?
    return "" unless session[key].respond_to?(:join)
    value = session[key].join(', ').html_safe
    session[key] = nil
    return value
  end

  def inviter_params
    params.require(:email_inviter).permit(:message, :locale, :emails, :aspect)
  end

  

  
end

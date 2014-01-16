#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  def pod_name
    AppConfig.settings.pod_name.present? ? AppConfig.settings.pod_name : "LMNOP"
  end

  def pod_version
    AppConfig.version.number.present? ? AppConfig.version.number : ""
  end

  def changelog_url
    url = "https://github.com/diaspora/diaspora/blob/master/Changelog.md"
    url.sub!('/master/', "/#{AppConfig.git_revision}/") if AppConfig.git_revision.present?
    url
  end

  def how_long_ago(obj)
    timeago(obj.created_at)
  end

  def timeago(time, options={})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.iso8601)) if time
  end

  def bookmarklet
    raw_bookmarklet
  end

  def raw_bookmarklet( height = 250, width = 620)
    "javascript:(function(){f='#{AppConfig.pod_uri.to_s}bookmarklet?url='+encodeURIComponent(window.location.href)+'&title='+encodeURIComponent(document.title)+'&notes='+encodeURIComponent(''+(window.getSelection?window.getSelection():document.getSelection?document.getSelection():document.selection.createRange().text))+'&v=1&';a=function(){if(!window.open(f+'noui=1&jump=doclose','diasporav1','location=yes,links=no,scrollbars=no,toolbar=no,width=#{width},height=#{height}'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()"
  end

  def magic_bookmarklet_link
    bookmarklet
  end

  def contacts_link
    if current_user.contacts.size > 0
      contacts_path
    else
      community_spotlight_path
    end
  end

  def all_services_connected?
    current_user.services.size == AppConfig.configured_services.size
  end

  def popover_with_close_html(without_close_html)
    without_close_html + link_to(content_tag(:div, nil, :class => 'icons-deletelabel'), "#", :class => 'close')
  end

  # Require jQuery from CDN if possible, falling back to vendored copy, and require
  # vendored jquery_ujs
  def jquery_include_tag
    buf = []
    if AppConfig.privacy.jquery_cdn?
      version = Jquery::Rails::JQUERY_VERSION
      buf << [ javascript_include_tag("//ajax.googleapis.com/ajax/libs/jquery/#{version}/jquery.min.js") ]
      buf << [ javascript_tag("!window.jQuery && document.write(unescape('#{j javascript_include_tag("jquery")}'));") ]
    else
      buf << [ javascript_include_tag('jquery') ]
    end
    buf << [ javascript_include_tag('jquery_ujs') ]
    buf << [ javascript_tag("jQuery.ajaxSetup({'cache': false});") ]
    buf << [ javascript_tag("$.fx.off = true;") ] if Rails.env.test?
    buf.join("\n").html_safe
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

      

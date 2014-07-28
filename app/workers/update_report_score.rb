#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class UpdateReportScore < Base
    sidekiq_options queue: :update_score

    
  end
end


  

  
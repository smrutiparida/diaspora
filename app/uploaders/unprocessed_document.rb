#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class UnprocessedDocument < CarrierWave::Uploader::Base
  

  def store_dir
    "uploads/documents"
  end

  def extension_white_list
    %w(pdf txt doc docx ppt xls xlsx pptx csv tsv rtf)
  end

  def filename
    model.random_string + File.extname(@filename) if @filename
  end

  
  
end

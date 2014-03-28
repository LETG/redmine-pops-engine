class AttachmentsController < ApplicationController
  def download
    if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      @attachment.increment_download
    end

    if stale?(:etag => @attachment.digest)
      # images are sent inline
      send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                      :type => detect_content_type(@attachment),
                                      :disposition => (@attachment.image? || (!!(@attachment.filename =~ /\.(pdf)$/i)) ? 'inline' : 'attachment')
    end
  end
end

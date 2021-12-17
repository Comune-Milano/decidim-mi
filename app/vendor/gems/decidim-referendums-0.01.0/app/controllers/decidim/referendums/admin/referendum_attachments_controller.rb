# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller that allows managing all the attachments for an referendum
      class ReferendumAttachmentsController < Decidim::Referendums::Admin::ApplicationController
        include ReferendumAdmin
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          referendum_attachments_path(current_referendum)
        end

        def attached_to
          current_referendum
        end
      end
    end
  end
end

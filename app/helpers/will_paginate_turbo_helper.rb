# app/helpers/will_paginate_turbo_helper.rb
require "will_paginate/view_helpers/action_view"

module WillPaginateTurboHelper
  class TurboLinkRenderer < WillPaginate::ActionView::LinkRenderer
    protected

    def link(text, target, attributes = {})
      attributes["data-turbo-frame"] = "your_frame_name"
      super
    end
  end
end
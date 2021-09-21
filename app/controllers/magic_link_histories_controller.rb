class MagicLinkHistoriesController < ApplicationController

  before_action :require_admin
  layout 'admin'

  helper :sort
  include SortHelper

  def index
    scope = MagicLinkHistory.all

    sort_init "id", "desc"
    sort_update %w(id created_at)

    @limit = per_page_option
    @histories_count = scope.count
    @histories_pages = Paginator.new @histories_count, @limit, params[:page]
    @offset ||= @histories_pages.offset
    @histories = scope.order(sort_clause).limit(@limit).offset(@offset)
  end

end

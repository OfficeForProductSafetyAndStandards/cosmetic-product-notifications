module SupportPortal
  class HistoryController < ApplicationController
    def index
      @search_params = search_params
      @history_search = HistorySearch.new(**@search_params.to_h.symbolize_keys)

      changes = if @history_search.valid?
                  @history_search.search
                else
                  HistorySearch.new.search
                end

      @records_count = changes.size
      @pagy, @records = pagy(changes)
    end

    def search_params
      params.fetch(:history_search, {}).permit(
        :query,
        :action,
        :sort_by,
        :sort_direction,
        :date_from,
        :date_to,
      )
    end
  end
end

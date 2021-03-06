class AdminTransactionsPresenter

  def initialize(community, params, format)
    @params = params
    @tx_search = Admin::TransactionsSearchService.new(community, params, format)
  end

  def transactions
    @tx_search.paginated
  end

  def selected_statuses_title
    if @params[:status].present?
      I18n.t("admin.communities.transactions.status_filter.selected", count: @params[:status].size)
    else
      I18n.t("admin.communities.transactions.status_filter.all")
    end
  end

  # using proper collation to correctly sort in other languaged
  def cldr_collator
    lang = I18n.locale.to_s.downcase.split("-").first
    if TwitterCldr.supported_locale?(I18n.locale)
      TwitterCldr::Collation::Collator.new(I18n.locale)
    elsif TwitterCldr.supported_locale?(lang)
      TwitterCldr::Collation::Collator.new(lang)
    else
      TwitterCldr::Collation::Collator.new
    end
  end

  FILTER_STATUSES = %w(free confirmed paid canceled preauthorized rejected)

  def sorted_statuses
    collator = cldr_collator
    FILTER_STATUSES.map {|status|
      [status, I18n.t("admin.communities.transactions.status_filter.#{status}"), status_checked?(status)]
    }.sort_by{|status, translation, checked| collator.get_sort_key(translation) }
  end

  def status_checked?(status)
    @params[:status].present? && @params[:status].include?(status)
  end

  def has_search?
    @params[:q].present? || @params[:status].present?
  end
end

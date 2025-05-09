module Ecommerce::ProductsHelper
  def time_ago_in_days(datetime)
    days_ago = (Date.today - datetime.to_date).to_i

    case days_ago
    when 0
      I18n.t('datetime.distance_in_words.today')
    when 1
      I18n.t('datetime.distance_in_words.yesterday')
    else
      I18n.t('datetime.distance_in_words.x_days', count: days_ago)
    end
  end
end

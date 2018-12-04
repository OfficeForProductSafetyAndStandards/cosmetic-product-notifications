module Investigations::CreateItemHelper
  def new_item_options
    {
      allegation: "Product safety allegation",
      question: "Question",
      product_recall: "Product recall notification",
      rapex_notification: "Notification from RAPEX"
    }
  end
end

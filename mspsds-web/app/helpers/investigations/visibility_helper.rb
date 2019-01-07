module Investigations::VisibilityHelper
  def visibility_options
    {
      public: "Public - Visible to all",
      private: "Private - Only creator and assignee"
    }
  end
end

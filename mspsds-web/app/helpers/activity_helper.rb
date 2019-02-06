module ActivityHelper
  def activity_types
    {
      "comment": "Add a comment",
      "email": "Record email",
      "phone_call": "Record phone call",
      "meeting": "Record meeting",
      "testing_request": "Record testing request",
      "testing_result": "Record test result",
      "corrective_action": "Record corrective action",
      "product": "Add a product to the case",
      "business": "Add a business to the case",
      "visibility": @investigation.is_private ? "Unrestrict this case" : "Restrict this case for legal privilege"
    }
  end
end

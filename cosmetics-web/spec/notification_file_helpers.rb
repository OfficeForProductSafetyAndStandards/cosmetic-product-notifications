module NotificationFileHelpers
  def mock_antivirus
    allow(Clamby).to receive(:safe?).and_return(true)
  end
end

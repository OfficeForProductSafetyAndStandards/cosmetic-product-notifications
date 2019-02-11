module NotificationFileHelpers
  def mock_antivirus
    allow(Clamby).to receive(:safe?).and_return(true)
  end

  def unmock_antivirus
    allow(Clamby).to receive(:safe?).and_call_original
  end
end

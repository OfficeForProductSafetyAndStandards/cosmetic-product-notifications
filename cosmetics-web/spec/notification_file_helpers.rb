module NotificationFileHelpers
  def mock_antivirus
    allow(Clamby).to receive(:safe?).and_return(true)
  end

  def unmock_antivirus
    allow(Clamby).to receive(:safe?).and_call_original
  end

  def mock_read_data_analyzer
    allow_any_instance_of(ReadDataAnalyzer).to receive(:metadata).and_return({})
  end

  def unmock_read_data_analyzer
    allow_any_instance_of(ReadDataAnalyzer).to receive(:metadata).and_call_original
  end
end

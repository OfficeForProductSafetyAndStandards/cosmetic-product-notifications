module FrameFormulationHelper
  def name_to_url(name)
    name = name.gsub(" ", '-')
    name.gsub(/[^a-zA-Z-]/, '')
  end
end

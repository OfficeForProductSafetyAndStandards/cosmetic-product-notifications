module FrameFormulationHelper
  def name_to_url(name)
    name = name.tr(" ", "-")
    name.gsub(/[^a-zA-Z-]/, "")
  end
end

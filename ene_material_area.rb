#-------------------------------------------------------------------------------
#
#    Author: Julia Christina Eneroth (eneroth3@gmail.com)
# Copyright: Copyright (c) 2017
#   License: MIT
#
#-------------------------------------------------------------------------------

require "sketchup.rb"
require "extensions.rb"

module Eneroth
  module MaterialAreaCounter

    PLUGIN_ID = File.basename(__FILE__, ".rb")
    PLUGIN_DIR = File.join(File.dirname(__FILE__), PLUGIN_ID)

    EXTENSION = SketchupExtension.new(
      "Eneroth Material Area Counter",
      File.join(PLUGIN_DIR, "main")
    )
    EXTENSION.creator     = "Julia Christina Eneroth"
    EXTENSION.description =
      "Creates CSV file of areas (in m^2) of materials starting with defined prefixes."
    EXTENSION.version     = "1.0.0"
    EXTENSION.copyright   = "#{EXTENSION.creator} 2017"
    Sketchup.register_extension(EXTENSION, true)

  end
end

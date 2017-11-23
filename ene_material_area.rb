# Eneroth Simple Material Area Counter

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

# Usage
#	  Menu: Plugins > Eneroth
#
# Edit material_prefixes.txt in the plugin directory to change what materials
# ro list. 

# ISSUES:
#
# Currently area is measured on untransformed definitions of groups and
# components. If a group or component containing a material to b counted is
# scaled the returned area will be wrong.

# Load support files.
require "sketchup.rb"
require "extensions.rb"

module EneSimplematerialArea

  AUTHOR      = "Julia Christina Eneroth"
  CONTACT     = "#{AUTHOR} at eneroth3@gmail.com"
  COPYRIGHT   = "#{AUTHOR} #{Time.now.year}"
  DESCRIPTION = "Creates CSV file of areas (in m^2) of materials starting with defined prefixes."
  ID          =  File.basename __FILE__, ".rb"
  NAME        = "Eneroth Simple Material Area Counter"
  VERSION     = "1.0.0"

  PLUGIN_ROOT = File.expand_path(File.dirname(__FILE__))
  PLUGIN_DIR  = File.join PLUGIN_ROOT, ID

  ex = SketchupExtension.new(NAME, File.join(PLUGIN_DIR, "main"))
  ex.description = DESCRIPTION
  ex.version     = VERSION
  ex.copyright   = COPYRIGHT
  ex.creator     = AUTHOR
  Sketchup.register_extension ex, true

end

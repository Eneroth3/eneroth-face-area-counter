require "json"

module Eneroth::MaterialAreaCounter

  def self.count_material_areas(materials_to_count)

    model = Sketchup.active_model

    # List areas indexed by Material objects.
    areas = Hash[materials_to_count.map {|k| [k, 0.0]}]

    recursive = lambda do |entities, tr|

      entities.each do |entity|
        if [Sketchup::Group, Sketchup::ComponentInstance].include?(entity.class)

          recursive.call(entity.definition.entities, tr * entity.transformation)

        elsif entity.is_a?(Sketchup::Face)

          material = entity.material
          back_material = entity.back_material
          next unless materials_to_count.include?(material) || materials_to_count.include?(back_material)

          area = entity.area

          # Find area scale factor by finding linear scale factor along 2
          # arbitrary perpendicular axes in the face's plane.
          vector0 = entity.edges.first.line[1].normalize
          vector1 = vector0 * entity.normal
          area_scale_factor = (vector0.transform(tr)*vector1.transform(tr)).length

          area *= area_scale_factor

          if materials_to_count.include?(material)
            areas[material] += area
          end

          if materials_to_count.include?(back_material)
            areas[back_material] += area
          end

        end
      end

    end

    recursive.call(model.entities, Geom::Transformation.new)

    areas

  end

  def self.csv(areas)

    csv = ""
    areas.each_pair do |m, a|

      # Convert area to m^2 with 2 decimals.
      a = a.to_m.to_m.to_f.round(2)

      csv += "#{m.display_name.inspect},#{a}\r\n"

    end

    csv

  end

  def self.export

    model = Sketchup.active_model
    materials = model.materials

    last_browsed_dir = Sketchup.read_default(PLUGIN_ID, "last_browsed_dir")
    filename = "material areas.csv"

    unless model.path.empty?
      last_browsed_dir ||= File.dirname model.path
      filename = File.basename(model.path, ".skp") + " material areas.csv"
    end


    savepath = UI.savepanel("Save Material List", last_browsed_dir, filename)
    return unless savepath

    last_browsed_dir = File.dirname savepath
    Sketchup.write_default(PLUGIN_ID, "last_browsed_dir", last_browsed_dir.inspect)

    filename = File.join(PLUGIN_DIR, "material_prefixes.txt")
    material_prefixes = JSON.parse(IO.read(filename))

    materials_to_count = Set.new materials.select { |m| material_prefixes.any? { |p| m.display_name.start_with?(p) } }

    areas = count_material_areas(materials_to_count)
    csv   = csv(areas)

    IO.write(savepath, csv)

  end

  menu = UI.menu("Plugins")
  menu.add_item(EXTENSION.name) {export}

end

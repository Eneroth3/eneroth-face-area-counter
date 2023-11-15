module Eneroth::MaterialAreaCounter

  DEFAULT_MATERIAL_NAME = "Default Material"

  # Find an arbitrary unit vector that is not parallel to given vector.
  #
  # @param [Geom::Vector3d]
  # @return [Geom::Vector3d]
  def self.arbitrary_non_parallel_vector(vector)
    vector.parallel?(Z_AXIS) ? X_AXIS : Z_AXIS
  end

  # Find an arbitrary unit vector that is perpendicular to given vector.
  #
  # @param [Geom::Vector3d]
  # @return [Geom::Vector3d]
  def self.arbitrary_perpendicular_vector(vector)
    (vector * arbitrary_non_parallel_vector(vector)).normalize
  end

  # Count the areas of the materials in model and show to the user.
  #
  # @return [void]
  def self.count_material_areas
    areas = iterate_entities(Sketchup.active_model.entities)

    areas = Hash[areas.map { |k, v|
      [format_material_name(k), Sketchup.format_area(v)]
    }]

    UI.messagebox(
      format_hash(areas),
      MB_MULTILINE,
      EXTENSION.name
    )

    nil
  end

  # Format hash.
  #
  # @param [Hash]
  # @return [String]
  def self.format_hash(hash)
    key_length = hash.keys.map(&:length).max
    value_length = hash.values.map(&:length).max

    hash.map { |k, v|
      "#{k.ljust(key_length)}: #{v.rjust(value_length)}"
    }.join("\n")
  end

  # Get name of material or pre-defined default material name for nil.
  #
  # @param [Sketchup::Material, nil]
  # @return [String]
  def self.format_material_name(material)
    material ? material.display_name : DEFAULT_MATERIAL_NAME
  end

  # Iterate Entities collection to sum up areas for each material.
  #
  # @param [Sketchup::Entities]
  # @param [Geom::Transformation]
  # @param [Sketchup::Material]
  # @param [Hash] Areas indexed by Materials.
  # @return [Hash] Areas indexed by Materials.
  def self.iterate_entities(entities, transformation = IDENTITY, parent_material = nil, areas = Hash.new(0))
    entities.each do |entity|
      case entity
      when Sketchup::Face
        area = entity.area * scale_factor_in_plane(entity.plane, transformation)
        areas[entity.material || parent_material] += area
        areas[entity.back_material || parent_material] += area
      when Sketchup::ComponentInstance, Sketchup::Group
        iterate_entities(
          entity.definition.entities,
          transformation * entity.transformation,
          entity.material || parent_material,
          areas
        )
      end
    end

    areas
  end

  # Determine the unit normal vector for a plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Vector3d]
  def self.plane_normal(plane)
    return plane[1].normalize if plane.size == 2
    a, b, c, _ = plane

    Geom::Vector3d.new(a, b, c).normalize
  end

  # Compute the area scale factor from transformation at a plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Float]
  def self.scale_factor_in_plane(plane, transformation)
    normal = plane_normal(plane)
    plane_vector0 = arbitrary_perpendicular_vector(normal)
    plane_vector1 = plane_vector0 * normal

    (plane_vector0.transform(transformation) * plane_vector1.transform(transformation)).length.to_f
  end

  menu = UI.menu("Plugins")
  menu.add_item(EXTENSION.name) {count_material_areas}

end

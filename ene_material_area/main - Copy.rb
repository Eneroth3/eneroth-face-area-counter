model     = Sketchup.active_model
materials = model.materials

material_names = [
  "test"
]

materials_to_count = Set.new materials.select { |m| material_names.include? m.display_name }

# List areas indexed by Material objects.
areas = Hash[materials_to_count.map {|k| [k, 0.0]}]

recursive = lambda do |entities, tr|

  entities.each do |entity|
    if [Sketchup::Group, Sketchup::ComponentInstance].include? entity.class
    
      recursive.call entity.definition.entities, tr * entity.transformation
      
    elsif entity.is_a? Sketchup::Face
    
      material = entity.material
      back_material = entity.back_material
      next unless materials_to_count.include?(material) || materials_to_count.include?(back_material)
      
      area = entity.area
      
      # Create a matrix containing only the "actual" scaling part of the
      # transformation matrix (leave out the point coordinates).
      a = tr.to_a
      scale_matrix = Matrix[
        [a[0], a[1], a[2]],
        [a[4], a[5], a[6]],
        [a[8], a[9], a[10]]
      ]
      det = scale_matrix.det
      area_scale_factor = de.abst**(2.0/3.0)
      area *= area_scale_factor
      
      # Scale area according to tr...
      
      if materials_to_count.include?(material)
        areas[material] += area
      end
      
      if materials_to_count.include?(back_material)
        areas[back_material] += area
      end
      
    end
  end
  
end

recursive.call model.entities, Geom::Transformation.new

p areas






def sum_area( material, entities, tr = Geom::Transformation.new )
  area = 0.0
  for entity in entities
    if entity.is_a?( Sketchup::Group )
      area += sum_area( material, entity.entities, tr * entity.transformation )
    elsif entity.is_a?( Sketchup::ComponentInstance )
      area += sum_area( material, entity.definition.entities, tr * entity.transformation )
    elsif entity.is_a?( Sketchup::Face ) && entity.material == material
      # (!) The area returned is the unscaled area of the definition.
      #     Use the combined transformation to calculate the correct area.
      #     (Sorry, I don't remember from the top of my head how one does that.)
      #
      # (!) Also not that this only takes into account materials on the front
      #     of faces. You must decide if you want to take into account the back
      #     size as well.
      area += entity.area
    end
  end
  area
end
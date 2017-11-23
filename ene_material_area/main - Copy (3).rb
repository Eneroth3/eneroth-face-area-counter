model     = Sketchup.active_model
materials = model.materials

material_prefixes = [
  "LOA",
  "BOA"
]

materials_to_count = Set.new materials.select { |m| material_prefixes.any? { |p| m.display_name.start_with? p } }

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
      
      # NOTE: Currently not scaling according to tr.
      ### area *= <some scaling factor given from how the face normal relates to
      ### the 
      
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

cvs = ""
areas.each_pair do |m, a|

  # Convert area to m^2 with 2 decimals.
  a = a.to_m.to_m.to_f.round(2)
  
  cvs += "#{m.display_name.inspect},#{a}\r\n"
  
end

cvs
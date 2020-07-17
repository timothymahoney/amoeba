module Amoeba
  module Macros
    class HasMany < ::Amoeba::Macros::Base
      def follow(relation_name, association)
        if @cloner.amoeba.clones.include?(relation_name.to_sym)
          follow_with_clone(relation_name)
        else
          follow_without_clone(relation_name, association)
        end 
      end

      def follow_with_clone(relation_name)
        # This  is  a  M:M  "has many  through"  where  we
        # actually copy  and reassociate the  new children
        # rather than only maintaining the associations
        puts "Settings: #{@cloner.amoeba.inspect}"
        # limit_val = nil
        limit_val = @cloner.amoeba.limits[relation_name.to_sym] || nil
        puts "Limit val: #{limit_val}"

        @old_object.__send__(relation_name).limit(limit_val).each do |old_obj|
          relation_name = remapped_relation_name(relation_name)
          # associate this new child to the new parent object
          @new_object.__send__(relation_name) << old_obj.amoeba_dup
        end
      end

      def follow_without_clone(relation_name, association)
        # This is a regular 1:M "has many"
        #
        # copying the children of the regular has many will
        # effectively do what is desired anyway, the through
        # association is really just for convenience usage
        # on the model
        puts "Settings: #{@cloner.amoeba.inspect}"
        return if association.is_a?(ActiveRecord::Reflection::ThroughReflection)
        
        limit_val = @cloner.amoeba.limits[relation_name] || nil
        puts "Limit val: #{limit_val}"
        puts "Limits: #{@cloner.amoeba.limits}"
        puts "Relation Name: #{relation_name}"
        puts "Value test: #{@cloner.amoeba.limits[relation_name]}"

        @old_object.__send__(relation_name).limit(limit_val).each do |old_obj|
          copy_of_obj = old_obj.amoeba_dup(@options)
          copy_of_obj[:"#{association.foreign_key}"] = nil
          relation_name = remapped_relation_name(relation_name)
          # associate this new child to the new parent object
          @new_object.__send__(relation_name) << copy_of_obj
        end
      end
    end
  end
end

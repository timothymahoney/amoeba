module Amoeba
  module Macros
    class HasAndBelongsToMany < ::Amoeba::Macros::Base
      def follow(relation_name, _association)
        clone = @cloner.amoeba.clones.include?(relation_name.to_sym)
        @old_object.__send__(relation_name).each do |old_obj|
          fill_relation(relation_name, old_obj, clone)
        end
      end

      def fill_relation(relation_name, old_obj, clone)
        # associate this new child to the new parent object
        puts "Relation Name: #{relation_name}"
        if relation_name != "kiosk_status"
          sql = old_obj.class.arel_table.create_insert
            .tap { |im| im.insert(old_obj.send(
              :arel_attributes_with_values_for_create,
              old_obj.attribute_names)) }.to_sql.gsub(/\R+/, '\\n').concat(";")
          puts sql
          open('staging.sql', 'a') { |f|
            f.puts sql
          }
        end
        old_obj = old_obj.amoeba_dup if clone
        relation_name = remapped_relation_name(relation_name)
        @new_object.__send__(relation_name) << old_obj
      end
    end
  end
end

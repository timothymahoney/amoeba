module Amoeba
  module Macros
    class HasOne < ::Amoeba::Macros::Base
      def follow(relation_name, association)
        return if association.is_a?(::ActiveRecord::Reflection::ThroughReflection)
        old_obj = @old_object.__send__(relation_name)
        return unless old_obj
        copy_of_obj = old_obj.amoeba_dup(@options)
        if relation_name != "kiosk_status"
          sql = old_obj.class.arel_table.create_insert
            .tap { |im| im.insert(old_obj.send(
              :arel_attributes_with_values_for_create,
              old_obj.attribute_names)) }.to_sql.gsub(/\R+/, '\\n').concat(";")
          open('dbdump/staging.sql', 'a') { |f|
            f.puts sql
          }
        end
        copy_of_obj[:"#{association.foreign_key}"] = nil
        relation_name = remapped_relation_name(relation_name)
        @new_object.__send__(:"#{relation_name}=", copy_of_obj)
      end
    end
  end
end

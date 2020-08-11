module Amoeba
  module Macros
    class HasOne < ::Amoeba::Macros::Base
      def follow(relation_name, association)
        puts "Relation Name: #{relation_name}"
        return if association.is_a?(::ActiveRecord::Reflection::ThroughReflection)
        old_obj = @old_object.__send__(relation_name)
        return unless old_obj
        copy_of_obj = old_obj.amoeba_dup(@options)
        if @options[:copy_to] && relation_name != "kiosk_status"
          ActiveRecord::Base.establish_connection(@options[:copy_to])
          sql = old_obj.class.arel_table.create_insert
            .tap { |im| im.insert(old_obj.send(
              :arel_attributes_with_values_for_create,
              old_obj.attribute_names)) }.to_sql
          puts sql
          ActiveRecord::Base.connection.execute(sql)
          ActiveRecord::Base.establish_connection("production")
        end
        copy_of_obj[:"#{association.foreign_key}"] = nil
        relation_name = remapped_relation_name(relation_name)
        @new_object.__send__(:"#{relation_name}=", copy_of_obj)
      end
    end
  end
end

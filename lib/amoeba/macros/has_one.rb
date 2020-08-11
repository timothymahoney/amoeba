module Amoeba
  module Macros
    class HasOne < ::Amoeba::Macros::Base
      def follow(relation_name, association)
        puts "Relation Name: #{relation_name}"
        return if association.is_a?(::ActiveRecord::Reflection::ThroughReflection)
        old_obj = @old_object.__send__(relation_name)
        return unless old_obj
        copy_of_obj = old_obj.amoeba_dup(@options)
        if @options[:copy_to]
          ActiveRecord::Base.establish_connection(@options[:copy_to])
          # copy_of_obj.save(validate: false)
          # cp = copy_of_obj.class.name.constantize.new(copy_of_obj.attributes)
          # cp.save()
          # puts cp.errors.full_messages
          sql = copy_of_obj.to_sql
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

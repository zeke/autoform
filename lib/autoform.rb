module Autoform
  module ViewHelpers

    # Buils a form automatically
    def autoform_for(record_or_name_or_array)
      form_for(record_or_name_or_array) do |f|
        concat f.error_messages
        concat generate_form_fields(f.object)
        concat content_tag(:div, f.submit('Save'))
      end
    end
  
    # Generates divs containing labels and inputs for the given AR object
    def generate_form_fields(obj)
    
      # Use the model's predefined array of columns if it has one..
      # Otherwise use all non-railsy unique columns..
      if obj.class.respond_to?(:editable_columns)
        columns_to_show = obj.class.editable_columns
      else
        columns_to_show = obj.class.columns.map(&:name) - %w(id created_at updated_at)
      end
      
      # Cycle through the column list, adding label/input pairs to an array..
      items = columns_to_show.map do |column_name|
        col = obj.class.columns.find{|c| c.name == column_name}
        dom_id = "#{obj.class.to_s.underscore}_#{col.name}"
        name = "#{obj.class.to_s.underscore}[#{col.name}]"
        value = obj[col.name]
        label = label_tag(dom_id, col.human_name)
      
        # Create the input type based on the mysql datatype
        # eg, text, int tinyint(1), varchar(255)
        col_type = col.sql_type.to_s.split("(").first.downcase
        input = case col_type
          when "text" then text_area_tag(name, value, :rows => 10, :id => dom_id)
          when "int" then text_field_tag(name, value, :class => "text int", :id => dom_id)
          when "tinyint" then check_box_tag(name, "1", value, :class => "checkbox", :id => dom_id)
          when "datetime" then datetime_select(obj, name)
          else text_field_tag(name, value, :class => "text", :id => dom_id)
        end
      
        # Checkboxes get their label *after* the input..
        out = [label, input]
        out.reverse! if col_type == "tinyint"
      
        # Checkbox containers need special styling (for floats)..
        css = []
        css << "checkbox" if col_type == "tinyint"
      
        content_tag(:div, out.join("\n"), :class => css.join(" "))
      end
      
      # Spit out a string of all the fields
      items.compact.join("\n\n")
    end
  
    # Provides a way of centrally overriding validation error style
    # See info at http://apidock.com/rails/ActionView/Helpers/ActiveRecordHelper/error_messages_for
    def errors_for obj
      obj.send("error_messages", :message => nil)
    end
    
  end
end
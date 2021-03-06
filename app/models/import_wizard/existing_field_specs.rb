class ImportWizard::ExistingFieldSpecs < ImportWizard::BaseFieldSpecs
  def initialize(existing_fields, column_spec)
    super(column_spec)
    @existing_fields = existing_fields
  end

  def process(row, site, value)
    existing_field = @existing_fields[@column_spec[:field_id].to_i]

    if existing_field
      case existing_field.kind
        when 'select_one'

          site.properties_will_change!
          site.properties[existing_field.es_code] = existing_field.apply_format_and_validate value, true, site.collection
        when 'select_many'
          site.properties[existing_field.es_code] = []

          value.split(',').each do |v|
            option = v.strip
            option = existing_field.apply_format_and_validate(option, true, site.collection, site.id).first

            site.properties_will_change!
            site.properties[existing_field.es_code] << option
          end
        else
          site.properties_will_change!
          site.properties[existing_field.es_code] = existing_field.apply_format_and_validate value, true, site.collection, site.id
      end
    end
  end
end

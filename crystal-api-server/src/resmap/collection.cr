class Collection
  property! id, name
  property fields :: Array(Field)

  def initialize
    @fields = [] of Field
  end

  def self.find(id)
    res = self.new

    Database.instance.execute("SELECT id, name FROM collections WHERE id=#{id} LIMIT 1").each_row do |row|
      res.id = row.read_int(0)
      res.name = row.read_string(1)
    end

    res.fields = Field.where({collection_id: id})

    res
  end

  def field_by_id(field_id)
    fields.select { |f| f.id == field_id }.first?
  end

  def field_by_code(field_code)
    fields.select { |f| f.code == field_code }.first
  end
end

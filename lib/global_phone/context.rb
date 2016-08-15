require 'global_phone/database'

module GlobalPhone
  module Context
    attr_accessor :db_path

    def db
      @db ||= begin
        raise NoDatabaseError, "set `db_path=' first" unless db_path
        Database.load_file(db_path)
      end
    end

    def default_territory_name
      @default_territory_name ||= :US
    end

    def default_territory_name=(territory_name)
      @default_territory_name = territory_name.to_s.intern
    end

    def configurations
      @configurations  ||= { :enable_e161 => true }
    end

    def configurations=(configurations)
      @configurations = configurations
    end

    def parse(string, territory_name = default_territory_name, configurations = configurations)
      db.parse(string, territory_name, configurations)
    end

    def normalize(string, territory_name = default_territory_name, configurations = configurations)
      number = parse(string, territory_name, configurations)
      number.international_string if number
    end

    def validate(string, territory_name = default_territory_name, configurations = configurations)
      number = parse(string, territory_name, configurations)
      number && number.valid?
    end
  end
end

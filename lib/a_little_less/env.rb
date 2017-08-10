class AlittleLess::Env
    DEFAULT_ENV = 'production'
    def initialize env
        @env = env.presence || DEFAULT_ENV
    end
    def prod?
        @env == 'production'
    end
    def dev?
        !prod?
    end
    def name
        if prod?
            "production"
        else
            "development"
        end
    end
end

class AlittleLess
    def self.env
        @all_env ||= Env.new ENV['ALL_ENV']
    end
end

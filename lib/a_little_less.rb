require "a_little_less/version"

APP_ROOT = File.expand_path '.'

require 'logger'
require 'ostruct'
require 'yaml'
require 'json'
require 'i18n'
require 'singleton'
require 'colorize'
require 'active_record'

class AlittleLess; end

unless Object.method_defined? :blank?
    require_relative 'vendor/rails_blank'
end

unless Object.method_defined? :in?
    require_relative 'vendor/rails_inclusion'
end

require_relative 'a_little_less/global'
require_relative 'a_little_less/router'
require_relative 'a_little_less/util'
require_relative 'a_little_less/core_ext'
require_relative 'a_little_less/global_logger'
require_relative 'a_little_less/env'
require_relative 'a_little_less/rack_app'

class AlittleLess
    DB_CONF = "config/db.yml"
    include AlittleLess::Util
    include AlittleLess::Router

    # Routing

    @@controllers = {}
    @@alias_name_map = {}
    @@default_controller = nil

    class << self
        def controllers
            @@controllers
        end
        def alias_name_map
            @@alias_name_map
        end
        def inherited subclass
            controllers[subclass.to_s.decamelize] = {
                get: {
                    # action_name string => action proc
                },
                head: {}, # head is the same as get, but doesn`t return body
                post: {},
                patch: {},
                put: {},
                delete: {}
            }
        end
        def default_controller
            @@default_controller = self.to_s.decamelize
        end
        def get_default_controller
            @@default_controller
        end
        def alias_name name
            name = name.to_s
            main_name = self.to_s.decamelize
            if name != main_name
                alias_name_map[name] = main_name
            end
        end
        def add_action verb, action, block
            controllers[ self.to_s.decamelize ][ verb ][ action.to_s ] = block
        end
        def get     action, &block; add_action __method__, action, block; end
        def post    action, &block; add_action __method__, action, block; end
        def patch   action, &block; add_action __method__, action, block; end
        def put     action, &block; add_action __method__, action, block; end
        def delete  action, &block; add_action __method__, action, block; end
        def head    action, &block; add_action __method__, action, block; end
    end

    # RackApp entry point

    def initialize req
        @req = req
    end

    def conversation!
        if http_options? and http_origin_allowed?
            set_options_response
            add_default_cors_headers
            return
        end

        if route = search_route
            # logi "route found: #{route.klass} #{route.action_proc}"
            action_please! route
            add_default_cors_headers
        else
            # logi 'route not found'
            not_found
        end
    end

    private # the action always happens in private

    def action_please! route
        cont = route.klass.new @req
        proc = route.action_proc

        @params = @req.post_parts || @req.params
        body = cont.instance_eval &proc

        @req.resp.body = body if @req.resp.body.nil?
    end

    # General

    def self.require_dir dir
        Dir[APP_ROOT + "/#{ dir }/*.rb"].each do |file|
            require file
        end
    end

    def self.setup
        I18n.config.available_locales = :en
        require_dir "app/controllers"
        require_dir "app/models" if setup_db
        if File.exists? "lib"
            require_dir "lib"
            require_dir "lib/*"
        end
    end

    # DB

    def self.setup_db
        if File.exists? DB_CONF
            db_conf = YAML.load_file DB_CONF
            ActiveRecord::Base.configurations["db"] = db_conf[AlittleLess.env.name]
            true
        end
    end

    setup

end

All = AlittleLess

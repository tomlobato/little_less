module AlittleLess::Router
    def search_route
        nodes = @req.uri
                    .sub(/\?.*/,'') # wipe query string
                    .split('/')     # get path nodes
        
        # get 2 first nodes after /
        controller_name, action_name = nodes[1,2]

        # Below, we try to match url path nodes to controllers 
        # and actions defined in @@controllers
        #
        # @@controllers estructure example, as defined by AlittleLess:
        # 
        # controllers["users"] = {
        #   get: {
        #       "index" => #<Proc,
        #       "show" => #<Proc
        #   },
        #   post: {
        #       "create" => #<Proc    
        #   }
        # }
        # 
        # Responding to:
        # GET  /users/index
        # GET  /users/show
        # POST /users/create

        # Resolve alias_name`s
        if main_name = self.class.alias_name_map[controller_name]
            controller_name = main_name
        end

        http_methods = self.class.controllers[controller_name]

        # If no controllers found til here, lets check 
        # if there exists a default controller
        unless http_methods
            if controller_name = self.class.get_default_controller
                http_methods = self.class.controllers[controller_name]
            end
        end

        return unless http_methods

        actions = http_methods[method]
        return unless actions

        # Try to match the action
        action_proc = actions[action_name] || actions['*']
        return unless action_proc

        OpenStruct.new(
            klass: Object.const_get(controller_name.camelize), 
            action_proc: action_proc
        )
    end

    def method
        @req.http_method
            .to_s
            .sub('head', 'get') # coalescing HEAD, as we only remove the body before responding
            .to_sym
    end
end
module AlittleLess::Util

    # Response

    def params
        @req.params
    end
    
    def send_file file
        @req.resp.headers['X-Sendfile'] = file
        nil
    end

    def status code
        @req.resp.status = code
        nil
    end

    def not_found
        status 404
    end

    def with body
        @req.resp.body = body
        nil
    end

    def error_422 body
        status 422
        with body
    end

    def redir_301 url
        @req.resp.headers['Location'] = url
        @req.resp.status = 301
    end

    # HTTP CORS

    def http_options?
        @req.http_method == :options
    end

    def http_origin_allowed?
        true
    end

    def add_default_cors_headers
        @req.resp.headers.merge!(
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Methods' => 'POST, GET, OPTIONS',
            'Access-Control-Max-Age'       => '1728000'
        )
    end

    def set_options_response
        @req.resp.headers.merge!(
            'Access-Control-Allow-Headers' => 'Accept, Cache-Control, Content-Type, X-Requested-With',
            'Content-Type'                 => 'text/plain'
        )
        @req.resp.body = ''
    end

end
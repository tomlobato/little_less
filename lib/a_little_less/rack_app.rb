class AlittleLess::RackApp
    SLOW_GET_THRESOLD = 0.2

    ID_CHARS = 'a'.upto('z').to_a +
               'A'.upto('Z').to_a +
               '0'.upto('9').to_a

    def self.call env
        new(env).call
    end

    def initialize env
        @env = env
    end

    def call
        req = build_req
        req.id = rand_id
        resp = req.resp

        t0 = Time.now
        run_safe { log_req req }

        begin
            AlittleLessApp.new(req).conversation!
        rescue => e
            loge e
            Bugsnag.notify e
            resp.status = 500
        end

        resp.headers['X-Runtime'] = Time.now - t0
        run_safe { log_resp req }
        handle_body req, resp

        [
            resp.status,
            resp.headers,
            resp.body
        ]
    end

    private

    def rand_id
         4.times.map{ ID_CHARS.sample }.join
    end

    def handle_body req, resp
        h = resp.headers

        if resp.body.is_a?(Hash) or resp.body.is_a?(Array)
            h['Content-Type'] = 'application/json'
            resp.body = [resp.body.to_json]
        end

        if p = h['X-Sendfile'].presence and h['Content-Type'].blank?
            if c = get_content_type(p)
                h['Content-Type'] = c
            end
        end
    end

    def get_content_type path
        return unless File.exists? path
        require 'filemagic'
        unless defined? @@file_magic
            @@file_magic = FileMagic.open(:mime)
        end
        content_type = @@file_magic.file path
        if content_type =~ /^\S+\/\S+; charset=\S+$/i
            content_type
        end
    end

    def debug?
        #true
    end

    def log_req req
        if debug?
            logi "--ENV--\n#{ @env.to_yaml }\n--/ENV--"
        end
        logi [
            "Q #{req.id}",
            req.http_method.upcase,
            req.uri
        ].join(" ")
    end

    def log_resp req
        resp = req.resp
        status = resp.status.to_i
        success = status >= 200 && status < 400

        file = if success
            if status >= 300
                resp.headers['Location']
            else
                resp.headers['X-Sendfile'].to_s
            end
        end

        status_str = resp.status.to_s
        if success
            status_str = status_str.send (status >= 300 ? :cyan : :green)
        end

        log_line = [
            "A #{req.id}",
            status_str,
            log_runtime(resp.headers['X-Runtime'], req.http_method),
            file
        ].join(" ")

        if success
            logi log_line
        else
            loge log_line.red
        end
    end

    def log_runtime xrt, met
        rt = xrt.to_f
        rts = '%.6f' % rt
        color = :light_red if met == :get && rt > SLOW_GET_THRESOLD
        color ? rts.colorize(color) : rts
    end

    def params
        Rack::Utils
            .parse_nested_query(@env['QUERY_STRING'])
            .symbolize_keys
    end

    def clean_uri
        uri = @env['REQUEST_URI']
        uri.sub! /^(https?)?:\/\/[^\/]+/i, ''
        Rack::Utils.unescape uri
    end

    def build_req
        OpenStruct.new(
            http_method: @env['REQUEST_METHOD'].downcase.to_sym,
            uri: clean_uri,
            params: params,
            env: @env,
            resp: build_resp,
            post_parts: Rack::Multipart.parse_multipart(@env),
            referer: @env['HTTP_REFERER'],
            ua: @env['HTTP_USER_AGENT']
            # body: @env['rack.input'].tmp # for file uploads non multipart
        )
    end

    def build_resp
        OpenStruct.new(
            status: 200,
            headers: {},
            body: nil
        )
    end
end

class AlittleLess
    def self.rack_app
        RackApp
    end
end


# Example @env:

# REQUEST_URI: "/files/e/4/7/6/a/c/4/e476ac4e683ea737ddad1e53127819b983f1d5a5.jpg?fill=210x210&type=square210"
# PATH_INFO: "/files/e/4/7/6/a/c/4/e476ac4e683ea737ddad1e53127819b983f1d5a5.jpg"
# SCRIPT_NAME: ''
# QUERY_STRING: fill=210x210&type=square210
# REQUEST_METHOD: GET
# SERVER_NAME: example.com
# SERVER_PORT: '443'
# SERVER_SOFTWARE: Apache
# SERVER_PROTOCOL: HTTP/1.1
# REMOTE_ADDR: 179.234.49.149
# REMOTE_PORT: '56323'
# HTTPS: 'on'
# HTTP_USER_AGENT: Mozilla/5.0 (Linux; U; Android 4.3; pt-br; SM-G3502T Build/JLS36C)
#   AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30
# HTTP_ACCEPT_ENCODING: gzip,deflate
# HTTP_ACCEPT: "*/*"
# HTTP_ACCEPT_LANGUAGE: pt-BR, en-US
# HTTP_HOST: example.com
# HTTP_ACCEPT_CHARSET: utf-8, iso-8859-1, utf-16, *;q=0.7
# SSL_TLS_SNI: example.com
# rack.version:
# - 1
# - 2
# rack.input: !ruby/object:PhusionPassenger::Utils::TeeInput
#   len: 0
#   socket: !ruby/object:PhusionPassenger::Utils::UnseekableSocket
#     socket: !ruby/object:UNIXSocket {}
#     simulate_eof: true
#   bytes_read: 0
#   tmp: !ruby/object:StringIO {}
# rack.errors: !ruby/object:IO {}
# rack.multithread: false
# rack.multiprocess: true
# rack.run_once: false
# rack.url_scheme: https
# rack.hijack?: true
# rack.hijack: !ruby/object:Proc {}
# HTTP_VERSION: HTTP/1.1
# rack.tempfiles: []



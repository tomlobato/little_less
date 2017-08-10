
class Files < AlittleLess
    default_controller
    get '*' do
        # Helpers
        # send_file path
        # not_found
        # ... see https://github.com/tomlobato/little_less/blob/master/lib/a_little_less/util.rb
        redir_301 '/policy.html'
    end
    post 'upload' do
        if DoSome.new.thing
            {success: true}
        else
            error_422 success: false
        end
    end
    get 'users' do
        User.limit(10).map &:attributes
    end
end


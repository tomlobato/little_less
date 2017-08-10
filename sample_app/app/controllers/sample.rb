
class Files < AlittleLess
    default_controller
    get '*' do
        # Helpers
        # send_file path
        # not_found
        redir_301 '/policy.html'
    end
    post 'upload' do
        if DoSome.thing
            break error_422 success: false
        else
            {success: true}
        end
    end
    get 'users' do
        User.limit(10).map &:attributes
    end
end


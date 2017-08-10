class User < ActiveRecord::Base
    establish_connection :db

    attr_accessor :authenticated

    def self.check_auth key, auth
        user = User.find_by_user_hash key
        return unless user
        user.authenticated = auth == user.auth
        user
    end

end


def run_safe
    begin
        yield
    rescue => e
        loge e
    end
end


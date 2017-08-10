
class Exception
    def log
        loge to_s_long
    end
    def to_s_long
        l = [message]
        l += backtrace if backtrace
        l.join "\n"
    end
end

class String
    def decamelize
        scan(/[A-Z][a-z]*/).join("_").downcase
    end
    def camelize
        split('_').map(&:capitalize).join
    end
    def light_parameterize
        I18n.transliterate(self)
          .downcase
          .gsub(/[^a-z0-9]+/, '-')
          .gsub(/-+/, '-')
          .gsub(/^-|-$/, '')
    rescue => e
        logi "#{e.message} for '#{self}'"
        logi e.backtrace.join("\n") if e.backtrace
        self
    end
    def safe_utf8
        self.tidy_bytes.split(//u).join.force_encoding 'UTF-8'
    end
    def urlparams_to_hash
        hash = {}

        return hash if blank?

        split('&').each do |i| 
            k, v = i.split('=')
            if k and v
                hash[ k ] = v
            end
        end

        hash
    end
    def remove_extension
        self.sub /\..*$/, ''
    end
end

class Hash
  def symbolize_keys
    if self.is_a?(Hash) 
        Hash[ self.map { |k,v| [k.respond_to?(:to_sym) ? k.to_sym : k, v.is_a?(Hash) ? v.symbolize_keys : v] } ]
    else
        self
    end
  end
end

class Dir
    def self.ensure dir
        unless File.exist? dir
            FileUtils.mkdir_p dir
        end
    end
end

class Array
    def all_present?
        self.each do |i|
            return false if i.blank?
        end
        true
    end

    def any_present?
        self.each do |i|
            return true if i.present?
        end
        false
    end

    def any_blank?
        self.each do |i|
            return true if i.blank?
        end
        false
    end
end

class Pathname
    def realpath_safe
        realpath
    rescue Errno::ENOENT => e
        puts "Error following #{self}: #{e.message}"
        puts e.backtrace.join("\n") if e.backtrace
        nil
    end
end

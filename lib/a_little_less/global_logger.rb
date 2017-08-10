class GlobalLogger
	include Singleton
	
	SHOW_DIV = false

	def initialize
		@logger = build_logger
	end

	def log level, *args
		@level = level
		@caller = caller[1]
		div if SHOW_DIV
		args.each{|line| log_line line }
		nil
	end

	private

	def build_logger
		logger = Logger.new log_file
		logger.formatter = proc do |severity, datetime, progname, msg|
			"#{ severity[0] } #{ datetime.strftime('%y%m%d %H:%M:%S.%L') } #{ msg }\n"
		end
		logger
	end

	def _log s
		@logger.send @level, s
	end

	def div
		_log "\033[#{1};31;#{40}m -----#{ @caller }---------------\033[0m" 
	end

	def log_line line
		_log output(line)
		_log "----" if SHOW_DIV
	end

	def output line
		if line.is_a?(Numeric) || line.is_a?(String) || line.is_a?(Symbol)
			line
		elsif line.is_a? Exception
			line.to_s_long
		else
			line.to_yaml
		end
	end

	def log_file
		fname = case ENV['ALL_ENV']
		when 'PRODUCTION'
			'production'
		else
			'development'
		end
		"log/#{ fname }.log"
	end
end

def logd *args; GlobalLogger.instance.log :debug, 	*args; end
def logi *args; GlobalLogger.instance.log :info,	*args; end
def logw *args; GlobalLogger.instance.log :warn, 	*args; end
def loge *args; GlobalLogger.instance.log :error, 	*args; end
def logf *args; GlobalLogger.instance.log :fatal, 	*args; end
def logu *args; GlobalLogger.instance.log :unknown, *args; end
alias log logi 


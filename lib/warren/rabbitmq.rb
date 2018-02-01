module Warren
  module RabbitMQ

    class Exception < ::Exception

      @registry = {}

      class << self
        attr_accessor :registry
        attr_accessor :string
      end

      def self.inherited(subclass)
        super
        registry[subclass.name.demodulize.underscore.to_sym] = subclass
      end

      def self.handle(str)
        if (matches = str.match(/Error: (?<error>.*)/))
          error = ERLE.to_ruby(matches[:error])
          case error
          when Hash
            error_splits = error.first
            if error_class = registry[error_splits.first]
              raise error_class, error_splits.last
            else
              # Warren.logger.error "Couldn't discriminate exception class for error '#{error}'"
              raise UnknownException, "Couldn't discriminate exception class for error '#{error}'"
            end
          when String
            raise Exception, error
          end
        end
      end

    end

    class UnknownException < Exception
    end

    class NodeRunning < Exception
    end

    class InconsistentCluster < Exception
    end

    class Nodedown < Exception
    end

    def self.ctl(cmd, log: nil)
      # TODO: Parse for errors etc, raise?
      # TODO: "2>/dev/null" at the end of all commands?
      full_command = "rabbitmqctl -q #{cmd} 2>&1"
      Warren.logger.send(log, full_command) if log
      response = `#{full_command}`

      Exception.handle(response)

      obj = ERLE.to_ruby(response)
      # Warren.logger.warn("Obj '#{obj}'")
      uncomplicate(obj)
    end

    def self.uncomplicate(obj)
      (obj || {}).inject(Hash.new) { |h, i| h.merge(i) }
    end

  end
end

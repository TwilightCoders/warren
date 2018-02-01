module Warren
  module Node

    TYPES = [:disk, :ram]

    def self.start_app(address: , offline: false)
      RabbitMQ.ctl("-n #{address} start_app")
    end

    def self.stop_app(address: , offline: false)
      RabbitMQ.ctl("-n #{address} stop_app")
    end

    def self.start_server(address: , offline: false)
      RabbitMQ.ctl("-n #{address} start_server")
    end

    def self.stop_server(address: , offline: false)
      RabbitMQ.ctl("-n #{address} stop_server")
    end

    def self.clustered_with?(address: , remote_address: )
      status(address: remote_address).dig(:running_nodes)&.include?(address)
    end

    def self.clustered?(address: )
      !cluster_name(address: address).nil?
    end

    def self.cluster_name=(cluster_name, address: )
      return unless clustered?(address: address)
      RabbitMQ.ctl("-n #{address} set_cluster_name #{cluster_name}")
    end

    def self.cluster_name(address: )
      status(address: address).dig(:cluster_name)
    end

    def self.status(address: )
      RabbitMQ.ctl("-n #{address} cluster_status")
    end

    def self.set_policy(policy, address: )
      RabbitMQ.ctl("-n #{address} set_policy #{policy}")
    end

    def self.cleanup(address: )
      dir = Warren.config[:mnesia_node_base_dir]
      `rm -rf #{dir}/#{address}.pid`
      `rm -rf #{dir}/#{address}`
    end

  end
end

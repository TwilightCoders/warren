module Warren
  module Adapters
    class Base

      def initialize(*args)
      end

      def find_clusters
        fetch_nodes.inject(Hash.new) do |clusters, node|
          begin
            if cluster_name = Node.cluster_name(address: "#{Warren.config.node_name}@#{node}")
            (clusters[cluster_name] ||= Set.new).add(node)
            end
          rescue RabbitMQ::Nodedown => e
          end

          clusters
        end
      end

      def fetch_nodes
        []
      end

      def hostname
        `hostname`.chomp
      end

    end
  end
end

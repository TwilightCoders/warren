module Warren
  module Adapters
    class Base

      def initialize(*args)
      end

      def find_clusters
        fetch_nodes.inject(Hash.new) do |clusters, node|
          if cluster_name = Node.cluster_name(address: "#{Warren.config.node_name}@#{node}")
            (clusters[cluster_name] ||= Set.new).add(node)
          end
          clusters
        end
      end

      def fetch_nodes
        []
      end

      def hostname
        system 'hostname'
      end

    end
  end
end

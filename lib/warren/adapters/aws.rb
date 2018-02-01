require 'aws-sdk-ecs'
require 'aws-sdk-ec2'

module Warren
  module Adapters
    class AWS < Base

      attr_reader :ecs_client, :ec2_client
      attr_reader :cluster_name

      def initialize(cluster_name)
        super
        @cluster_name = cluster_name
        @ecs_client = Aws::ECS::Client.new
        @ec2_client = Aws::EC2::Client.new
      end

      def fetch_nodes
        instances.map(&:private_dns_name)
      end

      def hostname
        @hostname ||= `curl -s http://169.254.169.254/latest/meta-data/hostname`
      end

    # protected

      def instance_arns
        container_instances = ecs_client.list_container_instances({
          cluster: cluster_name,
          status: "ACTIVE"
        })

        container_instances.container_instance_arns
      end

      def instance_ids
        container_instances = ecs_client.describe_container_instances({
          cluster: cluster_name,
          container_instances: instance_arns
        }).container_instances

        container_instances.map(&:ec2_instance_id)
      end

      def instances
        ec2_reservations = ec2_client.describe_instances({
          instance_ids: instance_ids
        }).reservations

        # ec2_reservations.map { |reservation| reservation.instances }.flatten
        ec2_reservations.map(&:instances).flatten
      end

    end
  end
end

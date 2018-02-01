RSpec.describe Warren::RabbitMQ do

  context 'Warren::RabbitMQ::InconsistentCluster' do

    it 'is parsed correctly' do
      error_string = <<-S
        Error: {inconsistent_cluster,"Node 'rabbit@ip-10-1-3-250.us-west-2.compute.internal' thinks it's clustered with node 'rabbit@ip-10-1-2-220.us-west-2.compute.internal', but 'rabbit@ip-10-1-2-220.us-west-2.compute.internal' disagrees"}
      S
      expect{Warren::RabbitMQ::Exception.handle(error_string)}.to raise_error(Warren::RabbitMQ::InconsistentCluster)
    end

  end

end

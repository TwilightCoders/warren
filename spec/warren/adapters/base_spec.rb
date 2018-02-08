RSpec.describe Warren::Adapters::Base do

  before(:each) do

    @adapter = Warren::Adapters::Base.new

    cluster_one_status = {
      nodes: [{ disc: ['rabbit@ip-1-1.internal', 'rabbit@ip-1-2.internal']}],
      running_nodes: ['rabbit@ip-1-1.internal', 'rabbit@ip-1-2.internal'],
      cluster_name: 'rabbit@ip-1-1.internal',
      partitions: [],
      alarms: [{'rabbit@ip-1-1.internal'=>[]}, {'rabbit@ip-1-2.internal'=>[]}]
    }

    cluster_two_status = {
      nodes: [{disc: ['rabbit@ip-2-1.internal', 'rabbit@ip-2-2.internal']}],
      running_nodes: ['rabbit@ip-2-1.internal', 'rabbit@ip-2-2.internal'],
      cluster_name: 'rabbit@ip-2-1.internal',
      partitions: [],
      alarms: [{'rabbit@ip-2-1.internal'=>[]}, {'rabbit@ip-2-2.internal'=>[]}]
    }

    cluster_three_status = {
      nodes: [{disc: ['rabbit@ip-3-1.internal', 'rabbit@ip-3-2.internal']}],
      running_nodes: ['rabbit@ip-3-1.internal', 'rabbit@ip-3-2.internal'],
      partitions: [],
      alarms: [{'rabbit@ip-3-1.internal'=>[]}, {'rabbit@ip-3-2.internal'=>[]}]
    }

    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-1-1.internal').and_return(cluster_one_status)
    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-2-1.internal').and_return(cluster_two_status)
    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-2-2.internal').and_return(cluster_two_status)
    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-3-1.internal').and_return(cluster_three_status)

  end

  context '#find_clusters' do
    it "with a node that is down" do
      allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-4-1.internal').and_call_original
      allow(Warren::RabbitMQ).to receive(:exec_cmd).with('-n rabbit@ip-4-1.internal cluster_status', log: nil).and_return("Error: unable to connect to node 'rabbit@ip-3-1.internal': nodedown")

      allow(@adapter).to receive(:fetch_nodes).and_return([
        'ip-1-1.internal',
        'ip-2-1.internal',
        'ip-4-1.internal'
      ])

      clusters = @adapter.find_clusters
      expect(clusters.count).to eq(2)
      expect(clusters).to include('rabbit@ip-1-1.internal')
    end

    it "doesn't include nil clusters" do
      allow(@adapter).to receive(:fetch_nodes).and_return([
        'ip-1-1.internal',
        'ip-2-1.internal',
        'ip-3-1.internal'
      ])

      clusters = @adapter.find_clusters
      expect(clusters.count).to eq(2)
      expect(clusters).to include('rabbit@ip-1-1.internal')
    end

    it 'returns 2 clusters' do
      allow(@adapter).to receive(:fetch_nodes).and_return([
        'ip-1-1.internal',
        'ip-2-1.internal',
        'ip-2-2.internal'
      ])

      clusters = @adapter.find_clusters
      expect(clusters.count).to eq(2)
      expect(clusters).to include('rabbit@ip-1-1.internal')
      expect(clusters).to include('rabbit@ip-2-1.internal')
    end

  end

end


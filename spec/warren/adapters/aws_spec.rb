RSpec.describe Warren::Adapters::AWS do

  before(:each) do

    @adapter = Warren::Adapters::AWS.new('cluster_name')

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

    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-1-1.internal').and_return(cluster_one_status)
    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-2-1.internal').and_return(cluster_two_status)
    allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-2-2.internal').and_return(cluster_two_status)

  end

  context '#find_clusters' do

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

  context '#fetch_nodes' do

    it 'returns 2 private_dns_names' do
      allow(@adapter).to receive(:instances).and_return([
        Aws::EC2::Types::Instance.new(
          instance_id: 'i-foo',
          private_dns_name: 'ip-1-1.internal',
          private_ip_address: '10.1.1.250'
        ),
        Aws::EC2::Types::Instance.new(
          instance_id: 'i-bar',
          private_dns_name: 'ip-2-2.internal',
          private_ip_address: '10.2.2.220'
        )
      ])

      expect(@adapter.fetch_nodes).to eq(['ip-1-1.internal', 'ip-2-2.internal'])
    end

  end

  context '#hostname' do

  end

end


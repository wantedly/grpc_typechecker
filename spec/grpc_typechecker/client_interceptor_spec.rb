require "spec_helper"
require "google/protobuf/empty_pb"
require "src/proto/grpc/testing/test_services_pb"

RSpec.describe GrpcTypechecker::ClientInterceptor do
  class self::TestService < Grpc::Testing::TestService::Service
    def empty_call(req, call)
      Grpc::Testing::Empty.new
    end
  end

  let(:port) { 12475 }
  let(:server) {
    s = GRPC::RpcServer.new
    s.add_http2_port("0.0.0.0:#{port}", :this_port_is_insecure)
    s.handle(self.class::TestService)
    s
  }
  let(:stub) {
    Grpc::Testing::TestService::Stub.new(
      "localhost:#{port}",
      :this_channel_is_insecure,
      interceptors: [described_class.new(service_class: Grpc::Testing::TestService)]
    )
  }

  before { allow(ENV).to receive(:[]).and_call_original }
  before { allow(ENV).to receive(:[]).with('BASIC_AUTH_SYSTEM_USERNAME').and_return('foo') }
  before { allow(ENV).to receive(:[]).with('BASIC_AUTH_SYSTEM_PASSWORD').and_return('bar') }

  around do |e|
    th = Thread.start { server.run }
    sleep 0.3
    e.run
    server.stop
    th.join
  end

  it 'ill-typed request' do
    expect {
      stub.empty_call(Grpc::Testing::Empty)
    }.to raise_error(
      GRPC::InvalidArgument,
      "3:/grpc.testing.TestService/EmptyCall: expected an instance of Grpc::Testing::Empty, got an instance of Class"
    )
  end

  it 'well-typed request' do
    expect { stub.empty_call(Grpc::Testing::Empty.new) }.not_to raise_error(GRPC::InvalidArgument)
  end
end

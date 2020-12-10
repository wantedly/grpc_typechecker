module GrpcTypechecker
  class ClientInterceptor < GRPC::ClientInterceptor
    def initialize(service_class: nil)
      @service = service_class::Service
    end

    def request_response(request: nil, call: nil, method: nil, metadata: nil)
      # Raise InvalidArgument if the argument of gRPC method is ill-typed
      unless request.is_a?(request_class(method))
        raise GRPC::InvalidArgument, "#{method}: expected an instance of #{request_class(method)}, got an instance of #{request.class}"
      end
      yield
    end

    def client_streamer(requests: nil, call: nil, method: nil, metadata: nil)
      # no-op
      yield
    end

    def server_streamer(request: nil, call: nil, method: nil, metadata: nil)
      # no-op
      yield
    end

    def bidi_streamer(requests: nil, call: nil, method: nil, metadata: nil)
      # no-op
      yield
    end

  private

    # @param [String] method A string which represents a full path of a gRPC
    #     method. e.g. "/wantedly.users.UserService/GetUser"
    # @return [Class]
    def request_class(method)
      rpc_method = method.split('/')[2].to_sym
      @service.rpc_descs[rpc_method][:input]
    end
  end
end

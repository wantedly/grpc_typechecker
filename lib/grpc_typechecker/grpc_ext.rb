require "grpc"
require "active_support/core_ext/string/inflections"

module GRPC::GenericService
  # The usual way to supplement class methods is use of `Module#included'.
  # `GRPC::GenericService' already contains `included', thus we wrap `self.included' by `Module#prepend'.

  module IncludedForClassMethods
    def included(base)
      super
      base.extend(GRPC::GenericService::ClassMethods)
    end
  end

  class << self
    prepend IncludedForClassMethods
  end

  module ClassMethods
    def inherited(subclass)
      super if defined? super

      mod = Module.new do
        singleton_class.class_eval do
          # Some server interceptors try to obtain the service name by `method.owner.service_name` or `method.owner.to_s`.
          # despite `method` is overwritten by the method in this module.
          # We thus redirect class method calls of `service_name` and `to_s` for compatibility.
          define_method :service_name do
            subclass.service_name
          end

          define_method :to_s do
            subclass.to_s
          end
        end
      end

      subclass.class_eval do
        prepend mod
        @_prepended_module_for_type_check_ = mod
      end
    end

    def method_added(method)
      super if defined? super

      rpc_method = rpc_descs[method.to_s.camelize.to_sym]
      return unless rpc_method && @_prepended_module_for_type_check_

      # Overwrite the gRPC method
      @_prepended_module_for_type_check_.class_eval do
        define_method method do |*args, **kwargs|
          response = super(*args, **kwargs)
          # Raise Internal if the response of gRPC method is ill-typed
          unless response.is_a?(rpc_method[:output])
            raise GRPC::Internal, "the response of #{method} is expected to be an instance of #{rpc_method[:output]}, but the response is an instance of #{response.class}"
          end
          response
        end
      end
    end
  end
end

# GrpcTypechecker [![Build Status](https://travis-ci.com/wantedly/grpc_typechecker.svg?branch=master)](https://travis-ci.com/wantedly/grpc_typechecker)

A dynamic type checker for gRPC methods. This gem consists of two features:

- a client interceptor for the run-time type check of gRPC requests, and
- a monkey patch for type checking gRPC responses during execution.

## Installation

Add this line to your application's Gemfile:

    gem 'grpc_typechecker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grpc_typechecker

## Usage

If you would like to type check the gRPC requsts, please set the instance of `GrpcTypechecker::ClientInterceptor` as an interceptor of your gRPC application. For instance:

```ruby
server = Grpc::Testing::TestService::Stub.new(
  "localhost:12345",
  :this_port_is_insecure,
  interceptors: [
    GrpcTypechecker::ClientInterceptor(service_class: Grpc::Testing::TestService)
  ]
)
```

On the other hand, the dynamic type checker for gRPC responses will be automatically introduced only by requiring `grpc_typechecker`

```ruby
require 'grpc_typechecker'
```

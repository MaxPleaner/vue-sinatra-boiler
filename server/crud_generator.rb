#
# Defines the "crud_generate" method to create routes
# Load this using "register Sinatra::CrudGenerator"
#
# Note that if the :cross_origin_opts key in the crud_generate options is set,
# then sinatra-cross_origin is a dependency and "register Sinatra::CrossOrigin"
# should be run first
#

module Sinatra

  module CrudGenerator

    def get_default_secure_params(resource_class)
      Proc.new do |request|
        resource_class.new.attributes.keys.reject do |key|
          key.in? %w{id created_at updated_at}
        end
      end
    end

    def crud_generate(
      resource:, resource_class:, root_path: '/',
      cross_origin_opts: nil, auth: nil,
      index: nil, create: nil, read: nil, update: nil, destroy: nil,
      except: []
    )

      # the auth argument is a proc that can be used to disallow some requests.
      # It is passed the request as an argument.
      # It it returns something truthy, then the result of the auth block is sent
      # to the client and the route goes no further.
      # That's why the default proc returns false (to allow all requests)

      # The secure params (for update and create) defaults to all the keys except
      # id, created_at, and updated_at
      # It can be specified for a particular route
      # e.g. to allow no params on create:
      #    crud_generate(
      #      ... other opts (resource and resource_class are mandatory)
      #      create: { secure_params: Proc.new { |request| [] } }
      #    )

      if cross_origin_opts
        # Allow CORS preflight requests.
        # Each individual route still needs to state a CORS policy if it has one.
        before do
          if request.request_method == 'OPTIONS'
            response.headers["Access-Control-Allow-Origin"] = CLIENT_BASE_URL
            response.headers["Access-Control-Allow-Methods"] = "POST,DELETE,PUT,GET"
            halt 200
          end
        end
      end

      plural = resource.pluralize
      raise(
        ArgumentError, "resource does not have a simple plural"
      ) unless plural.eql?(resource + "s")
      
      default_secure_params_proc = get_default_secure_params(resource_class)

      index ||= {}
      index = {
        method: :get,
        path: "/#{plural}",
        auth: auth || Proc.new { |request| false },
        filter: Proc.new { |records| records }
      }.merge(index)

      create ||= {}
      create = {
        method: :post,
        path: "/#{plural}",
        auth: auth || Proc.new { |request| false },
        secure_params: default_secure_params_proc 
      }.merge(create)

      read ||= {}
      read = {
        method: :get,
        path: "/#{resource}",
        auth: auth || Proc.new { |request| false } 
      }.merge(read)

      update ||= {}
      update = {
        method: :put,
        path: "/#{resource}",
        auth: auth || Proc.new { |request| false },
        secure_params: default_secure_params_proc
      }.merge(update)

      destroy ||= {}
      destroy = {
        method: :delete,
        path: "/#{resource}",
        auth: auth || Proc.new { |request| false } 
      }.merge(destroy)

      unless except.include?(:index)
        send(index[:method], index[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          auth_result = index[:auth].call(request)
          return auth_result if auth_result
          {
            success: index[:filter].call(resource_class.all).map(&:public_attributes)
          }.to_json
        end
      end

      # Calls ActiveRecord "save" (via "create"), which is patched by ServerPush
      unless except.include?(:create)
        send(create[:method], create[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          auth_result = create[:auth].call(request)
          return auth_result if auth_result
          filtered_params = params.select do |key, val|
            key.in? *create[:secure_params].call(request)
          end
          created = resource_class.create(filtered_params)
          if created.persisted?
            { success: created.public_attributes }.to_json
          else
            { error: created.errors.full_messages }.to_json
          end
        end
      end

      unless except.include?(:read)
        send(read[:method], read[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          auth_result = read[:auth].call(request)
          return auth_result if auth_result
          found = resource_class.find_by(id: params[:id])
          if found
            { success: found.attributes }.to_json
          else
            { error: ["not found"] }.to_json
          end
        end
      end

      # calls ActiveRecord "update", which is patched by ServerPush
      unless except.include?(:update)
        send(update[:method], update[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          auth_result = update[:auth].call(request)
          return auth_result if auth_result
          filtered_params = params.select do |key, val|
            key.in? *create[:secure_params].call(request)
          end
          found = resource_class.find_by(id: params[:id])
          if found
            update[:secure_params].call.each do |key|
              found.send(:"#{key}=", params[key])
            end
            if found.valid?
              found.update({})
              { success: found.public_attributes }.to_json
            else
              { error: found.errors.full_messages }.to_json
            end
          else
            { error: ["not found"] }.to_json
          end
        end
      end

      # calls ActiveRecord "destroy" which is patched by ServerPush
      unless except.include?(:destroy)
        send(destroy[:method], destroy[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          auth_result = destroy[:auth].call(request)
          return auth_result if auth_result
          found = resource_class.find_by(id: params[:id])
          if found
            found.destroy!
            { success: found.attributes }.to_json
          else
            { error: ["not found"] }.to_json
          end
        end
      end

    end # /crud_generate

  end
end

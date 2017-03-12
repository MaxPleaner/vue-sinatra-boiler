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
      Proc.new do
        resource_class.new.attributes.keys.reject do |key|
          key.in? %w{id created_at updated_at}
        end
      end
    end

    def crud_generate(
      resource:, resource_class:, root_path: '/',
      cross_origin_opts: nil,
      index: nil, create: nil, read: nil, update: nil, destroy: nil,
      except: []
    )

    before do
      if request.request_method == 'OPTIONS'
        response.headers["Access-Control-Allow-Origin"] = "http://localhost:8080"
        response.headers["Access-Control-Allow-Methods"] = "POST,DELETE,PUT,GET"
        halt 200
      end
    end

      plural = resource.pluralize
      raise(
        ArgumentError, "resource does not have a simple plural"
      ) unless plural.eql?(resource + "s")
      
      default_secure_params_proc = get_default_secure_params(resource_class)
      index  ||= {
        method: :get,
        path: "/#{plural}",
        auth: Proc.new { },
        filter: Proc.new { |records| records }
      }
      create ||= {
        method: :post,
        path: "/#{plural}",
        auth: Proc.new { },
        secure_params: default_secure_params_proc 
      }
      read   ||= {
        method: :get,
        path: "/#{resource}",
        auth: Proc.new { } 
      }
      update ||= {
        method: :put,
        path: "/#{resource}",
        auth: Proc.new { },
        secure_params: default_secure_params_proc
      }
      destroy ||= {
        method: :delete,
        path: "/#{resource}",
        auth: Proc.new { } 
      }

      unless except.include?(:index)
        send(index[:method], index[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          index[:auth].call
          index[:filter].call(resource_class.all).map(&:public_attributes).to_json
        end
      end

      unless except.include?(:create)
        send(create[:method], create[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          create[:auth].call
          filtered_params = params.select do |key, val|
            key.in? *create[:secure_params].call
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
          read[:auth].call
          found = resource_class.find_by(id: params[:id])
          if found
            { success: found.attributes }.to_json
          else
            { error: ["not found"] }.to_json
          end
        end
      end

      unless except.include?(:update)
        send(update[:method], update[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          update[:auth].call
          filtered_params = params.select do |key, val|
            key.in? *create[:secure_params].call
          end
          found = resource_class.find_by(id: params[:id])
          if found
            update[:secure_params].call.each do |key|
              found.send(:"#{key}=", params[key])
            end
            if found.valid?
              found.save
              { success: found.public_attributes }.to_json
            else
              { error: found.errors.full_messages }.to_json
            end
          else
            { error: ["not found"] }.to_json
          end
        end
      end

      unless except.include?(:destroy)
        send(destroy[:method], destroy[:path]) do
          cross_origin(cross_origin_opts) if cross_origin_opts
          destroy[:auth].call
          found = resource_class.find_by(id: params[:id])
          if found
            found.destroy!
            { success: found.attributes }.to_json
          else
            { error: ["not found"] }.to_json
          end
        end
      end

    end # crud_generate

  end
end

module.exports = load: ({deps: {$, Vue, Client}}) ->

  CrudMapper = {}

  # ------------------------------------------------
  # These are private methods / helpers
  # ------------------------------------------------

  # Add $.put and $.delete methods
  jquery_extensions = require("./jquery_extensions").load {$}
  Object.assign $,
    delete: jquery_extensions.delete
    put: jquery_extensions.put

  # tracks which were added
  CrudMapper.resources = new Set()

  # ------------------------------------------------
  # This is the public api
  # ------------------------------------------------

  Object.assign CrudMapper,

    Client: Client

    # call from ws onopen or something like that
    get_indexes: ->
      @resources.forEach (resource) ->
        AppClient.Store.dispatch("index_#{resource}")

    # call this in the mutations file
    add_mutations: ({resource, plural_resource}) ->
      upcase_resource = resource.toUpperCase()
      plural_resource ||= resource + "s"
      "INDEX_#{upcase_resource}": (state, records) ->
        records.forEach (record) ->
          Vue.set(state[plural_resource], record.id, record)
      "CREATE_#{upcase_resource}": (state, record) -> 
        Vue.set(state[plural_resource], record.id, record)
      "UPDATE_#{upcase_resource}": (state, record) -> 
        Vue.set(state[plural_resource], record.id, record)    
      "DESTROY_#{upcase_resource}": (state, record) -> 
        Vue.delete(state[plural_resource], record.id)

    # call this from the ws onmessage handler
    process_ws_message: ({action, type, record}) ->
      switch action
        when "add_record"
          AppClient.Store.commit("CREATE_#{type.toUpperCase()}", record)
        when "update_record"
          AppClient.Store.commit("UPDATE_#{type.toUpperCase()}", record)
        when "destroy_record"
          AppClient.Store.commit("DESTROY_#{type.toUpperCase()}", record)

    # call this from the actions file
    add_store_actions: ({
      resource, root_path,                                        # strings
      index, create, read, update, destroy,                       # objects
    }) ->

      @resources.add(resource)

      root_path ||= "#{@Client.prototype.base_url}/"

      index ||= {}
      index = Object.assign {method: "get", path: "#{resource}s"}, index

      create ||= {}
      create = Object.assign {method: "post", path: "#{resource}s"}, create

      read ||= {}
      read = Object.assign {method: "get", path: "#{resource}"}, read

      update ||= {}
      update = Object.assign {method: "put", path: "#{resource}"}, update

      destroy ||= {}
      destroy = Object.assign {method: "delete", path: "#{resource}"}, destroy

      "index_#{resource}": ({commit}) -> new Promise (resolve, reject) =>
        data = token: AppClient.Store.state.token
        $[index.method] "#{root_path}#{index.path}", data, (response) ->
          {success, error} = JSON.parse(response)
          if success
            commit("INDEX_#{resource.toUpperCase()}", success)
            # Success object here is a list of records
            resolve(success)
          else
            AppClient.Store.dispatch("add_errors", Array.from(error))
            reject(error)
      
      "create_#{resource}": ({commit}, body) -> new Promise (resolve, reject) =>
        data = Object.assign body, {token: AppClient.Store.state.token}
        $[create.method] "#{root_path}#{create.path}", body, (response) ->
          {success, error} = JSON.parse(response)
          if success
            commit("CREATE_#{resource.toUpperCase()}", success)
            AppClient.Store.dispatch("add_notice", "created todo")
            # Success object here is a new record
            resolve(success)
          else
            AppClient.Store.dispatch("add_errors", Array.from(error))
            reject(error)

      "destroy_#{resource}": ({commit}, {id}) -> new Promise (resolve, reject) =>
        data = Object.assign {id}, {token: AppClient.Store.state.token}
        $[destroy.method] "#{root_path}#{destroy.path}", data, (response) =>
          { success, error } = JSON.parse response
          if success
            commit "DESTROY_#{resource.toUpperCase()}", success
            AppClient.Store.dispatch("add_notice", "destroyed todo")
            # Success object here is the deleted record
            resolve(success)
          else
            AppClient.Store.dispatch("add_errors", Array.from(error))
            reject(error)

      "update_#{resource}": ({commit}, body) -> new Promise (resolve, reject) =>
        data = Object.assign body, {token: AppClient.Store.state.token}
        $[update.method] "#{root_path}#{update.path}", body, (response) =>
          { success, error } = JSON.parse response
          if success
            commit "UPDATE_#{resource.toUpperCase()}", success
            AppClient.Store.dispatch("add_notice", "updated todo")
            # Success object here is the deleted record
            resolve(success)
          else
            AppClient.Store.dispatch("add_errors", Array.from(error))
            reject(error)
        
  CrudMapper

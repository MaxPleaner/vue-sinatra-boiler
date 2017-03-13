module.exports = load: ({deps: {$, Vue}}) ->

  # Add $.put and $.delete methods
  jquery_extensions = require("./jquery_extensions").load {$}
  Object.assign $,
    delete: jquery_extensions.delete
    put: jquery_extensions.put

  add_mutations: ({resource, plural_resource}) =>
    upcase_resource = resource.toUpperCase()
    plural_resource ||= resource + "s"
    "CREATE_#{upcase_resource}": (state, record) -> 
      Vue.set(state[plural_resource], record.id, record)
    "UPDATE_#{upcase_resource}": (state, record) -> 
      Vue.set(state[plural_resource], record.id, record)    
    "DESTROY_#{upcase_resource}": (state, record) -> 
      Vue.delete(state[plural_resource], record.id)


  add_store_actions: ({resource, root_path, index, create, read, update, destroy}) =>
    root_path ||= "http://localhost:3000/"
    index     ||= method: "get",    path: "#{resource}s"
    create    ||= method: "post",   path: "#{resource}s"
    read      ||= method: "get",    path: "#{resource}"
    update    ||= method: "put",    path: "#{resource}"
    destroy   ||= method: "delete", path: "#{resource}"
    
    "create_#{resource}": ({commit}, body) -> new Promise (resolve, reject) =>
      $[create.method] "#{root_path}#{create.path}", body, (response) ->
        {success, errors} = JSON.parse(response)
        if success
          commit("CREATE_#{resource.toUpperCase()}", success)
          # Success object here is a new record
          resolve(success)
        else
          reject(errors)

    "destroy_#{resource}": ({commit}, {id}) -> new Promise (resolve, reject) =>
      $[destroy.method] "#{root_path}#{destroy.path}", {id}, (response) =>
        { success, errors } = JSON.parse response
        if success
          commit "DESTROY_#{resource.toUpperCase()}", success
          # Success object here is the deleted record
          resolve(success)
        else
          reject(errors)

    "update_#{resource}": ({commit}, body) -> new Promise (resolve, reject) =>
      $[update.method] "#{root_path}#{update.path}", body, (response) =>
        { success, errors } = JSON.parse response
        if success
          commit "UPDATE_#{resource.toUpperCase()}", success
          # Success object here is the deleted record
          resolve(success)
        else
          reject(errors)
        




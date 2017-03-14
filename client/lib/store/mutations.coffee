module.exports = load: ({deps: {Vue, CrudMapper}}) ->

  todos_crud = CrudMapper.add_mutations
    resource: "todo"

  auth = 
    SET_TOKEN: (state, token) ->
      Vue.set(state, "token", token)
    SET_LOGGED_IN: (state, logged_in) ->
      Vue.set(state, "logged_in", logged_in)
    SET_USERNAME: (state, username) ->
      Vue.set(state, "username", username)

  Object.assign(todos_crud, auth)


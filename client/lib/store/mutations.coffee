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

  errors = 
    PUSH_ERROR: (state, error) ->
      state.errors.push error
      Vue.set state, "errors", state.errors
    SHIFT_ERROR: (state) ->
      state.errors.shift()
      Vue.set state, "errors", state.errors

  notices =
    PUSH_NOTICE: (state, notice) ->
      state.notices.push notice
      Vue.set state, "notices", state.notices
    SHIFT_NOTICE: (state) ->
      state.notices.shift()
      Vue.set state, "notices", state.notices      

  Object.assign(todos_crud, auth, errors, notices)


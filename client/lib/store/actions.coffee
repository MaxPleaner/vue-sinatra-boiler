module.exports = load: ({deps: {CrudMapper}}) ->
  Object.assign (
    CrudMapper.add_store_actions
      resource: "todo"
  ), (

    # Both errors and notices are rendered by the "notices" component
    # and expire after a few seconds.

    add_errors: ({commit}, errors) ->
      for error in errors
        commit("PUSH_ERROR", error)
        setTimeout ->
          commit("SHIFT_ERROR")
        , 2500

    add_notice: ({commit}, notice) ->
      commit("PUSH_NOTICE", notice)
      setTimeout ->
        commit("SHIFT_NOTICE")
      , 2500

  )

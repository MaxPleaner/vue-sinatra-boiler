module.exports = load: ({deps}) ->
  add_todo: ({dispatch}, {text}) ->
    dispatch("ADD_TODO", {text})

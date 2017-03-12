module.exports = load: ({deps}) ->
  add_todo: ({commit}, {text}) ->
    new Promise (resolve, reject) ->
      commit("ADD_TODO", {text})
      resolve(text)

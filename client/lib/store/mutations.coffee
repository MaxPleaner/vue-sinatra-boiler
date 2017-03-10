module.exports = load: ({deps}) ->
  ADD_TODO: (state, {text}) -> 
    state.todos.push {text}



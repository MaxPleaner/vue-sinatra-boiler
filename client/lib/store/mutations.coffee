module.exports = load: ({deps}) ->
  CREATE_TODO: (state, record) -> 
    state.todos.push record
  DESTROY_TODO: (state, record) -> 
    debugger
    delete state.todos[record]



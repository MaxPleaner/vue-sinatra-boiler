module.exports = load: ({deps: {Vue, mapState}}) ->
  Vue.component "todos",
    template: require('html-loader!./todos.slim')
    computed: mapState ['todos']
    methods:
      create_todo: (e) ->
        @$store.dispatch("create_todo", text: e.target.value)
      delete_todo: (todo) ->
        @$store.dispatch("destroy_todo", id: todo.id)


module.exports = load: ({deps: {Vue, mapState}}) ->
  Vue.component "todos",
    template: require('html-loader!./todos.slim')
    computed: mapState(['todos'])
    methods:
      create_todo: (e) ->
        @$store.dispatch("create_todo", text: e.target.value)
      delete_todo: (todo) ->
        @$store.dispatch("destroy_todo", id: todo.id)
      update_todo: (e, todo) ->
        text = e.currentTarget.value
        clone_to_update = Object.assign {}, todo
        @$store.dispatch("update_todo", Object.assign(clone_to_update, {text}))



module.exports = load: ({deps: {CrudMapper}}) ->
  CrudMapper.add_store_actions
    resource: "todo"

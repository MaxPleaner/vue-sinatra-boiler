module.exports = load: ({deps: {Vue, CrudMapper}}) ->
  CrudMapper.add_mutations
    resource: "todo"


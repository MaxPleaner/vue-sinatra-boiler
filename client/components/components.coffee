# Manifest of components - all should be required here

module.exports = load: ({deps}) ->
  navbar: require('./navbar/navbar.coffee').load {deps}
  about: require('./about/about.coffee').load { deps }
  contact: require('./contact/contact.coffee').load { deps }
  todos: require('./todos/todos.coffee').load { deps }
  authenticator: require('./authenticator/authenticator.coffee').load { deps }

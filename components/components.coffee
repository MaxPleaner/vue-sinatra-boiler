module.exports = load: ({deps}) ->
  navbar = require('./navbar/navbar.coffee').load {deps}
  root = require('./root/root.coffee').load {deps}
  { navbar, root }

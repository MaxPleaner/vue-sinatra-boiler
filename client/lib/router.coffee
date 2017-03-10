module.exports = load: ({ deps: { Vue, VueRouter, components } }) ->
  Vue.use VueRouter
  new VueRouter routes: [
    { path: '/about', component: components.about },
    { path: '/contact', component: components.contact }
    { path: '/', component: components.welcome }
  ]

**about**

This is a boilerplate using:

- webpack: server which automatically compiles and hot-pushes changes to browser.
- Vue: a client-side framework
- coffeescript 2: a nicer syntax for javascript
- slim: a ruby html templating library (used to build Vue components' HTML)
- auth: Github oauth
- server: Sinatra using faye-websockets and thin

**dependencies**:

- First of all, clone this repo (or fork).
- Client-side: first `cd client`. 
  Ruby deps are listed in the `Gemfile`. Run `bundle install`.
  NPM deps are listed in `package.json`. Run `npm insall`.
- the `server/` is a separate app and needs to have its dependencies installed
  too. `cd server` and `bundle install` there. - 
- Create an application on Github developers console, copy `server/.env.example` to
`server/.env` and then customize it with your credentials.

**running**:

There are two components, which should be run in separate tabs:

  - server (runs config.ru): `cd server; bundle exec thin start`
  - client (runs webpack.config.js): `cd client; npm run dev`

Then visit http://localhost:8080

**understanding/extending** 

What good is a boiler if the more nuanced details aren't covered in the README?

_Client_:

- `client/client.coffee` is the entry point to the client-side code.
- `client/components/components.coffee` is a manifest of components
- each component has its own folder in `client/components/`. They will contain
  at least 2 files:
  - a `.slim` file with the HTML template
  - a `.coffee` file for the JS definition
- `client/index.html` is served statically by webpack at GET '/' at localhost:8080
- `client/lib/router.coffee` maps clien-side routes to components.
- `client/lib/store.coffee` is a Vuex store (available to all components, but not used).
   This library has similarity to Redux but is more coupled to Vue.
- `client/style/app.sass` is added to the DOM and hot-reloaded
- `client/webpack.config.js` is very important. It extends the behavior of
   `require` to load non-JS assets and concatenates scripts into
   `bundle.js` with hot reloading. Furthermore, it acts as a static
   server for the front end.

_Server_:

- This is built with Sinatra (in Ruby) and uses faye-websockets with thin to
  handle websockets.
- Most of the code in `server/` is from
  [sinatra_sockets](http://github.com/maxpleaner/sinatra_sockets), another boiler
  I've made. 
- See `server/lib/routes/index.rb` for the server's websocket API
  and `server/server.rb` for routes pertaining to Github oAuth.

_Webpack loading_:

- First of all, Webpack does not interact with the server and any changes there
  require the server to be restarted.
- In in `client/webpack.config.js`, though, Webpack does a lot of magic for the front-end.
- The `context: __dirname` line starts a static HTTP server on port 8080 which sends
  the `client/index.html` file at the root of this repo.
- That file loads the script `bundle.js` and attaches `bundle.css` to the DOM,
  both of which Webpack maintains as _in-memory_ concatenations of all our compiled assets.
- The webpack config specifies `entry: "./client.coffee"`, and that file becomes
  the launching point of the client side code.
- The sass file `client/style/app.sass` is loaded into Javascript in `client.coffee`.
  But Webpack magic attaches it to the DOM as soon as it's `require`d in JS. So it's
  not listed in `client/index.html`. 

_component loading_:

- `client/client.coffee` loads Vue components from `client/components/components.coffee`.
- This components file individually requires each of the components in the `client/components/`
  folder (such as navbar and root).
- Specifically, it requires the `.coffee` file of the component such as `client/components/navbar/navbar.coffee`.
- That coffee file then requires the .slim template (`client/components/navbar/navbar.slim`) which contains the
  Vue-style HTML markup.
- The slim templates are loaded using the
  [slim-lang-loader](http://github.com/maxpleaner/slim-lang-loader), which I authored.
- For example `require('html-loader!./navbar.slim')` is in the `navbar.coffee` file;
  this returns a HTML string that is automatically updated whenever the .slim file changes.
- Every component must be listed in `client/components/omponents.coffee`, and there can't be anything
  dynamic passed to `require` or webpack won't be able to track the dependencies.
- Since it's the top-level element, root is technically a _Vue instance_ as
  opposed to a Vue component. This means that it doesn't get a custom HTML tag created,
  and copy-pasting its code to create a new component won't work.

_creating a new componenet_

1. create a new folder in `client/components/<name>`
2. create a `client/components/<name>/<name>.slim` file with the template
3. create a `client/componens/<name>/<name>.coffee` file for the JS definition.
  This file should require the slim template - 
  see `client/components/navbar/navbar.coffee` for an example of this.
4. Add a line requiring the new component in `client/components/components.coffee`
5. It can be attached to the DOM in (at least) these 2 ways:
  1. add a client-side route in `client/lib/router.rb` then put a `router-link`
     in some template which links to it. See the navbar tenplate for an example of this.
  2. Add the component's HTML tag to some other component that's being rendered.
     For example, if the component is named `potato` then you can simple write
     `potato` in one of the other components' slim template and it will render
     there as a child. See the Vue docs for more info on how components work.

_routing_:

`client/vue/components/root/` is the layout component.
It renders a `router-view` component which is akin to the `yield` in Rails.
The routes are declared in `client/lib/router.coffee`.


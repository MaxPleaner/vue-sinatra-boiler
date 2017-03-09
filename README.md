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
- Ruby dependencies are listed in the `Gemfile`. Run `bundle install`
  - the `server/` is a separate app and needs to have its dependencies installed
  too. run `cd server && bundle install`
- NPM dependencies are listed in `package.json`. Run `npm install`.
- Create an application on Github developers console, copy `server/.env.example` to
`server/.env` and then customize it with your credentials.

**running**:

There are two components, which should be run in separate tabs:

  - server (runs config.ru): `cd server; thin start`
  - client (runs webpack.config.js): `npm run dev`

Then visit http://localhost:8080

**understanding/extending**

What good is a boiler if the more nuanced details aren't covered in the README?

For reference, here's a tree of this repo:

```txt
.
├── client.coffee-------------Entrace to client-side code
├── components                
│   ├── components.coffee-----Manifest of Vue components
│   ├── about-----------------Each Vue component has its own folder with:
│   │   ├── about.coffee--------a coffee file (for scripting)
│   │   └── about.slim----------a slim file (for templating)
│   ├── contact
│   │   ├── contact.coffee
│   │   └── contact.slim
│   ├── navbar
│   │   ├── navbar.coffee
│   │   └── navbar.slim
│   ├── root------------------The layout component (always shown)
│   │   ├── root.coffee
│   │   └── root.slim
│   └── welcome
│       ├── welcome.coffee
│       └── welcome.slim
├── Gemfile-------------------Lists Ruby dependencies such as the slim compiler
├── index.html----------------HTML page which loads our app via JS
├── lib
│   ├── router.coffee---------Client-side routing of path to component
│   └── store.coffee----------Vuex storage system (some similarity to redux)
├── package.json--------------NPM dependencies
├── README.md
├── server--------------------Ommitted here for brevity, see note below
├── style
│   └── app.sass--------------CSS written in Sass
└── webpack.config.js---------Webpack compiles & serves the app

```

_Server_:

This is built with Sinatra (in Ruby) and uses faye-websockets with thin to
handle websockets. Most of the code in `server/` is from
[sinatra_sockets](http://github.com/maxpleaner/sinatra_sockets), another boiler
I've made. 

See `server/lib/routes/index.rb` for the server's websocket API
and `server/server.rb` for routes pertaining to Github oAuth.

_Webpack loading_:

First of all, Webpack does not interact with the server and any changes there
require the server to be restarted.

In in `webpack.config.js`, though, Webpack does a lot of magic for the front-end.
The `context: __dirname` line starts a static HTTP server on port 8080 which sends
the `index.html` file at the root of this repo. That file loads the script `bundle.js`
and attaches `bundle.css` to the DOM, both of which Webpack maintains as _in-memory_
concatenations of all our compiled assets.

To reiterate, every .coffee file is combined into `bundle.js` which is loaded by `index.html`.
The webpack config specifies `entry: "./client.coffee"`, and that file becomes the
launching point of the client side code.

The sass file `app.sass` is loaded into Javascript in `client.coffee`.
But it does not need to be manually attached to the DOM. This happens
automatically.

_component loading_:

`client.coffee` loads Vue components from `components/components.coffee`, This
components file individually requires each of the components in the `components/`
folder (such as navbar and root). Specifically, it requires the `.coffee` file of
the component such as `components/navbar/navbar.coffee`. That coffee file then
requires the .slim template (`components/navbar/navbar.slim`) which contains the
Vue-style HTML markup. The slim templates are loaded using the
[slim-lang-loader](http://github.com/maxpleaner/slim-lang-loader), which I authored.
For example `require('html-loader!./navbar.slim')` is in the `navbar.coffee` file;
this returns a HTML string that is automatically updated whenever the .slim file changes.

Every component must be listed in `components.coffee`, and there can't be anything
dynamic passed to `require` or webpack won't be able to track the dependencies.
In other words, _all requires in the app must be static_. 

One other detail about the components' coffee files:

the `navbar.coffee` returns a `Vue.component` while `root.coffee` returns only a
`new Vue`. Root isn't defined as a component because it's top level, but everything
else can be one. When a component is defined, a HTML tag is generated. That's why
`root.slim` renders `<navbar></navbar>` (which is a custom HTML tag).

_routing_:

`root.slim` acts as a layout file.
It renders a `router-view` component which is akin to the `yield` in Rails.
The routes are declared in `lib/router.coffee`.


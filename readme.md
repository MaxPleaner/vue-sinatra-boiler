# Vue/Sinatra boiler

a boiler built with Vue (client) and Sinata (server).

The server uses faye-websockets and maps connected sockets to logged in users
via a token passed to the connect request. It includes Github oAuth,
ActiveRecord, a Crud generator, and a server-push library to alert clients of
DB updates.

The client uses Vuex, a redux-like library with mutations/actions/store and such.
Since this type of thing generally requires a lot of boiler, there's a Crud
generator here too. It uses webpack to compile NPM deps, coffeescript, sass, and slim
code into Javascript objects that can be run from the client. Webpack has great
built-in hot reloading and runs the front-end as a static server.

Out the box, this boiler provides a basic collaborative Todo app with 3-way data binding.
In other words, any connected clients will see the todo list update in realtime,
even if the action was called by a different client. It also includes github oauth,
although the todos functionality doesn't require login.

---

### How to run

1. First of all, make sure you have at least the current LTS version of Node
(right now it's 6.10.0), Ruby 2.3 or newer, and a Unix environment.

2. Next, clone the repo and change the origin
      
        git clone https://github.com/MaxPleaner/vue-sinatra-boiler
        cd vue-sinatra-boiler
        git remote set-url origin git@github.com:<username>/<repo>.git

3. Create a new oAuth account on Github developer console

4. Configure the server

        cd server
        bundle install
        bundle exec rake db:create db:migrate
        cp .env.example .env
        nano .env # add the Github credentials here

5. Start the server

        bundle exec thin start

6. Configure the client

        cd ../client
        npm install

7. Start the client
    
        npm run dev

8. Visit the app at localhost:8080

---

### source code overview

#### client

Some important concepts to keep in mind:

- `components/` contains a separate folder for each component (`about/` and `contact/` are ommited here)
- all the coffee, slim, and sass files get compiled into `bundle.js` which is loaded by `index.html` 

```txt
├── client.coffee ------------------ The core of the client side code, required by loader.coffee
├── components --------------------- Contains a folder for each component (some are omitted here)
│   ├── components.coffee ---------- Manifest of components - requires each component
│   ├── navbar --------------------- Each component has two files:
│   │   ├── navbar.coffee ----------   coffee file for module definition
│   │   └── navbar.slim ------------   slim file for HTML template
│   ├── root ----------------------- Layout component that is always visible (along with navbar)
│   │   ├── root.coffee
│   │   └── root.slim
│   └── todos
│       ├── todos.coffee
│       └── todos.slim
├── Gemfile ------------------------ Ruby deps for client (it's only slim)
├── Gemfile.lock
├── index.html --------------------- Entry point of the app, served statically
├── lib
│   ├── crud_mapper.coffee --------- A generator for Vuex mutations/actions and server-push listeners
│   ├── jquery_extensions.coffee --- Helper methods for $.put and $.delete
│   ├── router.coffee -------------- Client side router
│   ├── store
│   │   ├── actions.coffee --------- Vuex actions make requests to server, and then commit mutations with the response
│   │   ├── mutations.coffee ------- Atomic actions to change the client state
│   │   └── state.coffee ----------- Initial client state
│   └── store.coffee --------------- Vuex store is available to all components
├── loader.coffee ------------------ Loaded by webpack.config.js, this the entry point of the client code.
├── package.json
├── style
│   └── app.sass ------------------- Not really used here but set up for hot reloading
└── webpack.config.js -------------- Webpack configuration

```

#### server

```txt
├── config.ru ---------------------- Entry point to server, run by "bundle exec thin start"
├── crud_generator.rb -------------- Sinatra plugin to generate CRUD routes for a resource
├── db
│   ├── migrate
│   │   └── 20170312215739_create_todos.rb
│   └── schema.rb
├── Gemfile ------------------------ Server dependencies
├── Gemfile.lock
├── models.rb ---------------------- ActiveRecord models (only Todo for now)
├── Rakefile ----------------------- Loads tasks from sinatra-activerecord
├── README.md
├── server_push.rb ----------------- Module which can be included in models to push updates to clients
├── server.rb ---------------------- Core of the Server, definition of Sinatra app
└── ws.rb -------------------------- The websocket API
```


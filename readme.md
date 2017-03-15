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

**demo**

see [https://maxpleaner.github.io/vue-sinatra-boiler](https://maxpleaner.github.io/vue-sinatra-boiler) 
(the backend is on heroku)

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
- the [slim-lang-loader](http://github.com/maxpleaner/slim-lang-loader
  used by webpack is somethin I authored. It allows .slim files to be passed through
  the HTML loader to become strings in Javascript.

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

#### deploying

First of all, you should decide what the production urls are going to be
for the front-end and server. Then do a search and replace in the codebase
for the following strings:

- `vue-sinatra-boiler-demo.herokuapp.com` (replace with your server url) _used by client for `ws://` and `https://`
- `maxpleaner.github.io` (replace with your front-end host only, not including path) _used by server for CORS_

The front end is easy to deploy to Github pages or another host like that.

1. `cd client`
2. `npm run deploy` - this will generate `client-dist/prod-bundle.js`
3. commit changes
4. `sh push_client_dist_to_gh_pages` will push the `client-dist/` folder to 
   the gh-pages branch of whatever origin the repo points to.

The server includes a Procfile so it's easy to deploy to heroku.

1. `heroku create --app <some app name>`
2. `sh push_server_to_heroku`
3. `heroku run rake db:migrate`
4. use `heroku config:set` to copy over the GitHub credentials in `.env`
5. Make sure to re-configure the Github application on their developer console
   so that it redirects to `https://<your url>/auth/github/callback`

### Todos

Extract the Crud generators and server push into their own libraries

Why does refreshing the demo twice cause a logout?

### Help?

If you are interested in using this boiler but are having a hard time making sense
of it, I'll be happy to help if you reach out to maxpleaner@gmail.com


**about**

This is a boilerplate using:

- webpack: server which automatically compiles and hot-pushes changes to browser.
- Vue: a client-side framework for data binding.
- coffeescript (2): a nicer syntax for javascript
  - a big benefit of this is ES6 arrow functions (`=>`), which differ from the standard
    coffeescript `->` since they bind the value of `this` to their lexical context.
- slim: a ruby html templating library (used to build Vue components' HTML)


**dependencies**:

- First of all, clone this repo (or fork).
- Ruby dependencies are listed in the `Gemfile`. Run `bundle install`.
- NPM dependencies are listed in `package.json`. Run `npm install`.

**running**:

- To run the boilerplate example _as-is_, just to see if it works, enter `npm run dev`. The definition of this command is in `package.json`. It launches `webpack.config.js` using `webpack-dev-server`. 
- visit http://localhost:8080

**understanding/extending**

What good is a boiler if the more nuanced details aren't covered in the README?

For reference, here's a tree of this repo:

```txt
.
├── client.coffee
├── components
│   ├── about
│   │   ├── about.coffee
│   │   └── about.slim
│   ├── components.coffee
│   ├── contact
│   │   ├── contact.coffee
│   │   └── contact.slim
│   ├── navbar
│   │   ├── navbar.coffee
│   │   └── navbar.slim
│   ├── root
│   │   ├── root.coffee
│   │   └── root.slim
│   └── welcome
│       ├── welcome.coffee
│       └── welcome.slim
├── Gemfile
├── index.html
├── lib
│   ├── router.coffee
│   └── store.coffee
├── package.json
├── README.md
├── style
│   └── app.sass
└── webpack.config.js

```

_Webpack loading_:

Webpack does a lot of magic here (in `webpack.config.js`). The `context: __dirname` line starts a static HTTP server on port 8080 which sends the `index.html` file at the root of this repo. That file loads the script `bundle.js`, which Webpack maintains as an _in-memory_ concatenation of all our compiled coffeescripts.

To reiterate, every .coffee file is combined into `bundle.js` which is loaded by `index.html`. The webpack config specifies `entry: "./client.coffee"`, and that file becomes the launching point of the client side code.

The sass file `app.sass` is loaded into Javascript in `client.coffee`.
But it does not need to be manually attached to the DOM. This happens
automatically.

_component loading_:

`client.coffee` loads Vue components from `components/components.coffee`, This components file individually requires each of the components in the `components/` folder (such as navbar and root). Specifically, it requires the `.coffee` file of the component such as `components/navbar/navbar.coffee`. That coffee file then requires the .slim template (`components/navbar/navbar.slim`) which contains the Vue-style HTML markup. The slim templates are loaded using the [slim-lang-loader](http://github.com/maxpleaner/slim-lang-loader), which I authored. For example `require('html-loader!./navbar.slim')` is in the `navbar.coffee` file; this returns a HTML string that is automatically updated whenever the .slim file changes.

Every component must be listed in `components.coffee`, and there can't be anything dynamic passed to `require` or webpack won't be able to track the dependencies. In other words, _all requires in the app must be static_. 

One other detail about the components' coffee files:

the `navbar.coffee` returns a `Vue.component` while `root.coffee` returns only a `new Vue`. Root isn't defined as a component because it's top level, but everything else can be one. When a component is defined, a HTML tag is generated. That's why `root.slim` renders `<navbar></navbar>` (which is a custom HTML tag).


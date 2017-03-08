1. Clone the repo
2. `npm install` and `bundle install`. The generated app has no server component, but these deps are used for compilation
3. run `npm run dev`.
   This launches `npm `webpack.config.js`, which ...
   1. serves `index.html` statically and loads `bundle.js`.
   2. maintains `bundle.js` as the concatenation of all coffee code
   3. uses `main.coffee` is the entry point to the coffee code, which: loads Vue components
4. visit localhost:8080


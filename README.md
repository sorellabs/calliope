Calliope
========

Calliope is a documentation toolkit for JavaScript projects. It uses
meta-information available in `package.json` files and provides a nice
and easy-to-use interface for the more generic tools: [kalamoi][] and
[papyr][].


## Getting Started

1) Document your files using [kalamoi][]'s documentation format:

```js
/// Module my-project
// A description for this module goes here.

//// Function identity
// This function is part of the module (note the number of comment
// characters).
// :: a -> a
function identity(a){ return a }

//// -- This is a logical group
///// Function foo
// This function belongs to this logical group.
function foo(){ }
```

2) Provide information on where to find your files:

   You probably have a `package.json` file in your project already,
   Calliope will use the information there, you just need to specify
   which files should be analysed for extracting documentation:

```js
{ "name": "my-project"
, "version": "1.0.0-snapshot"
, "calliope": {
    "packages": [
      { "parent": "my-project"
      , "files": [ "./lib/*.js" ]
      }]
    }
}
```

> `parent` is the name of the "main" module that all other modules in a
> folder are a part of. If you don't use a "package-like" structure (all
> your modules are flat), you don't need it.


3) Run the build step to generate your docs:

```bash
$ calliope build
```


4) Check your documentation on `build-docs/index.html`.


## Installation

One-command easy-install from NPM:

```bash
$ npm install -g calliope
```


## Licence

MIT/X11. ie.: do whatever you want with it.

[papyr]: https://github.com/killdream/papyr
[kalamoi]: https://github.com/killdream/kalamoi

## Module calliope #####################################################
#
# Command line interface for kalamoi/papyr in JS projects.
#
# 
# Copyright (c) 2013 Quildreen "Sorella" Motta <quildreen@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

doc = '''
      Calliope — CLI for kalamoi/papyr documentation in JS projects.

      Usage:
        calliope build [options]
        calliope -h | --help
        calliope --version

      Options:
        -c, --config=<json>     The `package.json` file to use.
        -h, --help              Displays this screen and exits.
        -v, --version           Displays this screen and exits.
      '''

fs            = require 'fs'
path          = require 'path'
wrench        = require 'wrench'
{stdout:exec} = require 'execSync'


global <<< require 'prelude-ls'

### -- Helpers ---------------------------------------------------------
read = (pathname) ->
  fs.read-file-sync pathname, 'utf-8'

read-as-json = (pathname) ->
  JSON.parse (read pathname)

write = (pathname, contents) -->
  fs.write-file-sync pathname, contents, 'utf-8'

to-json = JSON.stringify

make-tree = (pathname) ->
  wrench.mkdir-sync-recursive pathname

local-bin = (pathname) ->
  path.resolve __dirname, '../node_modules/.bin', pathname

sanitise-shell-args = (xs) ->
  (map to-json, xs).join ' '

sh = (cmd, ...args) ->
  console.log "\n<> #cmd #{sanitise-shell-args args}"
  exec "#cmd #{sanitise-shell-args args}"

local-sh = (cmd, ...args) ->
  sh (local-bin cmd), ...args


make-kalamoi-config = (pkg) ->
  packages: pkg.calliope?.packages

make-papyr-config = (pkg, entities) -->
  project   : pkg.name
  version   : pkg.version
  template  : pkg.calliope?.template
  copyright : pkg.calliope?.copyright
  output    : pkg.calliope?.output
  apis      : [
    * authors    : ([pkg.author] ++ (pkg.contributors or [])).filter Boolean
      copyright  : pkg.calliope?.copyright
      licence    : pkg.license
      repository : pkg.repository?.url
      entities   : ['.calliope/entities.json']
      examples   : pkg.calliope?.examples or pkg.directories?.example
  ]

### -- Commands --------------------------------------------------------
build-documentation = (options) ->
  console.log "› Using configuration from #{options['--config']}"
  meta = read-as-json options['--config']
  make-tree '.calliope'

  console.log '› Making kalamoi configuration from package.json...'
  write '.calliope/kalamoi.json', to-json (make-kalamoi-config meta)

  console.log '› Generating papyr configuration from package.json...'
  write '.calliope/papyr.json', to-json (make-papyr-config meta, (read '.calliope/kalamoi.json'))

  console.log '› Extracting documentation metadata (kalamoi generate)...'
  write '.calliope/entities.json', (local-sh \kalamoi \generate '.calliope/kalamoi.json')

  console.log '› Building documentation (papyr build)...'
  console.log (local-sh \papyr \build '.calliope/papyr.json')

 

### -- Main ------------------------------------------------------------
{docopt} = require 'docopt'
pkg-meta = require '../package'

let args = docopt doc, version: pkg-meta.version
    args['--config'] = args['--config'] or 'package.json'
    switch
    | args.build => build-documentation args


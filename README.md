# elm-oracle

Elm Oracle intends to be a standalone program that can be used by all editor plugins to query information about a project's source code.

## Installation

You need [node](http://nodejs.org) to install and run elm-oracle.

```
npm install -g elm-oracle
```

## Usage

```
elm-oracle FILE query
  Query for information about a token in an Elm file.

Available options:
  -h,--help                    Show this help text.
```

The return value will be a json array of json objects with information for each value that starts with the query string.

`elm-oracle Main.elm Signal.message` might return:

```json
[
    {
        "name": "message",
        "fullName": "Signal.message",
        "href": "http://package.elm-lang.org/packages/elm-lang/core/latest/Signal#message",
        "signature": "Address a -> a -> Message",
        "comment": "Create a message that may be sent to a `Mailbox` at a later time.\n\nMost importantly, this lets us create APIs that can send values to ports\n*without* allowing people to run arbitrary tasks."
    }
]
```

Whereas `elm-oracle Main.elm Signal.m` might include Signal.mailbox, Signal.map, etc.

If elm-oracle encounters errors, it will return a json array or json objects like:

```json
[{"error": "You did not supply a source file or query."}]
```

## Projects that use elm-oracle

* Vim: [elm-vim](https://github.com/elmcast/elm-vim)
* Atom: [atom-elm](https://github.com/edubkendo/atom-elm)
* Emacs: [elm-mode](https://github.com/jcollard/elm-mode)
* Sublime: [Elm.tmLanguage](https://github.com/deadfoxygrandpa/Elm.tmLanguage)
* LightTable: [elm-light](http://github.com/rundis/elm-light)
* NeoVim: [deoplete-elm](https://github.com/pbogut/deoplete-elm)

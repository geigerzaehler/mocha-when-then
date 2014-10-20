Given, When, Then
=================

[![Build Status](https://travis-ci.org/geigerzaehler/mocha-when-then.svg)](https://travis-ci.org/geigerzaehler/mocha-when-then)

Write **composable and expressive tests** with a promise-based
Given-When-Then DSL for [mocha][].

```coffeescript
describe 'given when then', ->
  
  Given setup
  When  doSomething
  And   doAnotherThing
  Then  check
```

The above example is roughly equivalent to

```coffeescript
describe 'bdd', ->

  beforeEach setup

  it 'then', ->
    doSomething()
    doAnotherThing()
    if check() == false
      throw new Error()
```

Use the package with

```
npm install --save-dev mocha-when-then
mocha --ui mocha-when-then
```

For browsers include the file `./dist/browser-bundle.js`. It includes
the [promise][] library, the [es5-shim][], and exposes the `mocha-when-then` interface as a
UMD module. It assumes that `Mocha` is defined as a global variable.


### Assigning variables

By passing a string to the DSL methods you can **assign variables**, or for
`Then`, pass variables to step.

```coffeescript
Given 'a number', -> return 0
When  'more', 1
When  'evenMore', 2
Then  'more', (more)-> 
  more > @number && @evenMore > more
```

As you can see, the labels will be stripped of any leading 'a'. The
same holds for 'an' and 'the'.

You can also pass constant values to the steps instead of functions.


### `Then` assertions

In addition to executing a step, `Then` also serves as a **simple
assertion** replacement. It will throw an error if the return value of
the given function is `false`. To not prevent you from using you on
expectations it will not throw on other falsey values like `null` or
`undefined`.

```coffeescript
Given 'number', 5
Then 'number', (it)-> it == 5

# This test fails.
Then 'number', (it)-> it == 4
```


### Structuring

We now explain in more detail how the step DSL maps to the default BDD
DSL.

The `Given` function behaves like `beforeEach`. The step is executed
before all tests in the current suite and all sub-suites.

```coffeescript
Then  'number', (it)-> it > 0
Given 'number', 5

describe 'actual value', ->
  Then 'number', (it) it == 5
```

Each `Then` creates a test case. The runner for this test case includes
all `When` steps tha precede it, up to a previous `Then`.

```coffeescript
describe 'when then', ->

  When computeName
  When computeAge
  Then checkName
  Then checkAge

  When computeStars
  Then checkStars

describe 'bdd', ->

  it '', ->
    computeName()
    computeAge()
    checkName()

  it '', ->
    computeName()
    computeAge()
    checkAge()

  it '', ->
    computeStars()
    checkStars()
```

The `And` function serves as an alias for the previously used keyword.

```coffeescript

describe 'simple', ->
  Given name
  Given age
  Then checkName
  Then checkAge

describe 'with "And"', ->
  Given name
  And age
  Then checkName
  And checkAge
```

### Promises

All functions passed to the DSL may return promises. The next step is
only executed when the promise is fullfilled.

```coffeescript
Given 'zero', -> makePromise(0)
When  'more', makePromise(1)
Then   -> @more > @zero
```


### Test labels

Since each `Then` creates a test case it has to provide a label for the
test.

If you pass a single function to `Then`, the interface will inspect the
code of that function and extract the expression that is returned last.
This works well for simple tests like

```coffeescript
# 'then this.counter == 5'
Then -> @counter == 5
```

You can set the label explicitly by passing a string to `Then`.

```coffeescript
# 'then the counter is 5'
Then 'the counter is 5', -> @counter == 5
```

Finally, if a given function has a `label` property, it is used to
contruct the label.

```coffeescript
shouldEqual5 = (it)-> it == 5
shouldEqual5.label = 'should equal 5'

# 'then the counter should equal 5'
Then 'the counter', shouldEqual5
```

This makes it perfect for use with [chai-builder][].


### Multiple data

Not yet implemented.

```coffeescript
GivenAny 'name' ['alice', 'adam', 'avery']
Then 'name', (n)-> n[0] == 'a'

GivenAny 'number', -> (i) -> i < 5 && i
Then 'name', (n)-> n < 5 && n >= 0
```


[mocha]: http://visionmedia.github.io/mocha/
[chai-builder]: https://github.com/geigerzaehler/chai-builder
[es5-shim]: https://www.npmjs.org/package/es5-shim
[promise]: https://www.npmjs.org/package/promise

Given, When, Then
=================

Write **composable and expressive tests** with a promise-based
Given-When-Then DSL for [mocha][].

To get started, install the package and run your tests with the
`mocha-steps` ui

A test with the steps ui looks like this.

  describe 'given when then', ->
    
    Given setup
    When  doSomething
    Then  check

To run it, install the the package with `npm install --save-dev
mocha-steps` and run

  mocha --ui mocha-steps

The above example is roughly equivalent to

  describe 'bdd', ->

    beforeEach setup

    it '', ->
      doSomething()
      if check() == false
        throw new Error()

In addition to executing a step, `Then` also serves as a very **simple
assertion** replacement. It will throw an error if the return value of
the given function is `false`. To not prevent you from using you on
expectations it will not throw on other falsey values like `null` or
`undefined`.

By passing a string to the DSL methods you can **assign variables**, or for
`Then`, pass variables to step.

  Given 'a number', -> return 0
  When  'more', 1
  When  'evenMore', 2
  Then  'more', (more)-> 
    more > @number && @evenMore > more

As you can see, the labels will be stripped of any leading 'a'. The
same holds for 'an' and 'the'.

You can also pass constant values to the steps instead of functions.


### Structuring

We now explain in more detail how the step DSL maps to the default BDD
DSL.

The `Given` function behaves like `beforeEach`. The step is executed
before all tests in the current suite and all sub-suites.

  Then  'number', (it)-> it > 0
  Given 'number', 5

  describe 'actual value', ->
    Then 'number', (it) it == 5

Each `Then` creates a test case. The runner for this test case includes
all `When` steps tha precede it, up to a previous `Then`.

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


### Promises

All functions passed to the DSL may return promises. The next step is
only executed when the promise is fullfilled.

  Given 'zero', -> makePromise(0)
  When  'more', makePromise(1)
  Then   -> @more > @zero


### Test labels

Since each `Then` creates a test case it has to provide a label for the
test.

If you pass a single function to `Then`, the interface will inspect the
code of that function and extract the expression that is returned last.
This works well for simple tests like

  # 'then this.counter == 5'
  Then -> @counter == 5

You can set the label explicitly by passing a string to `Then`.

  # 'then the counter is 5'
  Then 'the counter is 5', -> @counter == 5

Finally, if a given function has a `specLabel` property, it is used to
contruct the label.

  shouldEqual5 = (it)-> it == 5
  shouldEqual5.specLabel = 'should equal 5'

  # 'then the counter should equal 5'
  Then 'the counter', shouldEqual5


### Multiple data

Not yet implemented.

  GivenAny 'name' ['alice', 'adam', 'avery']
  Then 'name', (n)-> n[0] == 'a'

  GivenAny 'number', -> (i) -> i < 5 && i
  Then 'name', (n)-> n < 5 && n >= 0

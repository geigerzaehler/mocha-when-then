Promise = require('promise')
Mocha = require('mocha')

module.exports \
= Mocha.interfaces['mocha-when-then'] \
= Mocha.interfaces['when-then'] \
= (suite)->
  suites = []

  suite.on 'pre-require', (context, file, mocha) ->

    context.describe = (title, fn) ->
      suites.push(suite)

      context.And = ->
        throw Error('"And" keyword must be used after'
                    '"Given", "When", or "Then"')

      suite = Mocha.Suite.create(suite, title)
      suite.beforeAll -> this.assigns ||= {}
      suite.afterEach -> this.assigns = {}
      suite.whens = []
      suite.thens = []
      fn.call(suite)
      buildStepsTest(suite)
      suite = suites.pop()


    context.describe.only = (title, fn)->
      context.describe(title, fn)
      mocha.grep suite.fullTitle()


    context.Given = (name, executor)->
      context.And = context.Given
      step = Step(name, executor)
      suite.beforeEach -> step(this.assigns)


    context.When = (name, executor)->
      context.And = context.When
      buildStepsTest(suite)
      suite.whens.push(Step(name, executor))


    context.Then = (name, executor)->
      context.And = context.Then
      suite.thens.push(TestStep(name, executor))

    # Set by Given, When, Then
    context.And = undefined


# Creates a function that returns a promise
#
# The returned function accepts an object that is used to store
# variable assignments.
#
# If `executor` is a function the step calls it on the assignments (so
# they can be accesed through the `this` keyword) and its return
# value is coerced into a promise.
#
# Otherwise, the step just returns the excutor after coercing it into
# a promise.
#
# If the `name` is given, the corresponding property on the
# assignemnts is set to the resolved value of the executor.
#
Step = (name, executor)->
  {executor, name} = stepSpec(name, executor)
  (assigns)->
    executor.call(assigns)
    .then (val)=> assigns[name] = val if name


# Similar to `Step`.
#
# The value provided by the executor is tested for thruthiness. If
# this fails an error is raised and the step returns a rejected
# promise.
#
# If `name` is given, the corresponding property of the assignment
# argument to the step is passed to the executor.
#
TestStep = (label, fn)->
  {executor, name} = stepSpec(label, fn)
  run = (assigns)->
    executor.call(assigns, assigns[name] if name)
    .then (result)=>
      if result == false
        throw Error "Then statement returned 'false'"
  run.label = specLabel(fn || label, name)
  return run


# Return a function that runs the steps on after another.
#
# The function chains the promises returned by the steps and returns
# the final promise.
#
# The function uses the `assigns` property of the object it is called
# on for step assignments.
joinSteps = (steps)->
  steps = steps.slice()
  assigns = null
  next = ->
    if step = steps.shift()
      step(assigns).then(next)
  ->
    assigns = this.assigns
    next()

# Add a test from the `When` and `Then` steps defined on the suite.
buildStepsTest = (suite)->
  {whens, thens} = suite
  for t in thens
    runner = joinSteps(whens.concat([t]))
    suite.addTest new Mocha.Test(t.label || '', runner)
  if thens.length
    suite.whens = []
    suite.thens = []


# Utility functions

# Normalize arguments from the DSL to step specifications
# 
# @param {string} [label]
# @param {Function|Object} executor
#
stepSpec = (label, executor)->
  if not executor?
    executor = label
    label = null
  if label
    name = label.replace(/^(an?|the)\s+|(is|are)$/, '') || label
  executor = factory(executor)
  return {name, executor}

# Takes a function or a value and returns a function that returns a
# promise.
#
# If `fn` has a `test` method, it is called when the factory is
# executed.
factory = (fn)->
  if typeof fn.test == 'function'
    (args...)-> Promise.resolve(fn.test(args...))
  else if typeof fn == 'function'
    (args...)-> Promise.resolve(fn.apply(this, args))
  else
    -> Promise.resolve(fn)

# Create an assertion label for a function or value and a variable
# name.
specLabel = (fn, name)->
  label = ['then']
  if name
    label.push name

  if fn.label?
    label.push fn.label
  else if typeof fn == 'function'
    label.push lastReturnExpression(fn)
  else
    label.push 'is', fn

  return label.join(' ')

# Return the string of the expression passed to the last return
# statement in the function.
lastReturnExpression = (fn)->
  fnStart = /^\s*function\s*\([^)]*\)\s*{\s*/
  blockEnd = /\s*}\s*$/
  returnExpr = /\s*return\s+([^;]+)\s*;\s*$/

  expr = fn.toString()
    .replace(fnStart, '')
    .replace(blockEnd, '')
    .match(returnExpr)
  return expr and expr[1]

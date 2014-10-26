{expect} = require('chai')
Promise = require('promise')

describe.only 'Given When Then', ->

  Given -> @number = 5
  When  -> @number += 2
  Then  -> expect(@number).to.equal(7)


  describe 'nested given', ->
    Then -> expect(@number).to.equal(5)


  describe 'assignment names', ->
    Given 'string', -> 'hello'
    When  'string', -> @string += ' world'
    Then  'string', (it)-> expect(it).to.equal('hello world')

    describe 'verbose', ->
      Given 'the string is', -> 'hello'
      Then  'string', (it)-> expect(it).to.equal('hello')

    describe 'label', ->
      Given 'number', 5
      Then 'number', (it)-> expect(it).to.equal(5)

      Given 'test titles', => this.tests.map (t)-> t.title
      Then  'test titles', (titles)->
        expect(titles).to.include('then number expect(it).to.equal(5)')

    describe.only 'camel case', ->
      Given 'my new-number', 5
      Then -> @myNewNumber == 5


  describe 'multiple thens and whens', ->

    When 'bool',   true
    Then 'bool',   (it)-> expect(it).to.be.true
    Then 'string', (it)-> expect(it).to.be.undefined

    When 'string', 'hey'
    Then 'string', (it)-> expect(it).to.equal('hey')
    Then 'bool',   (it)-> expect(it).to.be.undefined

    Then => expect(this.tests).to.have.length(5)

  describe '"And" keyword', ->

    When 'bool', true
    And  'string', 'hi'
    Then 'bool', (it)-> expect(it).to.be.true
    And  'string', (it)-> expect(it).to.equal('hi')

    Then => expect(this.tests).to.have.length(3)

  describe 'given constant value', ->
    Given 'number', 2
    Then -> expect(@number).to.equal(2)


  describe 'promises', ->
    Given 'string', Promise.resolve('hey')
    When  'string', -> Promise.resolve(@string + ' ho')
    Then  'string', (it)-> expect(it).to.equal('hey ho')


    describe 'Then.value', ->
      Given.value 'string', Promise.resolve('hey')
      When.value 'rejected', Promise.reject(new Error('timeout'))
      When.value 'string', -> @string.then (s)-> s + ' ho'
      Then 'string', (it)-> expect(it).to.equal('hey ho')

  describe 'tester', ->

    shouldBeTrue = ->
    shouldBeTrue.test = (it)->
        expect(it).to.be.true
        this.ran = true
    shouldBeTrue.label = 'should be true'

    Given 'boolean', true
    Then  'boolean', shouldBeTrue
    Then -> expect(shouldBeTrue.ran).to.be.true

    Given 'test titles', => this.tests.map (t)-> t.title
    Then  'test titles', (titles)->
      expect(titles).to.include('then boolean should be true')

    Given 'string', 'hey'
    Then  'string', /^h/


describe 'do not run', ->
  Then false

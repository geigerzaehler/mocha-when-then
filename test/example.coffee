{expect} = require('chai')
Promise = require('promise')

describe 'Given When Then', ->

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
      Then  'test titles', ->
        expect(titles).to.include('then number exepect(it).to.equal(5)')


  describe 'multiple thens and whens', ->

    When 'bool',   true
    Then 'bool',   (it)-> expect(it).to.be.true
    Then 'string', (it)-> expect(it).to.be.undefined

    When 'string', 'hey'
    Then 'string', (it)-> expect(it).to.equal('hey')
    Then 'bool',   (it)-> expect(it).to.be.undefined

    Then => expect(this.tests).to.have.length(5)


  describe 'given constant value', ->
    Given 'number', 2
    Then -> expect(@number).to.equal(2)


  describe 'promises', ->
    Given 'string', Promise.resolve('hey')
    When  'string', -> Promise.resolve(@string + ' ho')
    Then  'string', (it)-> expect(it).to.equal('hey ho')


  describe 'tester', ->

    shouldBeTrue =
      test: (it)->
        expect(it).to.be.true
        this.ran = true
      specLabel: 'should be true'

    Given 'boolean', true
    Then  'boolean', shouldBeTrue
    Then -> expect(shouldBeTrue.ran).to.be.true

    Given 'test titles', => this.tests.map (t)-> t.title
    Then  'test titles', ->
      expect(titles).to.include('then boolean should be true')

    Given 'string', 'hey'
    Then  'string', /^h/


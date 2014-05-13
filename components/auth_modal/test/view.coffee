benv       = require 'benv'
sinon      = require 'sinon'
Backbone   = require 'backbone'
sd         = require('sharify').data
mediator   = require '../../../lib/mediator'

describe 'AuthModalView', ->

  before (done) ->
    benv.setup =>
      benv.expose { $: benv.require 'jquery' }
      Backbone.$ = $
      $('body').html $ "<div id='fixture'></div>"
      @AuthModalView = require '../view'
      sinon.stub @AuthModalView.prototype, 'initialize'
      done()

  after ->
    benv.teardown()

  beforeEach ->
    @view = new @AuthModalView el: $('#fixture')
    sinon.stub Backbone, 'sync'

  afterEach ->
    Backbone.sync.restore()

  describe '#preInitialize', ->

    it 'can render custom copy', ->
      @view.preInitialize copy: 'Sign up to foobar.'
      @view.templateData.copy.should.include 'Sign up to foobar'

    it 'can render custom redirect', ->
      @view.redirectTo = '/awesome-fair'
      @view.preInitialize copy: 'Sign up to foobar.'
      @view.templateData.redirectTo.should.include '/awesome-fair'

    it 'passes the pathname to the template', ->
      _location = global.location
      global.location = pathname: 'foobarbaz'
      @view.preInitialize {}
      @view.templateData.pathname.should.equal 'foobarbaz'
      global.location = _location

  describe '#submit', ->

    beforeEach ->
      sinon.stub location, 'reload'
      @view.validateForm = -> true
      @view.state = new Backbone.Model

    afterEach ->
      location.reload.restore()

    it 'submits to signup when in that mode', ->
      @view.redirectTo = 'foobarbaz'
      @view.state.set mode: 'register'
      @view.submit { preventDefault: -> }
      Backbone.sync.args[0][1].url.should.include 'users/invitation/accept'
      Backbone.sync.args[0][2].success {}
      location.href.should.include 'foobarbaz'

    it 'submits to signup with custom redirect url', ->
      @view.redirectTo = '/awesome-fair'
      @view.state.set mode: 'register'
      @view.submit { preventDefault: -> }
      Backbone.sync.args[0][1].url.should.include 'users/invitation/accept'
      Backbone.sync.args[0][2].success {}
      location.href.should.include '/awesome-fair'

    it 'sets a cookie named destination with whatever the passed in destination is', ->
      Cookies = benv.require 'cookies-js'
      @view.destination = '/artist/some-guy/follow'
      @view.state.set mode: 'register'
      @view.submit { preventDefault: -> }
      Backbone.sync.args[0][2].success {}
      Cookies.get('destination').should.equal @view.destination

    it 'creates a singned_in cookie', ->
      Cookies = benv.require 'cookies-js'
      @view.state.set mode: 'login'
      @view.submit { preventDefault: -> }
      Backbone.sync.args[0][2].success {}
      Cookies.get('signed_in').should.equal 'true'

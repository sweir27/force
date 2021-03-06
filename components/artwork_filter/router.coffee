_ = require 'underscore'
qs = require 'querystring'
Backbone = require 'backbone'
ArtworkFilterView = require './view.coffee'
sections = require './sections.coffee'
booleans = require './booleans.coffee'
whitelist = _.keys(sections).concat(booleans).concat(['sort'])

module.exports = class ArtworkFilterRouter extends Backbone.Router
  initialize: (options = {}) ->
    @view = new ArtworkFilterView options
    @view.on 'navigate', => @navigate @currentFragment()
    @navigateBasedOnParams()

  currentFragment: ->
    fragment = location.pathname
    fragment += "?#{params}" if params = @params()
    fragment

  params: ->
    qs.stringify _.pick @view.filter.selected.attributes, @view.filter.selected.visibleAttributes()

  searchString: ->
    location.search.substring(1)

  navigateBasedOnParams: ->
    params = _.pick qs.parse(@searchString()), whitelist...
    @view.filter.by params unless _.isEmpty(params)

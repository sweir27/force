_ = require 'underscore'
{ API_URL } = require('sharify').data
Sales = require './sales.coffee'
Auction = require '../models/auction.coffee'

module.exports = class Auctions extends Sales
  model: Auction

  url: "#{API_URL}/api/v1/sales?is_auction=true"

  previews: ->
    @chain()
    .select (auction) ->
      auction.isAuction() and auction.isPreview()
    .sortBy (auction) ->
      Date.parse auction.get('start_at')
    .value()

  opens: ->
    @chain()
    .select (auction) ->
      auction.isAuction() and auction.isOpen()
    .sortBy (auction) ->
      # hardcode sotheby's auction to appear at the top
      if auction.id in ['input-output', 'input-slash-output']
        return -1000000000000000000000
      else
        -(Date.parse auction.get('end_at'))
    .value()

  closeds: ->
    @chain()
    .select (auction) ->
      # Includes auction promos
      (auction.isAuction() or auction.isAuctionPromo()) and auction.isClosed()
    .sortBy (auction) ->
      -(Date.parse auction.get('end_at'))
    .value()

  auctions: ->
    @select (auction) ->
      auction.isAuction()

  currentAuctionPromos: ->
    @chain()
    .select (auction) ->
      auction.isAuctionPromo() and not auction.isClosed()
    .sortBy (auction) ->
      -(Date.parse auction.get('end_at'))
    .value()

  next: ->
    _.first @previews()

{ Model } = require 'models/base'
{ NodeMetadata } = require 'models/metadata/node'
{ Users } = require('collections/user')
{ Posts } = require('collections/post')

class exports.Node extends Model

    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata parent:this, id:nodeid
        # Subscribers:
        @users    = new Users parent:this
        @posts   ?= new Posts parent:this

        # TODO: only if !subscribed and therefore covered by MAM

    toJSON: (full) ->
        result = super
        if full
            result.metadata = @metadata.toJSON()
        result

    fetch: ->
        app.handler.data.get_node_subscriptions @get 'nodeid'

    # I am very afraid of the dead. They walk.
    update: -> # api function - every node should be updateable

    push_subscription: (subscription) ->
        switch subscription.subscription
            when 'subscribed'
                @users.get_or_create id: subscription.jid
            when 'unsubscribed', 'none'
                if (user = @users.get subscription.jid)
                    @users.remove user

        # TODO: needed by?
        @trigger "subscription:node:#{subscription.node}", subscription

    push_post: (post) ->
        @trigger 'post', post

    push_metadata: (metadata) ->
        @metadata.save metadata


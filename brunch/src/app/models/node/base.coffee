{ Model } = require 'models/base'
{ NodeMetadata } = require 'models/metadata/node'
{ Users } = require('collections/user')
{ Posts } = require('collections/post')

##
# Attributes:
# * id is only the tail for a channel (eg. posts)
# * nodeid is the full node name (eg. /user/astro@spaceboyz.net/posts)
class exports.Node extends Model

    initialize: ->
        nodeid = @get 'nodeid'
        @metadata = new NodeMetadata parent:this, id:nodeid
        # Subscribers:
        @users    = new Users parent:this
        @posts   ?= new Posts parent:this

    toJSON: (full) ->
        result = super
        if full
            result.metadata = @metadata.toJSON()
        result

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

    push_affiliation: (affiliation) ->
        if (user = @users.get affiliation.jid)
            # TODO: how to store affiliations?
            do ->

    push_post: (post) ->
        @trigger 'post', post

    push_metadata: (metadata) ->
        @metadata.save metadata

        if app.users.current.channels.get(@get 'nodeid')?
            @metadata_synced = yes
        else
            @metadata_synced = no

    push_error: (error) ->
        @error =
            condition: error.condition
            text: error.text
        @trigger 'error', error

    push_posts_rsm_last: (rsm_last) ->
        # No RSM support or
        # same <last/> as previous page
        if not rsm_last or
           rsm_last is @posts_rsm_last
            @posts_end_reached = yes
        @posts_rsm_last = rsm_last

    # If we are subscribed, newer/updated posts will come in
    # through notifications. No need to poll again.
    # FIXME: clear on xmpp disconnect
    on_posts_synced: ->
        if app.users.current.channels.get(@get 'nodeid')?
            @posts_synced = yes
        else
            @posts_synced = no

    can_load_more: ->
        not @posts_end_reached

    on_subscribers_synced: ->
        if app.users.current.channels.get(@get 'nodeid')?
            @subscribers_synced = yes
        else
            @subscribers_synced = no
        console.warn "on_subscribers_synced", @subscribers_synced

    push_subscribers_rsm_last: (rsm_last) ->
        console.warn "push_subscribers_rsm_last", rsm_last, @subscribers_rsm_last
        if not rsm_last or
           rsm_last is @subscribers_rsm_last
            @subscribers_end_reached = yes
        @subscribers_rsm_last = rsm_last

    can_load_more_subscribers: ->
        not @subscribers_end_reached

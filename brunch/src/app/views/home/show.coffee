{ ChannelView } = require 'views/channel/show'
{ Channels } = require 'collections/channel'
{ Sidebar } = require 'views/sidebar/show'

class exports.HomeView extends Backbone.View
    template: require 'templates/home/show'

    initialize: ->
        @el = $(@template())
        @bind 'show', @show
        @bind 'hide', @hide
        @current = undefined
        # sidebar entries
        @views = {} # this contains the channelnode views
        @timeouts = {} # this contains the channelview remove timeouts
        @channels = new Channels
        @channels.comparator = (channel) ->
            a = new Date(channel.last_touched)
            b = new Date(channel.nodes.get('posts')?.posts.at(0)?.get_last_update() or 0)
            a.getTime() - b.getTime()

        app.users.current.channels.bind 'add', (channel) =>
            @channels.get_or_create channel
        app.users.current.channels.forEach (channel) =>
            @channels.get_or_create channel
        # TODO: when all posts have come in, recheck if we already
        # scrolled to bottom again!

        @channels.bind 'remove', @remove_channel_view
        # FIXME: let the ChannelView be created on-demand, they're
        # rendering much too often during startup. mrflix supposedly says
        #@channels.bind 'add',    @new_channel_view
        # if we already found a view in the cache
        #@current?.el.show()

        @sidebar = new Sidebar parent:this

        channel = app.users.current.channels.get(app.users.target.get('id'))
        if channel?
            @setCurrentChannel channel

        $('body').removeClass('start').append @el

        @render()
        @el.show()

        # Set up InfiniteScrolling™ when reaching the bottom
        $(window).scroll @on_scroll

    new_channel_view: (channel) =>
        channel = @channels.get_or_create channel, silent:yes
        unless (view = @views[channel.cid])
            view = new ChannelView model:channel, parent:this
            @views[channel.cid] = view
            @el.append view.el
            view.trigger 'hide'
        view

    remove_channel_view: (channel) =>
        delete @timeouts[channel.cid]
        delete @views[channel.cid]

    setCurrentChannel: (channel) =>
        @current?.trigger 'hide'
        # Throw away if current user did not subscribe:
        oldChannel = @current?.model
        if oldChannel and not app.users.current.channels.get(oldChannel.get('id'))?
            if @timeouts[oldChannel.cid]?
                clearTimeout @timeouts[oldChannel.cid]
            @timeouts[oldChannel.cid] = setTimeout ( =>
                @channels.remove oldChannel
            ), 15*60*1000 # 15 min

        #@channels.touch channel, silent:true
        #@sidebar.bubble channel

        unless (@current = @views[channel.cid])
            @current = @new_channel_view channel
        if @timeouts[@current.model.cid]?
            clearTimeout @timeouts[@current.model.cid]
            delete @timeouts[@current.model.cid]
        # Indicate url change without routing:
        app.router.navigate @current.model.get('id'), false

        title = @current.model.nodes.get('posts')?.metadata.get('title')?.value
        document.title = title or @current.model.get('id')

        @sidebar.setCurrentEntry channel
        @current.trigger 'show'

        # when scrolled to the bottom, cause loading of more posts via
        # RSM because we are showing too few of them.
        #
        # example: so far only retrieved comments to an older post
        # which are all hidden, because that parent post is on a
        # further RSM page.
        @on_scroll()

    render: ->
        @current?.render()
        @sidebar.render()

    show: =>
        @render()
        @sidebar.moveIn()
        @current?.trigger 'show'

    hide: =>
        @sidebar.moveOut()
        @current?.trigger 'hide'

    on_scroll: =>
        if $(window).scrollTop() >= $(document).height() - $(window).height() * 1.1
            @current?.on_scroll_bottom?()
        no

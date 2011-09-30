

exports.getBrowserPrefix = getBrowserPrefix = ->
    regex = /^(Moz|Webkit|Khtml|O|ms|Icab)(?=[A-Z])/
    tester = document.getElementsByTagName("script")[0]
    prefix = ""
    for prop of tester.style
        if regex.test(prop)
            prefix = prop.match(regex)[0]
            break
    prefix = "Webkit"  if "WebkitOpacity" of tester.style
    unless prefix is ""
        "-" + prefix.charAt(0).toLowerCase() + prefix.slice(1) + "-"
    else
        ""

exports.transEndEventNames = transEndEventNames =
    '-webkit-transition' : 'webkitTransitionEnd'
    '-moz-transition' : 'transitionend'
    '-o-transition' : 'oTransitionEnd'
    'transition' : 'transitionEnd'

exports.transitionendEvent = transEndEventNames[getBrowserPrefix()+'transition']

exports.gravatar = (mail, opts) ->
    hash = MD5.hexdigest mail?.toLowerCase() or ""
    "https://secure.gravatar.com/avatar/#{hash}?" + $.param(opts)

exports.EventHandler = (handler) ->
    return (ev) ->
        ev.preventDefault()
        handler.apply(this, arguments)
        no

# /user/u@catz.net/posts → ["/user/u@catz.net/", "u@catz.net"]
NODEID_TO_USER_REGEX = /\/user\/([^\/]+@[^\/]+)\//
exports.nodeid_to_user = (nodeid) ->
    nodeid?.match(NODEID_TO_USER_REGEX)?[1] # jid


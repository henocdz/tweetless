TWITTER_CLIENT_ID = 'lWOzgSMmYPd5zQmvWxmyL82Bo'
NETWORK = 'twitter'



$ ->

    login_btn = $('#login_btn')
    logout_btn = $('#logout_btn')
    feed = $('#feed')
    tweetsList = []

    hello.init {
        twitter: TWITTER_CLIENT_ID
    }, {
        redirect_uri: ''
    }

    renderTweet = (id, text, date)->
        html = $("""
        <div class="tweet">
            <p>#{text}</p>
            <a href="#" class="delete-link" data-tweet-id="#{id}">Eliminar</a>
        </div>""")
        return html

    retrieveTweets = (callback, max_id)->
        max_id = max_id || null
        opts = {
            include_rts: false,
            exclude_replies: true,
            count: 200
        }

        if max_id
            opts['max_id'] = max_id

        hello('twitter').api('https://api.twitter.com/1.1/statuses/user_timeline.json', 'get', opts).then (tweets)->
            if callback
                callback(tweets)
        ,(e)->
            if callback
                callback(null, e)

    deleteTweet = (callback, id)->
        uri = "https://api.twitter.com/1.1/statuses/destroy/#{id}.json"
        console.log(uri)
        hello('twitter').api(uri, 'post').then (res)->
            if callback
                callback(res)
        ,(e)->
            if callback
                callback(null, e)

    total = 0
    listTweets = (tweets, e)->
        if not e and tweets
            total += tweets.length
            if tweets.length > 0
                oldest_tweet = tweets[tweets.length - 1]
                max_id = oldest_tweet.id
            first_tweet = tweets[0]
            last_tweet = tweets[tweets.length - 1]

            for tweet in tweets
                feed.append(renderTweet(tweet.id_str, tweet.text))
            if total < 2000 and not (first_tweet.id is last_tweet.id)
                retrieveTweets(listTweets, max_id)
                
        else            
            console.log(e)

    updateTweets = ->
        total = 0
        retrieveTweets(listTweets)

    isLoggedIn = (network)->
        session = hello(network).getAuthResponse()
        current_time = (new Date()).getTime() / 1000
        session and session.access_token and session.expires > current_time

    switchButtons = (out)->
        if out
            login_btn.show()
            logout_btn.hide()
        else
            logout_btn.show()
            login_btn.hide()

    logout_btn.on 'click', (e)->
        e.preventDefault();
        hello.logout('twitter').then ->
            switchButtons(true)
        ,(e)->
            alert('Error')

    login_btn.on 'click', (e)->
        e.preventDefault();
        hello.login('twitter').then ->
            switchButtons()
            retrieveTweets(listTweets)
        ,(e)->
            alert('Error')

    feed.on 'click', 'a.delete-link', (e)->
        e.preventDefault()
        that = $(@)
        id = that.data('tweet-id') || null
        if id
            deleteTweet((res, e)->
                console.log res
                if not e and not res.errors
                    that.parent('div').slideUp()
            , id)


    if isLoggedIn('twitter')
        switchButtons()
        retrieveTweets(listTweets)
        return @
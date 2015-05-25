# OpenTwitter

This is a simple Twitter app to read and compose Tweets.

Time spent: `16.5` hours

## Features

### Required

- [x] User can sign in using OAuth login flow
- [x] User can view last 20 tweets from their home timeline
- [x] The current signed in user will be persisted across restarts
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.  In other words, design the custom cell with the proper Auto Layout settings.  You will also need to augment the model classes.
- [x] User can pull to refresh
- [x] User can compose a new tweet by tapping on a compose button.
- [x] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [x] User can retweet, favorite, and reply to the tweet directly from the timeline feed.

### Optional

- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [ ] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User should be able to unfavorite and should decrement the favorite count.
- [ ] User should be able to unretweet and should decrement the retweet count.
- [x] Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

## Instructions

To run this app, you'll need to create a `secrets.plist` resource file and populate it with your Twitter API key and secret in `consumer_key` and `consumer_secret` properties.

## Walkthrough

![Video Walkthrough](...)


## Credits
* [Twitter API](https://dev.twitter.com/rest/public)
* [Carthage](https://github.com/Carthage/Carthage)
* [OAuthSwift](https://github.com/dongri/OAuthSwift)
* [Alamofire](https://github.com/Alamofire/Alamofire)

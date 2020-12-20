#!/usr/local/bin/python3

import tweepy
import requests
import sys
import pyjq


# Authenticate to Twitter
auth = tweepy.OAuthHandler("", "")
auth.set_access_token("","")
api = tweepy.API(auth, parser=tweepy.parsers.JSONParser())

# Tags
tags = [ 'openbanking', 'apifirst', 'devops', 'cloudfirst', 'microservices', 'apigateway', 'oauth', 'swagger', 'raml', 'openapis' ] 
for tag in tags: 
    results = api.search(q={tag}, result_type='recent', count=100, tweet_mode='extended')

# All 
parse = pyjq.all( '.statuses[] | "\(.user.screen_name) \(.user.followers_count) \(.entities.hashtags[].text) \(.lang) \(.created_at)"', results) 

#To file
f = open('filename.txt', 'a')
for i in parse:
    f.write(i + '\n')
f.close()

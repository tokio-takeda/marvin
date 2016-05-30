# Desciption:
#   manipulate slack channels. create or archive
#
# Configuration:
#   SLACK_API_KEY - Your slack API key
#
# Commands:
#   create <channel name> - Create channel

slack_api_key = process.env.SLACK_API_KEY

module.exports = (robot) ->
  Slack = require 'slack-node'
  slack = new Slack process.env.SLACK_API_TOKEN

  robot.hear /^create (.*)/i, (msg) ->
    channel = "#{msg.match[1]}"
    current = msg.message.room
    userId = msg.user.id

    getChannelFromName current, (err, currentId) ->
      if err
        return msg.send err

      newChannelName = "#{channel}"

      slack.api "channels.create", name: newChannelName, (err, response) ->
        if err
          return msg.send err

        newId = response.channel.id
        postMessage newId, "created from " + currentId,
        postLink newId, currentId
        inviteUser userId, newId

        msg.send "Created!"

  getUsersInChannel = (id, callback) ->
    slack.api "channels.info", channel: id, (err, response) ->
      if err
        return callback(err)

      callback null, response.channel.members

  getChannelFromName = (channelName, callback) ->
    for val, i in robot.adapter.client.channels
      if val.name == channelName
        return callback null, val.id

    return callback err

  postMessage = (to, message) ->
    slack.api "chat.postMessage", channel: to, text: message, (err, response) ->
      if err
        msg.send err

  postLink = (channelId, currentId) ->
    slack.api "chat.postMessage", channel: currentId, text: "<##{channelId}>", (err, response) ->
      if err
        msg.send err

  inviteUser = (userId, channelId) ->
    slack.api "channels.invite", channel: channelId, user: userId, (err, response) ->
      if err
        msg.send err

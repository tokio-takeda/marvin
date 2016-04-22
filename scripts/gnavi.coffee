# Description:
#   Get restaurant data from Gurunavi API
#
# Configuration:
#   GNAVI_API_KEY - Your gnavi API key
#
# Commands:
#   hubot gnavi <address> <query(,query2)> - search restaurant by <address> and optional free word (max 10 words)

gnavi_api_key = process.env.GNAVI_API_KEY

module.exports = (robot) ->
  robot.respond /(gnavi )(.+)/i, (msg) ->
    args = msg.match[2].trim().split(/\s/)

    address = args[0]

    url = 'http://api.gnavi.co.jp/RestSearchAPI/20150630/?keyid='
    url = url + gnavi_api_key
    url = url + '&format=json&address='
    url = url + encodeURIComponent(address)
    if args.length == 2
      url = url + '&freeword='
      url = url + encodeURIComponent(args[1])
    url = url + '&hit_per_page=3'

    console.log url

    msg.http(url)
      .get() (err, res, body) ->
        if err
          msg.send err
          return

        result = JSON.parse body

        if result.total_hit_count > 0
          for item in result.rest
            msg.send item.url
          return

        msg.send result.error.message

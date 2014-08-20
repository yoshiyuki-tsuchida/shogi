# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:

module.exports = (robot) ->

  play     = false
  request  = false
  sente    = null
  gote     = null
  tesuu    = 0
  sentemochi = []
  gotemochi  = []
  url      = ""
  kifu     = []
  bord     = [
    ["l","n","s","g","k","g","s","n","l"],
    [" ","r"," "," "," "," "," ","b"," "],
    ["p","p","p","p"," ","p","p","p","p"],
    [" "," "," "," ","p"," "," "," "," "],
    [" "," "," "," "," "," "," "," "," "],
    [" "," ","P"," "," "," "," "," "," "],
    ["P","P"," ","P","P","P","P","P","P"],
    [" ","B"," "," "," "," "," ","R"," "],
    ["L","N","S","G","K","G","S","N","L"]
  ]
  bind =
    "sente" :
      "歩" : "P"
      "香" : "L"
      "桂" : "N"
      "銀" : "S"
      "金" : "G"
      "角" : "B"
      "飛" : "R"
      "玉" : "K"
    "gote" :
      "歩" : "p"
      "香" : "l"
      "桂" : "n"
      "銀" : "s"
      "金" : "g"
      "角" : "b"
      "飛" : "r"
      "玉" : "k"



  robot.respond /(.+)\+\+$/i, (msg) ->
    user = msg.match[1]

    if not robot.brain.data[user]
      robot.brain.data[user] = 0

    robot.brain.data[user]++
    robot.brain.save()

    msg.send "#{user}が集めた「ありがとう」は#{robot.brain.data[user]}個"


  robot.respond /shogi new/i, (msg) ->
    if play == false
      if request == false
        sente = msg.message.user.name
        request = true
        msg.send "#{sente}が先手。対戦相手待ち。"
      else
        msg.send "#{sente}からの対戦要求があります。『at_grandma shogi accept』で対戦要求を受けます。"
    else
      url = convert(bord)
      msg.send "http://sfenreader.appspot.com/sfen?sfen=#{url}%20b%20-%2011"
      msg.send "▲#{sente}と△#{gote}が対戦中です。"


  robot.respond /shogi accept/i, (msg) ->
    if play == false
      if request == false
        msg.send "対戦要求がありません。『at_grandma shogi new』で対戦要求を出せます。"
      else
        gote = msg.message.user.name
        request = false
        play    = true
        msg.send "▲#{sente}と△#{gote}の対戦。"
    else
      url = convert(bord)
      msg.send "http://sfenreader.appspot.com/sfen?sfen=#{url}%20b%20-%2011"
      msg.send "▲#{sente}と△#{gote}が対戦中です。"


  robot.respond /shogi init/i, (msg) ->
    play     = false
    request  = false
    sente    = null
    gote     = null
    tesuu    = 0
    sentemochi = []
    gotemochi  = []
    url      = ""
    kifu     = []
    msg.send "対局を初期化しました。"

  convert = (now_bord) ->
    url = []
    for line in now_bord
      counted_space_line = count_space(line)
      url.push(counted_space_line.join(""))
    encodeURIComponent(url.join("/"))

  count_space = (line) ->
    counted_space_line = []
    space_count = 0
    for element in line
      if element == " "
        space_count++
      else
        if space_count > 0
          counted_space_line.push(space_count)
          space_count = 0
        counted_space_line.push(element)
    if space_count > 0
      counted_space_line.push(space_count)
    counted_space_line

  robot.respond /test/i, (msg) ->
    msg.send "#{url}"


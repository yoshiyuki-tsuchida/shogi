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


# -----------------------------------------------------------
# 新しい対戦を開始する
# -----------------------------------------------------------
  robot.respond /shogi new/i, (msg) ->
    if play == false
      if request == false
        sente = msg.message.user.name
        request = true
        msg.send "#{sente}が先手。対戦相手待ち。"
      else
        msg.send "#{sente}からの対戦要求があります。『at_grandma shogi accept』で対戦要求を受けます。"
    else
      print_bord(msg)
      msg.send "▲#{sente}と△#{gote}が対戦中です。"


# -----------------------------------------------------------
# 対戦を受け付ける
# -----------------------------------------------------------
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
      print_bord(msg)
      msg.send "▲#{sente}と△#{gote}が対戦中です。"


# -----------------------------------------------------------
# 現在の局面を見る
# -----------------------------------------------------------
  robot.respond /shogi bord/i, (msg) ->
    print_bord(msg)
    msg.send "▲#{sente}と△#{gote}が対戦中です。"


# -----------------------------------------------------------
# 指定の場所にある駒を見る（デバッグ用）
# -----------------------------------------------------------
  robot.respond /shogi check ([1-9])([1-9])/i, (msg) ->
    teban = get_teban()
    msg.send "手番は#{teban}です。"
    origin =
      "x" : msg.match[1]
      "y" : msg.match[2]
    kind_of_my_koma = bind[teban]
    msg.send "#{origin["x"]},#{origin["y"]}にある駒は・・・。"
    bord_coordinate = convert_to_bord_coordinate(origin)
    for koma_j, koma_e of kind_of_my_koma
      if (bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_e)
        msg.send "#{origin["x"]},#{origin["y"]}にある駒は#{koma_e}です。"
        msg.send "手数は#{tesuu}です。"
        return
      else
        msg.send "ないですね。"
        return

# -----------------------------------------------------------
# 現在の盤の状態を見る
# -----------------------------------------------------------

  robot.respond /shogi now/i, (msg) ->
    print_bord(msg)

# -----------------------------------------------------------
# すべてを初期化する
# -----------------------------------------------------------
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
    bord     = [
      ["l","n","s","g","k","g","s","n","l"],
      [" ","r"," "," "," "," "," ","b"," "],
      ["p","p","p","p","p","p","p","p","p"],
      [" "," "," "," "," "," "," "," "," "],
      [" "," "," "," "," "," "," "," "," "],
      [" "," "," "," "," "," "," "," "," "],
      ["P","P","P","P","P","P","P","P","P"],
      [" ","B"," "," "," "," "," ","R"," "],
      ["L","N","S","G","K","G","S","N","L"]
    ]
    msg.send "対局を初期化しました。"

# -----------------------------------------------------------
# 盤上のデータをURLに変換する
# -----------------------------------------------------------
  convert = (now_bord) ->
    url = []
    for line in now_bord
      counted_space_line = count_space(line)
      url.push(counted_space_line.join(""))
    console.log "#{url.join('/')}"
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

# -----------------------------------------------------------
# 指し手を解析する
# -----------------------------------------------------------
  robot.respond /shogi ([1-9])([1-9])(.{1,2}) ([1-9])([1-9])(.{1,2})$/i, (msg) ->
    origin =
      "x" : msg.match[1]
      "y" : msg.match[2]
      "k" : msg.match[3]
    destination =
      "x" : msg.match[4]
      "y" : msg.match[5]
      "k" : msg.match[6]

    if is_possible_moving(origin, destination, msg)
      msg.send "#{msg.message.user.name}が指した手は、#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}"
      # 移動する
      move(origin, destination)
      # 持ち駒の処理
      # 成か成らないか
      tesuu++
      print_bord(msg)
    else
      msg.send "もう一度どうぞ。"

  is_possible_moving = (origin, destination, msg) ->
    teban = get_teban()
    # 原点の駒と移動先の駒が同じかどうか
    if (origin["k"] != destination["k"])
      msg.send "移動先の駒が違います。その手は指せません。"
      return false
    # 存在するコマかどうかを判定する
    kind_of_koma = bind[teban]
    if !(kind_of_koma[origin["k"]])
      msg.send "そのような駒の種類はありません。"
      return false
    # 原点にその駒があるかどうか
    koma_str = bind[teban][origin["k"]]
    bord_coordinate = convert_to_bord_coordinate(origin)
    if !(bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_str)
      msg.send "そのような駒はその場所にありません。"
      return false
    # その駒の移動先に自分の駒がないか
    kind_of_my_koma = bind[teban]
    bord_coordinate = convert_to_bord_coordinate(destination)
    for koma_j, koma_e of kind_of_my_koma
      if (bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_e)
        msg.send "移動先に自分の駒があります。"
        return false
    # その駒がルールどおりに移動先にいけるか
      # 駒のルールに沿っているか
      # 通りぬけはできない
    return true

# -----------------------------------------------------------
# 移動する
# -----------------------------------------------------------

  move = (origin, destination) ->
    teban = get_teban()
    bord_coordinate = convert_to_bord_coordinate(origin)
    bord[bord_coordinate["y"]][bord_coordinate["x"]] = " "
    bord_coordinate = convert_to_bord_coordinate(destination)
    bord[bord_coordinate["y"]][bord_coordinate["x"]] = bind[teban][destination["k"]]

# -----------------------------------------------------------
# 手番を返す
# -----------------------------------------------------------

  get_teban = () ->
    if tesuu % 2 == 0
      return "sente"
    else
      return "gote"
    # return "sente"

# -----------------------------------------------------------
# 版を出力する
# -----------------------------------------------------------

  print_bord = (msg) ->
    url = convert(bord)
    msg.send "http://sfenreader.appspot.com/sfen?sfen=#{url}%20b%20-%20#{tesuu}"

# -----------------------------------------------------------
# 指定座標をbord座標に変換する
# -----------------------------------------------------------

  convert_to_bord_coordinate = (coordinate) ->
    bord_coordinate =
      "x" : 10 - coordinate["x"] - 1
      "y" : coordinate["y"] - 1
    return bord_coordinate



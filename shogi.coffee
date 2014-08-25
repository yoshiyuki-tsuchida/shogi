# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:

module.exports = (robot) ->

  play     = false
  request  = false
  player   =
    "sente" : null
    "gote"  : null
  tesuu    = 0
  last     = 55
  mochi    = []
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
  robot.respond /shogi req/i, (msg) ->
    if play == false
      if request == false
        player["sente"] = msg.message.user.name
        request = true
        msg.send "#{player["sente"]}が先手。対戦相手待ち。"
      else
        msg.send "#{player["sente"]}からの対戦要求があります。『at_grandma shogi ok』で対戦要求を受けます。"
    else
      print_bord(msg)
      msg.send "▲#{player["sente"]}と△#{player["gote"]}が対戦中です。"


# -----------------------------------------------------------
# 対戦を受け付ける
# -----------------------------------------------------------
  robot.respond /shogi ok/i, (msg) ->
    if play == false
      if request == false
        msg.send "対戦要求がありません。『at_grandma shogi req』で対戦要求を出せます。"
      else
        player["gote"] = msg.message.user.name
        request = false
        play    = true
        msg.send "▲#{player["sente"]}と△#{player["gote"]}の対戦。"
    else
      print_bord(msg)
      msg.send "▲#{player["sente"]}と△#{player["gote"]}が対戦中です。"


# -----------------------------------------------------------
# 現在の局面を見る
# -----------------------------------------------------------
  robot.respond /shogi bord/i, (msg) ->
    print_bord(msg)
    msg.send "▲#{player["sente"]}と△#{player["gote"]}が対戦中です。"

# -----------------------------------------------------------
# （デバッグ）
# -----------------------------------------------------------
  robot.respond /shogi mochi/i, (msg) ->
    message = get_convert_url_mochi()
    msg.send "#{message}"

# -----------------------------------------------------------
# 現在の棋譜を出力する
# -----------------------------------------------------------
  robot.respond /shogi kifu/i, (msg) ->
    print_kifu(msg)

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
# すべてを初期化する
# -----------------------------------------------------------
  robot.respond /shogi init/i, (msg) ->
    if !(validate_user_name(msg))
      msg.send "対戦中の▲#{player["sente"]}と△#{player["gote"]}しか操作できません。"
      return
    play     = false
    request  = false
    player   =
      "sente" : null
      "gote"  : null
    tesuu    = 0
    mochi  = []
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
# 指し手を進める
# -----------------------------------------------------------
  robot.respond /shogi ([0-9])([0-9])(.{1,2}) ([1-9])([1-9])(.{1,2})$/i, (msg) ->
    if !(validate_user_name(msg))
      msg.send "対戦中の▲#{player["sente"]}と△#{player["gote"]}しか操作できません。"
      return
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
      # 持ち駒の処理
      piece_in_hand(destination)
      # 移動する
      move(origin, destination)
      # 成か成らないか
      kifu.push(kifu_logger(destination))
      last = "#{destination["x"]}#{destination["y"]}"
      tesuu++
      print_bord(msg)
    else
      msg.send "もう一度どうぞ。"

  is_possible_moving = (origin, destination, msg) ->
    teban = get_teban()
    # 片方の座標が0だったらfalse
    if (origin["x"] == "0" && origin["y"] != "0") || (origin["x"] != "0" && origin["y"] == "0")
      msg.send "その座標は存在しません。"
      return false
    # 原点の駒と移動先の駒が同じかどうか
    if (origin["k"] != destination["k"])
      msg.send "移動先の駒が違います。その手は指せません。"
      return false
    # 存在するコマかどうかを判定する
    kind_of_koma = bind[teban]
    if !(kind_of_koma[origin["k"]])
      msg.send "そのような駒の種類はありません。"
      return false
    # その駒の移動先に自分の駒がないか
    kind_of_my_koma = bind[teban]
    bord_coordinate = convert_to_bord_coordinate(destination)
    for koma_j, koma_e of kind_of_my_koma
      if (bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_e)
        msg.send "移動先に自分の駒があります。"
        return false
    # 移動前のその場所に駒があるかどうか
    if (origin["x"] == "0" && origin["y"] == "0")
      # 持ち駒の場合
      koma_str = bind[teban][origin["k"]]
      is_exist = false
      for k,koma_e of mochi
        if (koma_str == koma_e)
          is_exist = true
      if !(is_exist)
        msg.send "その駒は持ち駒の中にありません。"
        return false
    else
      # 持ち駒じゃない場合
      koma_str = bind[teban][origin["k"]]
      bord_coordinate = convert_to_bord_coordinate(origin)
      if !(bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_str)
        msg.send "そのような駒はその場所にありません。"
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
    if (origin["x"] == "0" && origin["y"] == "0")
      mochi.some((v, i) ->
        if (v == bind[teban][origin["k"]])
          mochi.splice(i,1))
    else
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

# -----------------------------------------------------------
# 棋譜を記録する
# -----------------------------------------------------------

  kifu_logger = (destination) ->
    teban = get_teban()
    if teban == "sente"
      return "▲#{destination["x"]}#{destination["y"]}#{destination["k"]}"
    else
      return "△#{destination["x"]}#{destination["y"]}#{destination["k"]}"


# -----------------------------------------------------------
# 盤上を出力する
# -----------------------------------------------------------

  print_bord = (msg) ->
    url = convert(bord)
    mochigoma = get_convert_url_mochi()
    msg.send "http://sfenreader.appspot.com/sfen?sfen=#{url}%20b%20#{mochigoma}%20#{tesuu}&lm=#{last}&sname=#{player["sente"]}&gname=#{player["gote"]}"

# -----------------------------------------------------------
# 棋譜を出力する
# -----------------------------------------------------------

  print_kifu = (msg) ->
    all_kifu = ""
    for k,v of kifu
      te = parseInt(k) + 1
      all_kifu = all_kifu + "#{te}手目：#{v}\n"
    msg.send all_kifu


# -----------------------------------------------------------
# 指定座標をbord座標に変換する
# -----------------------------------------------------------

  convert_to_bord_coordinate = (coordinate) ->
    bord_coordinate =
      "x" : 10 - coordinate["x"] - 1
      "y" : coordinate["y"] - 1
    return bord_coordinate


# -----------------------------------------------------------
# 持ち駒取得の処理
# -----------------------------------------------------------

  piece_in_hand = (destination) ->
    # 相手の手番は先手？後手？
    teban = get_teban()
    if teban == "sente"
      aite_teban = "gote"
    else
      aite_teban = "sente"

    # その場所に相手の駒があるか
    kind_of_aite_koma = bind[aite_teban]
    kind_of_my_koma = bind[teban]
    bord_coordinate = convert_to_bord_coordinate(destination)
    for koma_j, koma_e of kind_of_aite_koma
      if (bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_e)
        # 相手の駒の種類と自分の駒の種類の変換
        # 持ち駒変数への代入
        mochi.push(kind_of_my_koma[koma_j])


# -----------------------------------------------------------
# 持ち駒のurl変換
# -----------------------------------------------------------
  get_convert_url_mochi = () ->
    if mochi.length <= 0
      return "-"
    url_mochi = []
    for k,kind_of_koma of bind
      for k_k,koma of kind_of_koma
        count_koma = 0
        for k_m,m of mochi
          if koma == m
            count_koma++
        if count_koma > 0
          url_mochi.push(count_koma)
          url_mochi.push(koma)
    url_mochi.join("")

# -----------------------------------------------------------
# ユーザーネームバリデート
# -----------------------------------------------------------

  validate_user_name = (msg) ->
    name = msg.message.user.name
    teban = get_teban()
    if teban == "sente"
      if name == player["sente"]
        return true
      else
        return false
    else if teban == "gote"
      if name == player["gote"]
        return true
      else
        return false
    else
      return false


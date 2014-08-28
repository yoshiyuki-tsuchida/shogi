# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:

module.exports = (robot) ->


# -----------------------------------------------------------
# 初期設定
# -----------------------------------------------------------

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
      "と" : "+P"
      "香" : "L"
      "杏" : "+L"
      "桂" : "N"
      "圭" : "+N"
      "銀" : "S"
      "全" : "+S"
      "金" : "G"
      "角" : "B"
      "馬" : "+B"
      "飛" : "R"
      "龍" : "+R"
      "玉" : "K"
    "gote" :
      "歩" : "p"
      "と" : "+p"
      "香" : "l"
      "杏" : "+l"
      "桂" : "n"
      "圭" : "+n"
      "銀" : "s"
      "全" : "+s"
      "金" : "g"
      "角" : "b"
      "馬" : "+b"
      "飛" : "r"
      "龍" : "+r"
      "玉" : "k"


# -----------------------------------------------------------
# LT end
# -----------------------------------------------------------

  robot.respond /lt end/i, (msg) ->
    msg.send "ご清聴ありがとうございました。"
    msg.send "http://cdn-ak.f.st-hatena.com/images/fotolife/y/yotsuya_step/20130326/20130326011914.jpg"
    msg.send "来週もまた見てくださいね！"


# -----------------------------------------------------------
# help
# -----------------------------------------------------------

  robot.respond /help$/i, (msg) ->
    msg.send """
```

  ---------------------------------------------
     Shogi on Slack Bot 'at_grandma' ver 0.1
  ---------------------------------------------

at_grandma commands are:

   shogi <command>

      - req
              対戦リクエストを発信する

      - ok
              対戦リクエストを受け付ける

      - bord
              現在の盤面情報を表示する

      - kifu
              直近の棋譜を表示する

      - init
              すべてを初期化する

      - <持つ駒> <打つ駒>
              動かしたい駒を持って、指定の場所に打つ
              ex1) at_grandma shogi 77歩 76歩
              ex2) at_grandma shogi 74歩 73歩成 （成る場合は「成」をつける）
              ex3) at_grandma shogi 00金 52金   （持ち駒は00指定）

      - help
              最善手っぽいものを教えてくれる


   help
         このhelp


使える駒：

      歩　と　香　杏　桂　圭　銀　全　金　角　馬　飛　龍　玉

```
"""

# -----------------------------------------------------------
# 新しい対戦を要求する
# -----------------------------------------------------------

  robot.respond /shogi req/i, (msg) ->
    if play == false
      if request == false
        player["sente"] = msg.message.user.name
        request = true
        random_message([
          "#{player["sente"]}が先手ね。対戦相手を待っているわよ。",
          "#{player["sente"]}が先手ね。がんばってね。",
          "#{player["sente"]}が先手ね。誰が相手なのかしらねぇ。",
        ], msg)
      else
        random_message([
          "#{player["sente"]}から呼ばれているわ。『at_grandma shogi ok』で対戦を受けるわよ。",
          "#{player["sente"]}が対戦したいそうよ。『at_grandma shogi ok』で相手をしてやってちょうだい。",
          "#{player["sente"]}がうずうずして待ってるわ。『at_grandma shogi ok』で遊んであげてね。",
        ], msg)
    else
      print_bord(msg)
      random_message([
        "▲#{player["sente"]}と△#{player["gote"]}が対戦中ね。",
        "▲#{player["sente"]}と△#{player["gote"]}の対戦がまだ終わってないわ。",
        "▲#{player["sente"]}と△#{player["gote"]}が白熱しているわねぇ。",
      ], msg)


# -----------------------------------------------------------
# 要求中の対戦を受け付ける
# -----------------------------------------------------------

  robot.respond /shogi ok/i, (msg) ->
    if play == false
      if request == false
        random_message([
          "まだ誰も来てないわ。『at_grandma shogi req』で相手を待てるわよ。",
          "あなた一人ねぇ。『at_grandma shogi req』で誰かを誘いましょう",
          "あなたから誰かを誘ってちょうだい。『at_grandma shogi req』で待ちましょう。",
        ], msg)
      else
        player["gote"] = msg.message.user.name
        request = false
        play    = true
        random_message([
          "対戦相手が決まったわ。▲#{player["sente"]}と△#{player["gote"]}の対戦中ね。",
          "▲#{player["sente"]}と△#{player["gote"]}の試合よ。頑張ってね。",
          "▲#{player["sente"]}と△#{player["gote"]}が対戦するらしいわ。。みんな集まって〜！",
        ], msg)
    else
      print_bord(msg)
      random_message([
        "▲#{player["sente"]}と△#{player["gote"]}が対戦中ね。",
        "▲#{player["sente"]}と△#{player["gote"]}の対戦がまだ終わってないわ。",
        "▲#{player["sente"]}と△#{player["gote"]}が白熱しているわねぇ。",
      ], msg)


# -----------------------------------------------------------
# 現在の局面を見る
# -----------------------------------------------------------

  robot.respond /shogi bord/i, (msg) ->
    if play == false
      random_message([
        "まだ誰も来ていないみたい。",
        "対戦は始まっていないわ。",
        "席は空いているわよ。対局してみたらどう？",
      ], msg)
    else
      print_bord(msg)
      random_message([
        "▲#{player["sente"]}と△#{player["gote"]}が対戦中ね。あなたならどっち持ち？",
        "▲#{player["sente"]}と△#{player["gote"]}の対戦がまだ終わってないわ。",
        "▲#{player["sente"]}と△#{player["gote"]}が白熱しているわねぇ。",
      ], msg)


# -----------------------------------------------------------
# 現在の棋譜を出力する
# -----------------------------------------------------------
  robot.respond /shogi kifu/i, (msg) ->
    if play == false
      random_message([
        "まだ誰も来ていないみたい。",
        "対戦は始まっていないわ。",
        "席は空いているわよ。対局してみたらどう？",
      ], msg)
    else
      print_kifu(msg)
      random_message([
        "現在の棋譜よ。▲#{player["sente"]}と△#{player["gote"]}の対戦ね。",
        "▲#{player["sente"]}と△#{player["gote"]}の棋譜よ。目隠し将棋で追ってみてね。",
        "▲#{player["sente"]}と△#{player["gote"]}の素晴らしい棋譜ねぇ。",
      ], msg)


# -----------------------------------------------------------
# 指定の場所にある駒を見る（デバッグ用）
# -----------------------------------------------------------

  # robot.respond /shogi check ([1-9])([1-9])/i, (msg) ->
    # teban = get_teban()
    # msg.send "手番は#{teban}です。"
    # origin =
      # "x" : msg.match[1]
      # "y" : msg.match[2]
    # kind_of_my_koma = bind[teban]
    # msg.send "#{origin["x"]},#{origin["y"]}にある駒は・・・。"
    # bord_coordinate = convert_to_bord_coordinate(origin)
    # for koma_j, koma_e of kind_of_my_koma
      # if (bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_e)
        # msg.send "#{origin["x"]},#{origin["y"]}にある駒は#{koma_e}です。"
        # msg.send "手数は#{tesuu}です。"
        # return
      # else
        # msg.send "ないですね。"
        # return

# -----------------------------------------------------------
# すべてを初期化する
# -----------------------------------------------------------

  robot.respond /shogi init/i, (msg) ->
    if !(validate_user_name(msg))
      random_message([
        "この操作は、対戦中の▲#{player["sente"]}と△#{player["gote"]}しかできないのよ。",
        "これは対戦中の▲#{player["sente"]}と△#{player["gote"]}しかできないの。ごめんねぇ。",
        "対戦中の▲#{player["sente"]}と△#{player["gote"]}しかこの操作はできないの。",
      ], msg)
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
    msg.send "すべて元に戻しましたよ。"


# -----------------------------------------------------------
# 指し手を進める
# -----------------------------------------------------------

  robot.respond /shogi ([0-9])([0-9])(.{1,2}) ([1-9])([1-9])(.)(|成)$/i, (msg) ->
    if !(validate_user_name(msg))
      random_message([
        "こらカツオ！！この操作は、対戦中の▲#{player["sente"]}と△#{player["gote"]}しかできないのよ！",
        "タラちゃ〜ん。これは対戦中の▲#{player["sente"]}と△#{player["gote"]}しかできないの。ごめんねぇ。",
        "サザエ！あんたは、対戦中の▲#{player["sente"]}と△#{player["gote"]}しかできないって知ってるでしょ！",
      ], msg)
      return
    origin =
      "x" : msg.match[1]
      "y" : msg.match[2]
      "k" : msg.match[3]
    destination =
      "x" : msg.match[4]
      "y" : msg.match[5]
      "k" : msg.match[6]
      "n" : msg.match[7]

    if is_possible_moving(origin, destination, msg)
      teban = get_teban()
      if teban == "sente"
        random_message([
          "▲#{player["sente"]}が指した手は、#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}#{destination["n"]}ね。",
          "あら、そんな手があったのねぇ。#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}#{destination["n"]}",
          "あたしは読んでたわよ。#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}#{destination["n"]}",
        ], msg)
      else
        random_message([
          "△#{player["sente"]}が指した手は、#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}#{destination["n"]}ね。",
          "それは気づかなかったわぁ！。#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}#{destination["n"]}",
          "ちょっとわけがわからないねぇ。#{origin["x"]}#{origin["y"]}#{origin["k"]} -> #{destination["x"]}#{destination["y"]}#{destination["k"]}#{destination["n"]}",
        ], msg)
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
      random_message([
        "やり直してちょうだい。",
        "もう一度打ち直してね。",
        "もう一度よ。どこにするのかしら？",
      ], msg)


# -----------------------------------------------------------
# 勝手に何か言ってくれる
# -----------------------------------------------------------

  robot.respond /shogi help/i, (msg) ->
    if play == false
      random_message([
        "まだ誰も来ていないみたい。",
        "対戦は始まっていないわ。",
        "席は空いているわよ。対局してみたらどう？",
      ], msg)
    else
      random_x = Math.floor(Math.random() * 9) + 1
      random_y = Math.floor(Math.random() * 9) + 1
      random_message([
        "#{random_x}#{random_y}歩 がいいんじゃないかしら。",
        "#{random_x}#{random_y}と が最善手ね。",
        "#{random_x}#{random_y}香 がいいんじゃないかしら。",
        "#{random_x}#{random_y}杏 だと思うわ。",
        "#{random_x}#{random_y}桂 がいいんじゃないかしら。",
        "#{random_x}#{random_y}圭 なんてどうかしら。",
        "#{random_x}#{random_y}銀 しかないでしょう！",
        "#{random_x}#{random_y}全 がいいんじゃないかしら。",
        "#{random_x}#{random_y}金 がいいと思うわ。",
        "#{random_x}#{random_y}角 がいいんじゃないかしら。",
        "#{random_x}#{random_y}馬 なんて妙手じゃないかしら。",
        "#{random_x}#{random_y}飛 がいいんじゃないかしら。",
        "#{random_x}#{random_y}龍 ひとつね。",
        "#{random_x}#{random_y}玉 でしょう！。",
      ], msg)


# -----------------------------------------------------------
# 移動可能かどうかのバリデーション
# -----------------------------------------------------------

  is_possible_moving = (origin, destination, msg) ->
    teban = get_teban()
    # 成れない駒だったら弾く
    if (destination["n"] == "成") && (
        destination["k"] == "と" ||
        destination["k"] == "杏" ||
        destination["k"] == "圭" ||
        destination["k"] == "全" ||
        destination["k"] == "馬" ||
        destination["k"] == "龍" ||
        destination["k"] == "金" ||
        destination["k"] == "玉")
      msg.send "その駒は成れないわ。"
      return false
    # その場所で成れない
    bord_coordinate = convert_to_bord_coordinate(destination)
    if (destination["n"] == "成") && (4 <= bord_coordinate["y"] && bord_coordinate["y"] <= 6)
      ##### ちょっとこの実装だと動作しない
      msg.send "その位置では成れないわ。"
      return false
    # 片方の座標が0だったらfalse
    if (origin["x"] == "0" && origin["y"] != "0") || (origin["x"] != "0" && origin["y"] == "0")
      msg.send "その場所は盤面上には存在しないのよ〜。"
      return false
    # 原点の駒と移動先の駒が同じかどうか
    if (origin["k"] != destination["k"])
      msg.send "持った駒と打つ駒が違うわね。"
      return false
    # 存在するコマかどうかを判定する
    kind_of_koma = bind[teban]
    if !(kind_of_koma[origin["k"]])
      msg.send "そんな駒は存在しないでしょ？"
      return false
    # その駒の移動先に自分の駒がないか
    kind_of_my_koma = bind[teban]
    bord_coordinate = convert_to_bord_coordinate(destination)
    for koma_j, koma_e of kind_of_my_koma
      if (bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_e)
        msg.send "打つところに自分の駒があるわよ？"
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
        msg.send "そんな持ち駒は見当たらないわねぇ。"
        return false
    else
      # 持ち駒じゃない場合
      koma_str = bind[teban][origin["k"]]
      bord_coordinate = convert_to_bord_coordinate(origin)
      if !(bord[bord_coordinate["y"]][bord_coordinate["x"]] == koma_str)
        msg.send "そこにある駒は違うものじゃない？"
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
    if destination["n"] == "成"
      bord[bord_coordinate["y"]][bord_coordinate["x"]] = "+" + bind[teban][destination["k"]]
    else
      bord[bord_coordinate["y"]][bord_coordinate["x"]] = bind[teban][destination["k"]]


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

# -----------------------------------------------------------
# ランダムでメッセージを返す
# -----------------------------------------------------------

  random_message = (message_array, msg) ->
    num = message_array.length
    random_key = Math.floor(Math.random() * num)
    msg.send message_array[random_key]


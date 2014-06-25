# Management Assistant

## 概要

音声認識によって様々な操作を補助するアプリ群を管理する。

アプリは音声コマンドを受け取り、任意に振る舞いを設定できる。

音声認識技術にはGoogleSpeechRecognitionを利用している。

## 実行

    /worker.rb

これを実行し、本体が動作する。

GoogleSpeechRecognitionを利用するためのChromeが必要である。

    /webserver/webserver.rb

これを実行し、httpsウェブサーバーを立ち上げ`https://localhost:10080/client.html`にアクセスする。(Chromeのマイク利用の仕様により、httpsを利用しなくてはならない。)

client.htmlとworker.rbがWebSocketで接続され、音声認識が利用可能になる。

## アプリ

#### App.create(global_id, [command, ...])
**概要** : アプリを作成する  
**global_id** : (Symbol)アプリを管理するためのid  
**[command, ...]** : ([String, ...])グローバルコマンド。このコマンドによってこのアプリが呼び出される(foreground)

#### #init(input, match_data)
**概要** : アプリがグローバルコマンドによって呼び出された時、activeでない場合に呼び出される  
**input** : (Hash)
**match_data** : (MatchData)呼ばれたコマンドがマッチした音声データのMatchDataが格納されている

#### #speech(text)
**概要** : アプリがforegroundである時、音声データを取得したときこのメソッドが呼ばれる  
**text** : (String)取得した音声データの文字列

#### @local_commands = {:local_id, [command, ...]}
**概要** : ローカルコマンドを設定し、コマンドが呼ばれた時に:local_idと同一名のメソッドが呼ばれる  
**global_id** : (Symbol)メソッド名を管理するためのid。コマンドが呼ばれた時このメソッド名が呼ばれる  
**[command, ...]** : ([String, ...])ローカルコマンド。このコマンドによってメソッドが呼ばれる

#### #local_id(input, match_data)
**概要** : local_commandsで指定したlocal_idのメソッド。コマンドが呼ばれた時にこのメソッドが実行される  
**input** : (Hash)前のコマンドの戻り値が格納されている
**match_data** : (MatchData)呼ばれたコマンドがマッチした音声データのMatchDataが格納されている
**戻り値** : (Hash)次に呼ばれるコマンドのinputに渡される。:defaultを設定推奨

#### @command_propagation = bool
**概要** : コマンドは#speech, local_commands, global_commandsの順で探索を行う。その探索の伝播を止める制御できる。
**bool** : (TrueClass, FalseClass)trueの時は伝播を行う。falseの時は伝播を停止する。

###サンプル

    App.create(:time, ["時計"]) do
      def init
        @local_commands = {:show => ["表示"]}
      end
    
      def speech(text) 
      end
    
      def show(input, match_data)
        time = Time.now
        puts time.to_s
        output = {:string => time.to_s, :time => time, :default => time.to_s}
        return output
      end
    end
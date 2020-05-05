class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # LINEから送られてきたメッセージが「アンケート」と一致するかチェック
          if event.message['text'].eql?('アンケート')
            # private内のtemplateメソッドを呼び出します。
            client.reply_message(event['replyToken'], template)
          end
        end
      end
    }

    head :ok
  end

  private

  def template
    {
      "type": "template",
      "altText": "This is a buttons template",
      "template": {
          "type": "buttons",
          "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
          "imageAspectRatio": "rectangle",
          "imageSize": "cover",
          "imageBackgroundColor": "#FFFFFF",
          "title": "Menu",
          "text": "Please select",
          "defaultAction": {
              "type": "uri",
              "label": "View detail",
              "uri": "http://example.com/page/123"
          },
          "actions": [
              {
                "type": "postback",
                "label": "Buy",
                "data": "action=buy&itemid=123"
              },
              {
                "type": "postback",
                "label": "Add to cart",
                "data": "action=add&itemid=123"
              },
              {
                "type": "uri",
                "label": "View detail",
                "uri": "http://example.com/page/123"
              }
          ]
      }
    }
  end
end

#def template
  #  {
  #    "type": "template",
  #    "altText": "this is a confirm template",
  #    "template": {
  #        "type": "confirm",
  #        "text": "カレーライスはお好きですか？",
  #        "actions": [
  #            {
  #              "type": "message",
  #              # Botから送られてきたメッセージに表示される文字列です。
  #              "label": "好き",
  #              # ボタンを押した時にBotに送られる文字列です。
  #              "text": "好き"
  #            },
  #            {
  #              "type": "message",
  #              "label": "嫌い",
  #              "text": "嫌い"
  #            }
  #        ]
  #    }
  #  }
  #end
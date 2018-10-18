/**
*	各種System.Queueable共通クラス
*/
public with sharing class LW_QueueableCommon {
	/**
	*	非同期メッセージ送信処理（テキスト）
	*/
    public class QueueableSendTextMsg implements System.Queueable, Database.AllowsCallouts {
        String accountId;
        String msgStr;

        public QueueableSendTextMsg(String accountId, String msgStr) {
            this.accountId= accountId;
            this.msgStr= msgStr;
        }

        public void execute(System.QueueableContext ctx) {
			// Server Tokenを取得
			String SERVER_TOKEN = LW_Utils.getServerToken();
			if( SERVER_TOKEN == null ){
				System.debug('Error: Server Token is null.');
				return;
			}

			// send message text json
			Map<String, Object> msgTextObj = new Map<String, Object>();
			msgTextObj.put('botNo', LW_Utils.BOT_NO);
			msgTextObj.put('accountId', accountId);
			Map<String, Object> msgContentObj = new Map<String, Object>();
			msgContentObj.put('type', 'text');
			msgContentObj.put('text', msgStr);
			msgTextObj.put('content', msgContentObj);
			String msgTextJson = Json.serialize(msgTextObj);

			// send message text
			HttpRequest sendMsgTextReq = new HttpRequest();
			sendMsgTextReq.setHeader('Authorization', 'Bearer '+ SERVER_TOKEN);
			sendMsgTextReq.setHeader('consumerKey', LW_Utils.SERVER_CONSUMER_KEY);
			sendMsgTextReq.setHeader('Content-Type', 'application/json');
			sendMsgTextReq.setEndpoint(LW_Utils.LW_SEND_MESSAGE_URI);
			sendMsgTextReq.setMethod('POST');
			sendMsgTextReq.setBody(msgTextJson);
			Http sendMsgTextHttp = new Http();
			HTTPResponse sendMsgTextRes = sendMsgTextHttp.send(sendMsgTextReq);
System.debug(sendMsgTextRes);
	    }
	}
}
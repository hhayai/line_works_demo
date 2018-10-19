/**
*	LINE WORKSからWebhookでメッセージを受け取るクラス
*/
@RestResource(urlMapping='/lineWorksBotCallback')
global with sharing class LW_BotCallbackController {
	/**
	*	POSTされたデータの処理
	*	@return Boolean
	*/
    @HttpPost
    global static Boolean doPost() {
		/**
		*	POSTされたデータを展開
		*/
		RestRequest req = RestContext.request;
		Map<String, Object> callbackParams = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.ToString());
		Map<String, Object> contentParams = (Map<String, Object>)callbackParams.get('content');
		String message = (String)contentParams.get('text');

		// Server Tokenを取得
		String SERVER_TOKEN = LW_Utils.getServerToken();
		if( SERVER_TOKEN == null ){
			System.debug('Error: Server Token is null.');
			return false;
		}

		// send message text json
		Map<String, Object> msgTextObj = new Map<String, Object>();
		msgTextObj.put('botNo', LW_Utils.BOT_NO);
		msgTextObj.put('accountId', LW_Utils.MNG_USER_ID);
		Map<String, Object> msgContentObj = new Map<String, Object>();
		msgContentObj.put('type', 'text');
		String retMsg = 'メッセージありがとうございます。\n\n>> '+ message;
		msgContentObj.put('text', retMsg);
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
		if( sendMsgTextRes.getStatusCode() != 200 ){
			System.debug('Http Callout Error!'+ sendMsgTextRes.getStatusCode());
			return false;
		}
		return true;
	}
}
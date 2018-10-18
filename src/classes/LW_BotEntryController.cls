/**
*	LINE WORKSのテナントとドメインにBOTを登録するクラス
*/
public with sharing class LW_BotEntryController {
	/**
	*	LINE WORKSのテナントとドメインにBOTを登録する処理
	*/
	public static void registLW_BotEntry(){
		// Server Tokenを取得
		String SERVER_TOKEN = LW_Utils.getServerToken();
		if( SERVER_TOKEN == null ){
			System.debug('Error: Server Token is null.');
			return;
		}

		/**
		*	BOTを作成してテナントに登録
		*/
		// make json for regist bot to tenant
		Map<String, Object> bots = new Map<String, Object>();
		bots.put('name', 'test bot');
		bots.put('photoUrl', 'https://developers.worksmobile.com/favicon.png');
		bots.put('description', 'This is test bot.');
		List<String> manageUser = new List<String>();
		manageUser.add(LW_Utils.MNG_USER_ID);
		bots.put('managerList', manageUser);
		String jsonBody = Json.serialize(bots);

		// regist bot to tenant
		HttpRequest botReq = new HttpRequest();
		botReq.setHeader('Authorization', 'Bearer '+ SERVER_TOKEN);
		botReq.setHeader('consumerKey', LW_Utils.SERVER_CONSUMER_KEY);
		botReq.setHeader('Content-Type', 'application/json');
		botReq.setEndpoint(LW_Utils.LW_REGIST_BOT_TENANT_URI);
		botReq.setMethod('POST');
		botReq.setBody(jsonBody);
		Http botHttp = new Http();
		HTTPResponse botRes = botHttp.send(botReq);
		Map<String, Object> regBotParams = (Map<String, Object>)JSON.deserializeUntyped(botRes.getBody());
		Integer botNo = null;
		if( (Integer)regBotParams.get('code') != 200 ){
			System.debug('Http Callout Error!'+ (Integer)regBotParams.get('code'));
			return;
		}else{
			botNo = (Integer)regBotParams.get('botNo');
		}
System.debug('Bot No: '+ botNo);

		/**
		*	BOTをドメインに登録
		*/
		// make json for regist bot to domain
		Map<String, Object> regDomainBots = new Map<String, Object>();
		regDomainBots.put('botNo', botNo);
		regDomainBots.put('domainId', 0);
		regDomainBots.put('usePublic', true);
		regDomainBots.put('usePermission', false);
		String regDomainJson = Json.serialize(regDomainBots);

		// regist bot to domain
		HttpRequest regDomainBotReq = new HttpRequest();
		regDomainBotReq.setHeader('Authorization', 'Bearer '+ SERVER_TOKEN);
		regDomainBotReq.setHeader('consumerKey', LW_Utils.SERVER_CONSUMER_KEY);
		regDomainBotReq.setHeader('Content-Type', 'application/json');
		regDomainBotReq.setEndpoint(LW_Utils.LW_REGIST_BOT_DOMAIN_URI);
		regDomainBotReq.setMethod('POST');
		regDomainBotReq.setBody(regDomainJson);
		Http regDomainBotHttp = new Http();
		HTTPResponse regDomainBotRes = regDomainBotHttp.send(regDomainBotReq);
		if( regDomainBotRes.getStatusCode() != 200 ){
			System.debug('Http Callout Error!'+ regDomainBotRes.getStatusCode());
			return;
		}
System.debug('complete!');
	}
}
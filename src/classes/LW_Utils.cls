/**
*	LINE WORKS用ユーティリティクラス
*/
public with sharing class LW_Utils {
	/**
	*	共通設定
	*	以下、Salesforceのカスタム表示ラベルを事前に作成して、それぞれ値をセットしてください
	*	LW_API_ID	LINE WORKSのDeveloper Consoleで発行したAPI ID
	*	LW_SERVER_CONSUMER_KEY	LINE WORKSのDeveloper Consoleで発行したSERVER CONSUMER KEY
	*	LW_SERVER_ID	LINE WORKSのDeveloper Consoleで発行したSERVER ID
	*	LW_USER_ID	LINE WORKSの自身のアカウントID
	*	LW_BOT_NO	登録したBOTの番号（こちらだけは、BOT登録後に値を書き換える）
	*/
	// LINE WORKS設定、URI
	public static String API_ID = System.Label.LW_API_ID;
	public static String SERVER_CONSUMER_KEY = System.Label.LW_SERVER_CONSUMER_KEY; 
	public static String SERVER_ID = System.Label.LW_SERVER_ID; 
    public static String LW_AUTH_URI = 'https://authapi.worksmobile.com/b/'+ API_ID +'/server/token';
    public static String LW_REGIST_BOT_TENANT_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/registerBot/v4';
    public static String LW_GET_BOT_LIST_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/getBotList/v4';
    public static String LW_REGIST_BOT_DOMAIN_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/registerBotDomain/v3';
    public static String LW_SEND_MESSAGE_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/sendMessage/v2';

	// LINE WORKSの管理ユーザー（デモ用として自分のLINE WORKSアカウントIDを登録）
	public static String LW_USER_ID = System.Label.LW_USER_ID;
	// BOT NO（テスト用）
	public static Integer BOT_NO = Integer.valueOf(System.Label.LW_BOT_NO);

	/**
	*	Server Tokenを取得するクラス
	*/
	public static String getServerToken(){
		String accessToken = null;

		// header
		String jwtHeader = '{"alg":"RS256","typ":"JWT"}';
		jwtHeader = System.encodingUtil.base64Encode(Blob.valueOf(jwtHeader)).replace('+', '-').replace('/', '_');

		// claims
		Map<String, Object> claims = new Map<String, Object>();
		claims.put('iss', SERVER_ID);
		Datetime startDt = Datetime.now();
		Long startDtMs = startDt.getTime()/1000;
		claims.put('iat', startDtMs);
		Long expDtMs = startDt.addMinutes(2).getTime()/1000;
		claims.put('exp', expDtMs);
		String jwtClaims = Json.serialize(claims);
		jwtClaims = System.encodingUtil.base64Encode(Blob.valueOf(jwtClaims)).replace('+', '-').replace('/', '_');

		// jwt request
		String jwtRequest = jwtHeader + '.' + jwtClaims;

		// private key
		StaticResource srData = [Select Id, Body From StaticResource Where Name = 'LineWorksPrivateKey' Limit 1];
		String bodyStr = srData.Body.toString();
		Blob privateKey = EncodingUtil.base64Decode(bodyStr);

		// signature
		String signature = System.encodingUtil.base64Encode(Crypto.sign('RSA-SHA256', Blob.valueOf(jwtRequest), privateKey)).replace('+', '-').replace('/', '_');
		String signedJwtRequest = jwtRequest + '.' + signature;

		// payload
		String payload = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion='+ signedJwtRequest;

		// get accessToken
		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
		req.setEndpoint(LW_AUTH_URI);
		req.setMethod('POST');
		req.setBody(payload);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		Map<String, Object> callbackParams = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		if( (Integer)callbackParams.get('code') == 31 ){
			System.debug('Http Callout Error!'+ (Integer)callbackParams.get('code'));
			return null;
		}else{
			accessToken = (String)callbackParams.get('access_token');
		}
System.debug(accessToken);
		return accessToken;
	}
}
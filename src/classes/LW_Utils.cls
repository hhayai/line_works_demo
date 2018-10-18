/**
*	LINE WORKS用ユーティリティクラス
*/
public with sharing class LW_Utils {
	/**
	*	共通設定
	*/
	// LINE WORKS設定、URI
	public static String API_ID = '【自分のAPI IDを入力】'; 
	public static String SERVER_CONSUMER_KEY = '【自分のServer Consumer Keyを入力】'; 
	public static String SERVER_ID = '【自分のServer Listに登録したServer IDを入力】'; 
    public static String LW_AUTH_URI = 'https://authapi.worksmobile.com/b/'+ API_ID +'/server/token';
    public static String LW_REGIST_BOT_TENANT_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/registerBot/v4';
    public static String LW_GET_BOT_LIST_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/getBotList/v4';
    public static String LW_REGIST_BOT_DOMAIN_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/registerBotDomain/v3';
    public static String LW_SEND_MESSAGE_URI = 'https://apis.worksmobile.com/'+ API_ID +'/message/sendMessage/v2';

	// LINE WORKSの管理ユーザー（とりあえず1人分）
	public static String MNG_USER_ID = '【自分のLINE WORKSアカウントのIDを入力】';
	// BOT NO（テスト用）
	public static Integer BOT_NO = 9999999;		// 自分が登録したBotの番号を入力

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
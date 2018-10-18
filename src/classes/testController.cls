public with sharing class testController {
	@AuraEnabled
	public static string getUserSession() {
		return userInfo.getSessionId();
	}
}
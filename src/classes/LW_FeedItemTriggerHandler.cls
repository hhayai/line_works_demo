/**
*	FeedItem用のトリガハンドラー
*/
public with sharing class LW_FeedItemTriggerHandler {
    /**
     * After Insert時のハンドリング
     */
    public void onAfterInsert(FeedItem[] triggerNew) {
		// FeedItemのBodyから、メンションがついていれば宛先として利用し、Body全体をメッセージとして送信
		// ※実際に利用する場合は、ガバナ制限やMessaging API側の制限を考慮する必要があるため、
		// ※このままでは動作しなくなることがあります。必ずご自身で確認してください。
		Set<String> lastNames = new Set<String>();
		Set<String> userIds = new Set<String>();
		Map<Id, String> msgMap = new Map<Id, String>();
		// Map<String, String> msgMap = new Map<String, String>();
		Map<String, String> postUserMap = new Map<String, String>();
		for( FeedItem fi : triggerNew ){
			String tmpBody = fi.Body.replaceAll('<p>', '');
			List<String> msgList = tmpBody.split('</p>');
			String msgStr = tmpBody.replaceAll('</p>', '\n');
			
			// ユーザに対するメンションがあればそのユーザIDを取得
			ConnectApi.FeedElement fe = ConnectApi.ChatterFeeds.getFeedElement(null, fi.Id);
			List<ConnectApi.MessageSegment> messageSegments = fe.body.messageSegments;
			for( ConnectApi.MessageSegment messageSegment : messageSegments ){
				if( messageSegment instanceof ConnectApi.MentionSegment ){
					ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
					Id tmpId = mentionSegment.record.Id;
					if( String.valueOf(tmpId).startsWith(User.SObjectType.getDescribe().getKeyPrefix()) ){
						userIds.add(mentionSegment.record.Id);
						msgMap.put(mentionSegment.record.Id, msgStr);
					}
				}
			}
		}
System.debug(userIds);
System.debug(msgMap);

		// 取得したユーザーのLINE WORKSのアカウントIDを取得し、メッセージ送信
		for( User usr : [Select Id, Name, LW_AccountId__c From User Where Id In :userIds Order By Id ASC]){
			if( msgMap.containsKey(usr.Id) ){
				String sendMsgStr = msgMap.get(usr.Id);
				sendMsgStr += '\n\nFrom '+ usr.Name;
System.debug(usr.LW_AccountId__c);
System.debug(sendMsgStr);
				System.enqueueJob(new LW_QueueableCommon.QueueableSendTextMsg(usr.LW_AccountId__c, sendMsgStr));
			}
		}
    }
}
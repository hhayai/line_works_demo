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
		Set<String> userNames = new Set<String>();
		Set<String> userIds = new Set<String>();
		Map<String, String> msgMap = new Map<String, String>();
		Map<String, String> postUserMap = new Map<String, String>();
		for( FeedItem fi : triggerNew ){
			String tmpBody = fi.Body.replaceAll('<p>', '');
			List<String> msgList = tmpBody.split('</p>');
			String msgStr = tmpBody.replaceAll('</p>', '\n');
			String userName = null;
			for( String msg : msgList ){
				if( msg.contains('@') ){
					// メンションが含まれていたら名前を取り出す
					userName = msg.replaceAll('@', '').removeEndIgnoreCase('​ ');
					userNames.add(userName);
					msgMap.put(userName, msgStr);
					if( String.valueOf(fi.InsertedById).startsWith(User.SObjectType.getDescribe().getKeyPrefix()) ){
						postUserMap.put(fi.InsertedById, userName);
						userIds.add(fi.InsertedById);
					}
				}
			}
		}

		// 送信元のユーザーIDの氏名を取得
		Map<String, String> senderMap = new Map<String, String>();
		for( User sendUsr : [Select Id, Name From User Where Id In :userIds Order By Id ASC]){
			if( postUserMap.containsKey(sendUsr.Id) ){
				senderMap.put(postUserMap.get(sendUsr.Id), sendUsr.Name);
			}
		}

		// 取得したユーザーのLINE WORKSのアカウントIDを取得し、メッセージ送信
		for( User usr : [Select Id, Name, LW_AccountId__c From User Where Name In :userNames Order By Id ASC]){
			if( msgMap.containsKey(usr.Name) ){
				String sendMsgStr = msgMap.get(usr.Name);
				if( senderMap.containsKey(usr.Name) ){
					// 一致するものがあれば送信元を付与
					sendMsgStr += '\n\nFrom '+ senderMap.get(usr.Name);
				}
				System.enqueueJob(new LW_QueueableCommon.QueueableSendTextMsg(usr.LW_AccountId__c, sendMsgStr));
			}
		}
    }
}
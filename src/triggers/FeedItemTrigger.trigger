/**
*	FeedItemトリガ
*/
trigger FeedItemTrigger on FeedItem (after insert) {
    //  トリガハンドラーをインスタンス化
    LW_FeedItemTriggerHandler handler = new LW_FeedItemTriggerHandler();

    /**
    *	isAfter
    */
    if( trigger.isAfter ){
        if( trigger.isInsert ){
            handler.onAfterInsert(trigger.new);
        }
    }
}
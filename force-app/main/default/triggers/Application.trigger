trigger Application on Application__c(before insert, after insert) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			ApplicationTriggerHelper.beforeInsert(Trigger.new);
		}
	}

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			ApplicationTriggerHelper.afterInsert(Trigger.new);
		}
	}
}

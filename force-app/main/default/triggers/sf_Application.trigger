trigger sf_Application on sf_Application__c(before insert, after insert) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			sf_ApplicationTriggerHelper.beforeInsert(Trigger.new);
		}
	}

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			sf_ApplicationTriggerHelper.afterInsert(Trigger.new);
		}
	}
}

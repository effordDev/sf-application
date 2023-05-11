import { api, LightningElement } from "lwc";

export default class ApplicationDisplayText extends LightningElement {
	@api recordId;
	@api sectionId;
	@api detail;

	@api get completed() {
		return true;
	}

	get displayText() {
		return this.detail?.Display_Text__c;
	}
}
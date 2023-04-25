import { api, LightningElement } from "lwc";

export default class ApplicationDisplayRichText extends LightningElement {
	@api recordId;
	@api sectionId;
	@api detail;

	@api get completed() {
		return true;
	}

	get displayRichText() {
		return this.detail?.Display_Rich_Text__c;
	}
}

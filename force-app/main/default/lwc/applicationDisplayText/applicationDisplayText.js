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
	get alignment() {
		return this.detail?.Alignment__c
	}
	get displayClass() {
		if (['Right', 'Left'].includes(this.alignment)) {
			return `slds-float_${this.alignment.toLowerCase()}` 
		} 
		return 'slds-align_absolute-center'
	}
}
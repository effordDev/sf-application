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
	get alignment() {
		return this.detail?.Alignment__c;
	}
	get displayClass() {
		if (["Right", "Left"].includes(this.alignment)) {
			return `slds-float_${this.alignment.toLowerCase()}`;
		}
		return "slds-align_absolute-center";
	}
}

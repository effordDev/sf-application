import { api, LightningElement } from "lwc";

export default class ApplicationDisplayText extends LightningElement {
	@api recordId;
	@api sectionId;
	@api detail;
	@api language = ''
	@api languages = []

	connectedCallback() {
		console.log(JSON.parse(JSON.stringify(this.detail)))
	}

	errorCallback(error, stack) {
		console.log('error')
		console.log(error)
	}
	@api get completed() {
		return true;
	}
	get displayText() {
		return this.language === 'English' ? 
		this.detail?.Field_Label__c :
		this.languages
		.filter(lang => lang.Application_Detail__c === this.id)
		.find(item => item.Language__c === this.language)?.Translated_Text__c || this.detail?.Display_Text__c
	}
	// get displayText() {
	// 	return this.detail?.Display_Text__c;
	// }
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

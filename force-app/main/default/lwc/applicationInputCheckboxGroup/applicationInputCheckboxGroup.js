import { api, track, LightningElement } from "lwc";

export default class ApplicationInputCheckboxGroup extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api languages = [];
	@track _detail = {};

	@api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	@api get completed() {
		return [
			...this.template.querySelectorAll("lightning-checkbox-group")
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
	}
	get id() {
		return this.detail?.Id;
	}
	get label() {
		return this.language === "English"
			? this.detail?.Field_Label__c
			: this.languages
					.filter((lang) => lang.Application_Detail__c === this.id)
					.find((item) => item.Language__c === this.language)
					?.Translated_Text__c;
	}
	get required() {
		return this.detail?.Required__c;
	}
	get val() {
		return this.detail?.Input_Text_Long__c?.split(";") || [];
	}
	get picklistValues() {
		return this.detail?.Checkbox_Group_Values__c || "";
	}
	get options() {
		if (!this.picklistValues.length) {
			return [{ label: "N/A", value: "N/A" }];
		}
		if (!this.picklistValues.split(";").length) {
			return [{ label: "N/A", value: "N/A" }];
		}

		return this.picklistValues.split(";").map((value) => {
			value = value.trim();

			return {
				label: value,
				value
			};
		});
	}

	handleChange(event) {
		const value = event.detail.value;

		this.detail.Input_Text_Long__c = value.join(";");

		console.log(JSON.parse(JSON.stringify(this.detail)));

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Text_Long__c: this.detail.Input_Text_Long__c
				}
			})
		);
	}
}

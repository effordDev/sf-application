import { api, track, LightningElement } from "lwc";

export default class ApplicationAccountInfo extends LightningElement {
	@api recordId;
	@api detail = {};
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api account = {};

	@track accountInfo;

	@api get completed() {
		return [
			...this.template.querySelectorAll("lightning-input, lightning-combobox")
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
	}

	get id() {
		return this.account?.Id;
	}
	get name() {
		return this.account?.Name;
	}
	get website() {
		return this.account?.Website;
	}
	get ein() {
		return this.account?.EIN__c;
	}
	get billingAddress() {
		return this.account?.BillingAddress;
	}
	get billingCity() {
		return this.billingAddress?.city || "";
	}
	get billingState() {
		return this.billingAddress?.state || "";
	}
	get billingStreet() {
		return this.billingAddress?.street || "";
	}
	get billingPostalCode() {
		return this.billingAddress?.postalCode;
	}
	get billingCountry() {
		return this.billingAddress?.country;
	}

	get customJSONSettings() {
		if (isJSON(this.detail.Custom_Component_JSON__c)) {
			return JSON.parse(this.detail.Custom_Component_JSON__c);
		}
		return {};
	}

	get showName() {
		return this.customJSONSettings?.fieldsToShow?.includes("Name");
	}
	get showWebsite() {
		return this.customJSONSettings?.fieldsToShow?.includes("Website");
	}
	get showBillingAddress() {
		return this.customJSONSettings?.fieldsToShow?.includes("BillingAddress");
	}
	get showEin() {
		return this.customJSONSettings?.fieldsToShow?.includes("EIN__c");
	}

	handleAddressChange(event) {
		const address = {
			BillingCity: event.detail.city,
			BillingCountry: event.detail.country,
			BillingPostalCode: event.detail.postalCode,
			BillingStreet: event.detail.street,
			BillingState: event.detail.province
		};

		Object.entries(address).forEach(([field, value]) => {
			this.dispatchEvent(
				new CustomEvent("sobchange", {
					composed: true,
					bubbles: true,
					detail: {
						id: this.id,
						field,
						value
					}
				})
			);
		});
	}

	handleChange(event) {
		const value = event.detail.value;
		const field = event.target.name;

		// console.log({
		// 	field,
		// 	value
		// })

		this.dispatchEvent(
			new CustomEvent("sobchange", {
				composed: true,
				bubbles: true,
				detail: {
					id: this.id,
					field,
					value
				}
			})
		);
	}
}

const isJSON = (string) => {
	try {
		JSON.parse(string);
		return true;
	} catch (error) {
		return false;
	}
};
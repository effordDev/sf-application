import { api, LightningElement } from "lwc";

export default class ApplicationProgressIndicatorItem extends LightningElement {
	@api item = {};
	@api activeSectionId = "";

	get id() {
		return this.item.Id;
	}
	get isActiveSection() {
		return this.id === this.activeSectionId;
	}
	get icon() {
		return this.completed ? "action:approval" : "action:defer";
	}
	get title() {
		return this.completed ? "Completed" : "Incomplete";
	}
	get label() {
		return this.item?.Display_Section_Label__c;
	}
	get completed() {
		return this.item.Completed__c;
	}
	get incomplete() {
		return !this.completed;
	}
	get labelClass() {
		return this.isActiveSection
			? "slds-text-title_bold content"
			: "slds-text-body_regular content";
	}

	handleClick(event) {
		const id = event.target.dataset.id;
		console.log(id);
		this.dispatchEvent(
			new CustomEvent("sectionselect", {
				bubbles: true,
				composed: true,
				detail: {
					id
				}
			})
		);
	}
}

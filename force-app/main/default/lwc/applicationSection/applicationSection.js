import { api, LightningElement } from "lwc";
import ApplicationModal from "c/applicationModal";
import getApplicationDetails from "@salesforce/apex/ApplicationHelper.getApplicationDetails";
import getApplicationSectionLanguages from "@salesforce/apex/ApplicationHelper.getApplicationSectionLanguages";
import saveApplicationDetails from "@salesforce/apex/ApplicationHelper.saveApplicationDetails";

export default class ApplicationSection extends LightningElement {
	@api recordId;
	@api section = {};
	@api language = ''
	@api readOnly = false;

	@api cancelBtnLabel= ''
	@api saveBtnLabel= ''

	details = [];
	detailsToUpdate = [];

	connectedCallback() {
		this.fetchApplicationDetails();
		this.fetchApplicationSectionLanguages()
	}

	async fetchApplicationDetails() {
		this.details = await getApplicationDetails({
			applicationSectionId: this.id
		});
	}
	async fetchApplicationSectionLanguages() {
		this.languages = await getApplicationSectionLanguages({ sectionId: this.id })
	}
	get id() {
		return this.section.Id;
	}
	get displaySectionLabel() {
		if (this.language === 'English') {
			return this.section?.Display_Section_Label__c
		}
		return this.languages.find(l => l.Language__c === this.language)?.Translated_Display_Section_Name__c || this.section?.Display_Section_Label__c;
	}
	get isCompleted() {
		return this.section?.Completed__c;
	}
	get btnClass() {
		return "slds-button slds-button_success btn-responsive-width";
	}
	get completeColor() {
		return "#40B658";
	}
	get inCompleteColor() {
		return "#0073CE";
	}
	get btnBackgroundBorderColor() {
		return this.isCompleted ? this.completeColor : this.inCompleteColor;
	}
	get btnColor() {
		return this.isCompleted ? "#FFFFFF" : this.inCompleteColor;
	}
	get btnStyle() {
		return `text-align:center; color:#FFFFFF ;background-color:${this.btnBackgroundBorderColor}; border: ${this.btnBackgroundBorderColor}`;
	}

	async open() {
		try {
			const result = await ApplicationModal.open({
				label: this.displaySectionLabel,
				recordId: this.recordId,
				sectionId: this.id,
				details: this.details,
				readOnly: this.readOnly,
				language: this.language,
				cancelBtnLabel: this.cancelBtnLabel,
				saveBtnLabel: this.saveBtnLabel,

				ondetailchange: (event) => this.handleDetailChange(event),
				onsave: (event) => this.handleSave(event),
			});

			if (result == "save") {
				await this.handleSave();
			}
		} catch (error) {
			console.log(JSON.parse(JSON.stringify(error)));
		}
	}

	handleDetailChange(event) {
		const detail = JSON.parse(JSON.stringify(event.detail));

		this.detailsToUpdate = [
			...this.detailsToUpdate.filter((item) => item.Id != detail.Id),
			detail
		];
	}

	async handleSave() {
		try {

			this.dispatchEvent(new CustomEvent("loading"));

			await saveApplicationDetails({
				recordId: this.recordId,
				sectionId: this.id,
				details: this.detailsToUpdate
			});

			//reset details
			await this.fetchApplicationDetails();

			this.dispatchEvent(new CustomEvent("refresh"));

		} catch (error) {
			console.error(error);
		} finally {
			this.dispatchEvent(new CustomEvent("loading"));
		}
	}
}
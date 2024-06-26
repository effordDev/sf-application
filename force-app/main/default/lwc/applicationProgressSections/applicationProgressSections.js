import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import getApplicationDetails from "@salesforce/apex/ApplicationHelper.getApplicationDetails";
import getApplicationDetailLanguages from "@salesforce/apex/ApplicationHelper.getApplicationDetailLanguages";
// import getApplicationSectionLanguages from "@salesforce/apex/ApplicationHelper.getApplicationSectionLanguages";
import saveApplicationDetails from "@salesforce/apex/ApplicationHelper.saveApplicationDetails";
import updateSobs from "@salesforce/apex/ApplicationHelper.updateSobs";

export default class ApplicationProgressSections extends LightningElement {
	@api recordId;
	@api application = {}
	@api applicationLanguages = []
	@api account = {};
	@api contact = {};
	@api readOnly = false;
	@api sections = [];
	@api activeSectionId = "";
	@api language = "";
	@api isCommunity = false
	// @api saveBtnLabel = 'Save & Next'
	// @api cancelBtnLabel = 'Previous'

	details = [];
	sobsToUpdate = [];
	detailsToUpdate = [];

	detailLanguages = [];

	isLoading = false;

	connectedCallback() {
		this.fetchApplicationDetails();
		this.fetchApplicationDetailLanguages();
	}

	get editable() {
		return !this.readOnly;
	}
	get isSectionComplete() {
		return this.sections.find(s => s.Id === this.activeSectionId)?.Completed__c || false
	}
	get allSectionsComplete() {
		return this.sections.every((section) => section.Completed__c);
	}
	get sectionIndex() {
		return this.sections.findIndex(
			(section) => section.Id === this.activeSectionId
		);
	}
	get isLastSection() {
		return this.sectionIndex + 1 === this.sections.length;
	}
	get saveBtnLabel() {
		return this.isLastSection ? this.displaySaveBtnLabel : this.displaySaveNextBtnLabel;
	}
	get showSaveForLaterBtn() {
		return !this.isSectionComplete
	}
	get showSubmitBtn() {
		return this.allSectionsComplete;
	}

	get defaultSubmitLabel() {
		return this.application?.Submit_Label__c || ''
	}
	get displaySubmitBtnLabel() {
		return (
			this.applicationLanguages.find((al) => al.Language__c === this.language)
				?.Translated_Submit_Text__c || this.defaultSubmitLabel
		);
	}

	get defaultSaveLabel() {
		return this.application?.Save_Label__c || ''
	}
	get displaySaveBtnLabel() {
		return (
			this.applicationLanguages.find((al) => al.Language__c === this.language)
				?.Translated_Save_Text__c || this.defaultSaveLabel
		);
	}

	get defaultSaveNextLabel() {
		return this.application?.Save_Next_Label__c || ''
	}
	get displaySaveNextBtnLabel() {
		return (
			this.applicationLanguages.find((al) => al.Language__c === this.language)
				?.Translated_Save_Text__c || this.defaultSaveNextLabel
		);
	}
	// saveBtnDisable() {
	//     return this.isLastSection
	// }

	@api async setDetails(sectionId) {
		try {
			this.isLoading = true;

			if (sectionId === this.activeSectionId) {
				return;
			}

			this.activeSectionId = sectionId;

			await this.fetchApplicationDetails();
			await this.fetchApplicationDetailLanguages();
		} catch (error) {
			console.error(error);
		} finally {
			this.isLoading = false;
		}
	}

	async fetchApplicationDetails() {
		// console.log('fetching details, sectionId:', this.activeSectionId)
		try {
			this.isLoading = true;

			this.details = [];

			this.details = await getApplicationDetails({
				applicationSectionId: this.activeSectionId
			});
			// console.log(JSON.parse(JSON.stringify(this.details)));
		} catch (error) {
			console.error(error);
		} finally {
			this.isLoading = false;
		}
	}

	async fetchApplicationDetailLanguages() {
		try {
			this.detailLanguages = [];

			this.detailLanguages = await getApplicationDetailLanguages({
				applicationSectionId: this.activeSectionId
			});
			// console.log("this.detailLanguages");
			// console.log(JSON.parse(JSON.stringify(this.detailLanguages)));
		} catch (error) {
			console.error(error);
		}
	}

	handleDetailChange(event) {
		const detail = JSON.parse(JSON.stringify(event.detail));

		this.detailsToUpdate = [
			...this.detailsToUpdate.filter((item) => item.Id != detail.Id),
			detail
		];
	}

	handleSobChange(event) {
		// const sob = JSON.parse(JSON.stringify(event.detail));
		const { id, field, value } = event.detail;

		const match = (x) => x.Id === id;

		if (this.sobsToUpdate.some(match)) {
			this.sobsToUpdate.forEach((sob) => {
				if (match(sob)) {
					sob[field] = value;
				}
			});
		} else {
			this.sobsToUpdate = [
				...this.sobsToUpdate,
				{
					Id: id,
					[field]: value
				}
			];
		}

		// console.log(JSON.parse(JSON.stringify(this.sobsToUpdate)));
	}

	validateInputs() {
		const appDetailsTypes = this.template.querySelectorAll(
			"c-application-detail-type.customInput"
		);

		let allValidArray = [];

		let firstErrorElement = null;

		appDetailsTypes.forEach((curr) => {
			const valid = curr.isValid();

			allValidArray.push(valid);

			if (!firstErrorElement && !valid) {
				firstErrorElement = curr;

				firstErrorElement.scrollIntoView({
					behavior: "smooth",
					block: "center"
				});
			}
		});

		console.log(allValidArray);

		const isAllValid = allValidArray.every((item) => !!item);

		return isAllValid;
	}

	async handleSubmit() {
		const result = await LightningConfirm.open({
			message: "Are you sure you want to Submit?",
			label: "Confirm",
			theme: "inverse"
		});

		if (!result) {
			return;
		}

		this.dispatchEvent(
			new CustomEvent("submit", {
				bubbles: true,
				composed: true
			})
		);
	}
	async handleSave(event) {
		this.isLoading = true;

		
		const btnName = event.target.name
		// console.log(event.target.name)

		if (btnName === 'Save') {

			const isAllValid = this.validateInputs();
	
			if (!isAllValid) {
				this.isLoading = false;
				return;
			}
		}

		const sectionComplete = btnName === 'Save'
		// console.log({sectionComplete})

		try {
			if (this.sobsToUpdate.length) {
				await updateSobs({
					sobs: this.sobsToUpdate
				});

				this.sobsToUpdate = [];
			}

			await saveApplicationDetails({
				recordId: this.recordId,
				sectionId: this.activeSectionId,
				details: this.detailsToUpdate,
				sectionComplete
			});

			this.detailsToUpdate = [];

			const i = this.sections.findIndex(
				(section) => section.Id === this.activeSectionId
			);

			let nextSectionIndex = 1 + i;

			//move to next section
			if (nextSectionIndex < this.sections.length) {
				const nextSection = this.sections[nextSectionIndex];

				this.dispatchEvent(
					new CustomEvent("sectionselect", {
						bubbles: true,
						composed: true,
						detail: {
							id: nextSection.Id
						}
					})
				);
			}

			this.dispatchEvent(new CustomEvent("refresh"));

			this.isLoading = false;
		} catch (error) {
			console.error(error);

			this.toast("Error", "An Error has occured", "error");
		} finally {
			this.isLoading = false;
		}
	}

	// async handleSaveForLater() {

	// }

	toast(
		title = "Success",
		message = "Application updated",
		variant = "success",
		mode = "dismissible"
	) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant,
				mode
			})
		);
	}
}
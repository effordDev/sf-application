import { api, track, LightningElement } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getApplication from "@salesforce/apex/ApplicationHelper.getApplication";
import getApplicationLanguages from "@salesforce/apex/ApplicationHelper.getApplicationLanguages";
import saveApplication from "@salesforce/apex/ApplicationHelper.saveApplication";

export default class ApplicationProgressIndicatorMain extends LightningElement {
    @api recordId;

	@track application = {};
	applicationLanguages = []

	language = 'English'
	defaultLanguages = [{label:'English', value:'English'}]

	activeSectionId = ''

	size = 12;
	smallDeviceSize = 12;
	mediumDeviceSize = 4;
	largeDeviceSize = 4;

	isLoading = false;

	async connectedCallback() {
		await this.fetchApplication()
		await this.fetchApplicationLanguages()

		this.setInitialActiveSection(this.sections)
	}

	get languages() {
		return [
			...this.defaultLanguages, 
			...(this.applicationLanguages.map(al => ({label: al.Language__c, value: al.Language__c})))
		]
	}
	get disableLanguagePicklist() {
		return this.languages.length === 1
	}

	get applicationDisplayName() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Display_Name__c || this.application?.Application_Display_Name__c
	}
	get displayDescription() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Display_Description__c || this.application?.Display_Description__c
	}
	get displayApplicationNumberText() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Application_Number__c || 'Application Number'
	}
	get displayApplicationStatusText() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Status__c || 'Status'
	}
	get displayApplicationCreatedDateText() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Created_Date__c || 'Created Date'
	}
	get displayCancelBtnLabel() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Cancel_Text__c || 'Cancel'
	}
	get displaySubmitBtnLabel() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Submit_Text__c || 'Submit'
	}
	get displaySaveBtnLabel() {
		return this.applicationLanguages
			.find(al => al.Language__c === this.language)
			?.Translated_Save_Text__c || 'Save & Close'
	}
	get createdDate() {
		return this.application?.CreatedDate;
	}
	get name() {
		return this.application?.Name;
	}
	get status() {
		return this.application?.Status__c;
	}
	get readOnly() {
		return this.application?.Read_Only__c
	}
	get sections() {
		return this.application?.Application_Sections__r || [];
	}
	get contact() {
		return this.application?.Applicant_Contact__r || {}
	}
	get sectionsComplete() {
		return this.application?.Application_Sections__r?.every(
			(section) => section?.Completed__c
		);
	}
	get submitBtnDisabled() {
		return !(this.sectionsComplete && !this.readOnly);
	}
	/* ----- */	

	get activeSection() {
		return this.sections?.find(s => s.Id === this.activeSectionId) || {}
	}

	setInitialActiveSection(sections) {

		if (sections.every(s => s.Completed__c)) {
			this.activeSectionId = (sections[sections.length - 1])?.Id
			return
		}

		this.activeSectionId = (sections.find(s => !s.Completed__c))?.Id
	}

	handleSectionSelect(event) {
		// console.log('caguth');
		// console.log(event.detail.id)
		this.activeSectionId = event.detail.id

		const el = this.template.querySelector('c-application-progress-sections')

		if (el) {
			el.setDetails(this.activeSectionId)
		}
	}
	handleRefresh() {
		this.toast()
		this.fetchApplication()
	}

	handleLoading() {
		this.isLoading = this.isLoading ? false : true
	}
	
	toast(
		title = 'Success',
		message = 'Application updated',
		variant = 'success',
		mode = 'dismissible'
	) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant,
				mode
			})
		)
	}
	/* ----- */	

	async fetchApplication() {
		try {
			this.isLoading = true

			this.application = await getApplication({ recordId: this.recordId });
			console.log(JSON.parse(JSON.stringify(this.application)));

		} catch (error) {
			console.error(error)
		} finally {
			this.isLoading = false
		}
	}

	async fetchApplicationLanguages() {
		try {
			this.isLoading = true
			this.applicationLanguages = await getApplicationLanguages({ applicationId: this.recordId })
		} catch (error) {
			console.error(error)
		} finally {
			this.isLoading = false
		}
	}

	handleLanguageChange(event) {
		this.language = event.detail.value
	}

	handleRefresh() {

		this.toast()
		this.fetchApplication()
	}

	handleLoading() {
		this.isLoading = this.isLoading ? false : true
	}

	async handleSubmit() {
		try {

			this.isLoading = true

			const app = {
				Id: this.recordId,
				Status__c: "Submitted"
			};
	
			this.application = await saveApplication({ app });
	
			this.toast(
				'Success',
				'Application Submitted',
				'success'
			)
	
			this.dispatchEvent(
				new CustomEvent('refresh')
			)
		} catch (error) {
			
			console.error(error)

			this.toast(
				'Error',
				'An Error has occured',
				'error'
			)
		} finally {
			this.isLoading = false
		}
	}

	toast(
		title = 'Success',
		message = 'Application updated',
		variant = 'success',
		mode = 'dismissible'
	) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant,
				mode
			})
		)
	}
}
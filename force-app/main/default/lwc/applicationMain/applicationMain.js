import { api, LightningElement } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplication from "@salesforce/apex/ApplicationHelper.getApplication";
import saveApplication from "@salesforce/apex/ApplicationHelper.saveApplication";

export default class ApplicationMain extends LightningElement {
	@api recordId;

	application = {};

	size = 12;
	smallDeviceSize = 12;
	mediumDeviceSize = 4;
	largeDeviceSize = 4;

	isLoading = false;

	connectedCallback() {
		this.fetchApplication();
	}

	get applicationDisplayName() {
		return this.application?.Application_Display_Name__c;
	}
	get displayDescription() {
		return this.application?.Display_Description__c;
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
		//editable status's
		// return !["New", "In Progress"].includes(this.status);
		return this.application?.Read_Only__c
	}
	get sections() {
		return this.application?.Application_Sections__r || [];
	}
	get sectionsComplete() {
		return this.application?.Application_Sections__r?.every(
			(section) => section?.Completed__c
		);
	}

	get submitBtnDisabled() {
		return !(this.sectionsComplete && !this.readOnly);
	}

	async fetchApplication() {
		try {
			this.isLoading = true

			this.application = await getApplication({ recordId: this.recordId });
			console.log(JSON.parse(JSON.stringify(this.application)));
		} catch (error) {
			//silent fail - check debugs
		} finally {
			this.isLoading = false
		}
	}

	handleRefresh() {

		this.toast()

		this.fetchApplication()
	}

	handleLoading() {
		this.isLoading = this.isLoading ? false : true
	}

	async handleSubmit() {
		
		const app = {
			Id: this.recordId,
			Status__c: "Submitted"
		};

		this.application = await saveApplication({ app });
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
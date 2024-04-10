import { api, track, LightningElement } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getFiles from "@salesforce/apex/ApplicationHelper.getFiles";
import renameFiles from "@salesforce/apex/ApplicationHelper.renameFiles";
import deleteFile from "@salesforce/apex/ApplicationHelper.deleteFile";

import { fileTypesMap } from "./utils";

export default class ApplicationInputFile extends NavigationMixin(LightningElement) {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api languages = [];
	@api isSectionComplete = false
	@track _detail = {};
	@api isCommunity = false

	files = [];
	srcFileURL = ''
	active = false
	disableDeleteBtn = false

	@api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	/*
	 * if required => make sure there is a value and required is == true
	 * if not required => return true
	 */
	@api get completed() {

		if (!this.required) {
			return true;
		}

		return !!this.files.length && this.required;
	}

	get boxClass() {
		return this.completed ? `slds-box` : `slds-box not-complete`;
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
					?.Translated_Text__c || this.detail?.Field_Label__c;
	}
	get required() {
		return this.detail?.Required__c;
	}
	get fileRename() {
		return this.detail?.File_Rename__c;
	}
	get acceptedFormats() {
		return this.detail?.Accepted_File_Types__c?.split(";") || []
	}
	get formattedAcceptedFormats() {
		return this.acceptedFormats.join(", ");
	}
	get allowDelete() {
		return !this.readOnly && !this.isSectionComplete
	}

	connectedCallback() {
		this.fetchFiles();
	}

	async fetchFiles() {
		this.files = (
			await getFiles({
				recordId: this.recordId,
				title: this.fileRename
			})
		).map((f) => {
			f.icon = `doctype:${fileTypesMap(f.FileExtension)}`;
			return f;
		});

		// console.log('files')
		// console.log(JSON.parse(JSON.stringify(this.files)))
	}

	async handleUploadFinished(event) {
		this.dispatchEvent(
			new CustomEvent("loading", {
				bubbles: true,
				composed: true
			})
		);

		const contentVersionIds = event.detail.files.map((f) => f.contentVersionId);

		if (this.fileRename && contentVersionIds.length) {
			await renameFiles({ contentVersionIds, name: this.fileRename });
		}

		await this.fetchFiles();

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Files_Uploaded__c: this.files.length
				}
			})
		);

		this.dispatchEvent(
			new CustomEvent("loading", {
				bubbles: true,
				composed: true
			})
		);
	}

	async handleDelete(event) {
		try {
			this.disableDeleteBtn = true

			const id = event.target.dataset.id;
	
			await deleteFile({ contentDocumentId: id });
			await this.fetchFiles();
	
			this.dispatchEvent(
				new CustomEvent("detailchange", {
					composed: true,
					bubbles: true,
					detail: {
						Id: this.id,
						Input_Files_Uploaded__c: this.files.length
					}
				})
			);
		} catch (error) {
			console.error(error)
		} finally {
			this.disableDeleteBtn = false
		}
	}

	handleView(event) {

		const contentVersionId = event.target.dataset.id

		// console.log(contentVersionId)
		if (!contentVersionId) {
			return
		}

		const file = this.files.find(file => file.Id === contentVersionId)

		if (!this.isCommunity) {
			this[NavigationMixin.Navigate]({
				type: 'standard__namedPage',
				attributes: {
					pageName: 'filePreview'
				},
				state : {
					selectedRecordId: file?.ContentDocumentId
				}
			}, false )
				
			return
		} else {
			
			const currentUrl = window.location.href
			const base = currentUrl.slice(0, currentUrl.indexOf('/s/'))
	
			const rendition = this.getRendition(file.FileType)
	
			const url = `${base}/sfc/servlet.shepherd/version/renditionDownload?rendition=${rendition}&versionId=${contentVersionId}`
			// console.log(url)
			
			this.srcFileURL = url
			this.active = true
		}
	}

	handleHideFile() {
		this.srcFileURL = ''
		this.active = false
	}

	getRendition(fileType) {
		switch(fileType) {
			case "PDF":
				return 'SVGZ'
			case "PNG":
				return 'ORIGINAL_Png'
			case "JPG":
				return 'ORIGINAL_Jpg'
			default:
				return 'THUMB720BY480'
		}

	}

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
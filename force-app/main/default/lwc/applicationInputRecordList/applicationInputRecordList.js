import { api, track, LightningElement } from "lwc";
import { deleteRecord } from "lightning/uiRecordApi";
import getFieldSet from "@salesforce/apex/ApplicationHelper.getFieldSet";
import getFieldSetData from "@salesforce/apex/ApplicationHelper.getFieldSetData";

export default class ApplicationInputRecordList extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@api language = "";
	@api languages = [];
	@track _detail = {};

	fieldSet = [];
	displayTableFieldSet = [];
	data = [];

	currentRowId = ''

	active = false;
	isLoading = false;
	formLoaded = false;
	editActive = false

	async connectedCallback() {
		// console.log("record list");
		// console.log(JSON.parse(JSON.stringify(this.detail)));

		try {
			this.isLoading = true;

			this.fieldSet = await this.fetchFieldSet(
				this.childsObjectApi,
				this.childFieldSetApi
			);
			console.log('fieldset');
			console.log((JSON.stringify(this.fieldSet)))
			this.displayTableFieldSet = await this.fetchFieldSet(
				this.childsObjectApi,
				this.childDisplayTableFieldSetApi || this.childFieldSetApi
			);
			await this.fetchFieldSetData();
		} catch (error) {
			console.error(JSON.parse(JSON.stringify(error)));
		} finally {
			this.isLoading = false;
		}
	}

	@api get detail() {
		return this._detail;
	}
	set detail(value) {
		this._detail = Object.assign({}, value);
	}

	@api get completed() {
		return this.required ? !!(this.data.length && this.required) : true;
	}
	get editable() {
		return !this.readOnly;
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
	get val() {
		return this.detail?.Input_Text__c;
	}
	get parentRelationshipApi() {
		return this.detail?.Child_To_Parent_Relationship_Api_Name__c;
	}
	get childsObjectApi() {
		return this.detail?.Child_sObject_API_Name__c;
	}
	get childFieldSetApi() {
		return this.detail?.Child_sObject_Field_Set_API_Name__c;
	}
	get childDisplayTableFieldSetApi() {
		return this.detail?.Child_sObject_Table_Field_Set_API_Name__c;
	}
	get allowDelete() {
		return this.detail?.Allow_Delete__c;
	}
	get allowEdit() {
		return this.detail?.Allow_Edit__c;
	}
	get columns() {
		let cols = this.displayTableFieldSet.map((field) => {
			const col = {
				label: field?.label,
				fieldName: field?.name,
				type: field?.type || 'text'
			};

			if (field?.type === 'percent') {
				col.type = 'percentfixed'
			}

			col.cellAttributes = {
				alignment: 'center' // Center the button within the cell
			}

			return col
		});

		if (this.allowEdit && this.editable) {
			cols = [
				...cols,
				{
					type: "button-icon",
					initialWidth: 34,
					typeAttributes: {
						iconName: "utility:edit",
						name: "edit",
						iconClass: "slds-icon-text-warning"
					}
				}
			];
		}

		if (this.allowDelete && this.editable) {
			cols = [
				...cols,
				{
					type: "button-icon",
					initialWidth: 34,
					typeAttributes: {
						iconName: "utility:delete",
						name: "delete",
						iconClass: "slds-icon-text-error"
					}
				}
			];
		}

		return cols;
	}
	get hideAddBtn() {
		return !this.active;
	}

	async fetchFieldSet(sObjectName, fieldSetName) {
		return JSON.parse(
			await getFieldSet({
				sObjectName,
				fieldSetName
			})
		).map((field) => {
			field.req = field?.required === "true";
			return field;
		});
	}

	async fetchFieldSetData() {
		this.data = await getFieldSetData({
			parentId: this.recordId,
			sObjectName: this.childsObjectApi,
			fieldSetName: this.childFieldSetApi,
			parentRelationship: this.parentRelationshipApi
		});
		console.log("DATA");
		console.log(JSON.parse(JSON.stringify(this.data)));
		// console.log(JSON.parse(JSON.stringify(this.data)))
	}

	handleRowAction(event) {
		console.log(JSON.parse(JSON.stringify(event.detail.action)));
		console.log(JSON.parse(JSON.stringify(event.detail.row)));

		const { Id } = event.detail.row;
		const { name } = event.detail.action;

		switch (name) {
			case "delete":
				this.deleteRow(Id);
				break;
			case "edit":
				this.editRow(Id)
		}
	}

	async deleteRow(id) {
		try {
			this.dispatchEvent(
				new CustomEvent("loading", {
					bubbles: true,
					composed: true
				})
			);

			await deleteRecord(id);
			this.fetchFieldSetData();
		} catch (error) {
			console.log(JSON.parse(JSON.stringify(error)));
		} finally {
			this.dispatchEvent(
				new CustomEvent("loading", {
					bubbles: true,
					composed: true
				})
			);
		}
	}

	editRow(id) {
		this.formLoaded = false
		this.currentRowId = id
		this.editActive = true
		this.active = false
	}

	handleSubmit(event) {
		//prevent submit and handle custom
		//prevent onsubmit from bubbling in DOM
		event.preventDefault();
		event.stopPropagation();

		const fields = event.detail.fields;
		fields[this.parentRelationshipApi] = this.recordId;
		this.template.querySelector("lightning-record-edit-form").submit(fields);
	}

	handleError(event) {
		console.error(JSON.parse(JSON.stringify(event.detail)));
	}

	handleFormLoad() {
		this.formLoaded = true;
	}

	async handleSuccess(event) {
		const inputFields = this.template.querySelectorAll("lightning-input-field");
		if (inputFields) {
			inputFields.forEach((field) => {
				field.reset();
			});
		}

		const payload = event.detail;
		console.log(JSON.stringify(payload));

		await this.fetchFieldSetData();

		this.editActive = false

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Record_List__c: this.data.length
				}
			})
		);
	}
	
	showInputs(event) {
		this.active = true;
	}

	hideInputs(event) {
		const inputFields = this.template.querySelectorAll("lightning-input-field");

		if (inputFields) {
			inputFields.forEach((field) => {
				field.reset();
			});
		}

		this.active = false;
		this.editActive = false
	}
}

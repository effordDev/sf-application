import { api, track, LightningElement } from "lwc";
import getFiles from '@salesforce/apex/ApplicationHelper.getFiles'
import renameFiles from '@salesforce/apex/ApplicationHelper.renameFiles'
import deleteFile from '@salesforce/apex/ApplicationHelper.deleteFile'

import { fileTypesMap } from './utils';

export default class ApplicationInputFile extends LightningElement {
	@api recordId;
	@api sectionId;
	@api readOnly;
	@track _detail = {};

     files = [] 

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

          // console.log('completed running')
          // const el = this.template.querySelector('.box')

          // if (el && !!this.files.length) {
          //      console.log('not-completed')
          //      el.classList.add('not-completed')
          // } else {
          //      el.classList.remove('not-completed')
          // }

          if (!this.required) {
               return true
          }

		return (!!this.files.length && this.required)
	}

     get boxClass() {
          return this.completed ? `slds-box` : `slds-box not-complete`
     }

	get id() {
		return this.detail?.Id;
	}
	get label() {
		return this.detail?.Field_Label__c;
	}
	get required() {
		return this.detail?.Required__c;
	}
     get fileRename() {
          return this.detail?.File_Rename__c;
     }
     get acceptedFormats() {
          return this.detail?.Accepted_File_Types__c.split(';') 
     }
     get formattedAcceptedFormats() {
          return this.acceptedFormats.join(', ') 
     }

     connectedCallback() {
          this.fetchFiles()
     }
  
     async fetchFiles() {

          this.files = (await getFiles({ 
               recordId:this.recordId,
               title: this.fileRename
          })).map(f =>{
               f.icon = `doctype:${fileTypesMap(f.FileExtension)}`
               return f
          })

          console.log('files')
          console.log(JSON.parse(JSON.stringify(this.files)))
     }

     async handleUploadFinished(event) {

          this.dispatchEvent(new CustomEvent('loading', {
               bubbles: true,
               composed: true
          }))

          const contentVersionIds = event.detail.files.map(f => f.contentVersionId)

          if (this.fileRename && contentVersionIds.length) {
               await renameFiles({ contentVersionIds, name: this.fileRename })
          }

          await this.fetchFiles()

          this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Files_Uploaded__c : this.files.length
				}
			})
		);

          this.dispatchEvent(new CustomEvent('loading', {
               bubbles: true,
               composed: true
          }))
     }

     async handleDelete(event) {

          const id = event.target.dataset.id

          await deleteFile({ contentDocumentId: id })
          await this.fetchFiles()

          this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
					Input_Files_Uploaded__c : this.files.length
				}
			})
		);
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
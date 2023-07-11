import { api } from "lwc";
import LightningModal from "lightning/modal";
import { getDataConnectorSourceObjectDataPreviewWithFields } from "lightning/analyticsWaveApi";

export default class ApplicationModal extends LightningModal {
	@api recordId;
	@api label;
	@api language = ''
	@api sectionId;
	@api readOnly;
	@api details = [];

	@api cancelBtnLabel = '';
	@api saveBtnLabel = '';
	
	get editable() {
		return !this.readOnly;
	}

	handleClose() {
		this.close("closed");
	}

	handleSave() {
		const appDetailsTypes = this.template.querySelectorAll(
			"c-application-detail-type.customInput"
		);

		let allValidArray = [];

		appDetailsTypes.forEach((curr) => {
			// console.log(curr)
			// console.log(curr.isValid())
			allValidArray.push(curr.isValid());
		});

		console.log(allValidArray)

		const isAllValid = allValidArray.every((item) => !!item);

		if (!isAllValid) {
			return;
		}

		this.close("save");
	}
}
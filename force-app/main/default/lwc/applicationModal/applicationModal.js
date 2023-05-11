import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class ApplicationModal extends LightningModal {
	@api recordId;
	@api label;
	@api sectionId;
	@api readOnly;
	@api details = [];

	get closeBtnLabel() {
		return this.readOnly ? "Close" : "Cancel";
	}
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
			allValidArray.push(curr.isValid());
		});

		const isAllValid = allValidArray.every((item) => !!item);

		if (!isAllValid) {
			return;
		}

		this.close("save");
	}
}
import { api, track, LightningElement } from 'lwc';

export default class ApplicationInputAddress extends LightningElement {
    @api recordId;
	@api sectionId;
	@api language = "";
	@api languages = [];
	@api readOnly;
	@track _detail = {};

    showMap = false

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
		return [...this.template.querySelectorAll("lightning-input-address")].reduce(
			(validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			},
			true
		);
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
    get streetLabel() {
        return this.detail?.Street_Label__c
    }
    get cityLabel() {
        return this.detail?.City_Label__c
    }
    get countryLabel() {
        return this.detail?.Country_Label__c
    }
    get provinceLabel() {
        return this.detail?.Province_Label__c
    }
    get postalCodeLabel() {
        return this.detail?.Postal_Code_Label__c
    }

    get streetVal() {
        return this.detail?.Input_Street__c || ''
    }
    get cityVal() {
        return this.detail?.Input_City__c || ''
    }
    get provinceVal() {
        return this.detail?.Input_State_Province__c || ''
    }
    get postalCodeVal() {
        return this.detail?.Input_Postal_Code__c || ''
    }
    get countryVal() {
        return this.detail?.Input_Country__c || ''
    }
    // get showMap() {
    //     return !!this.detail?.Input_Street__c
    // }
    get invalidAddress() {
        return !this.detail?.Input_Street__c && !this.detail?.Input_City__c
    }
    get mapMarkers() {
        return [
            {
                location: {
                    City: this.cityVal,
                    Country: this.countryVal,
                    PostalCode: this.postalCodeVal,
                    State: this.provinceVal,
                    Street: this.streetVal,
                },
            }
        ]
    }

    handleChange(event) {
		const {
            city,
            country,
            postalCode,
            province,
            street
        } = event.detail;

        // console.log(event)

        this.detail.Input_Street__c = street
        this.detail.Input_City__c = city
        this.detail.Input_State_Province__c = province 
        this.detail.Input_Postal_Code__c = postalCode
        this.detail.Input_Country__c = country

        // console.log(JSON.parse(JSON.stringify(this.mapMarkers)))

		this.dispatchEvent(
			new CustomEvent("detailchange", {
				composed: true,
				bubbles: true,
				detail: {
					Id: this.id,
                    Input_Street__c: street,
                    Input_City__c: city,
                    Input_State_Province__c: province,
                    Input_Postal_Code__c: postalCode,
                    Input_Country__c: country,
				}
			})
		);
	}

    handleShowMap() {
        this.showMap = true
    }
    handleHideMap() {
        this.showMap = false
    }
}
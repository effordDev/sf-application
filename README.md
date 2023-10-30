# sf-application

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Demo

[﻿screen-recorder-tue-may-23-2023-11-14-03.webm](https://github.com/effordDev/sf-application/assets/36901822/16ea4480-2926-4933-b18b-b6aa0b3801e9)

# Table of Contents
- [Overview](#overview)
- [Getting Started](#gettingStarted)
- [Creating Inputs / Display Text](#creatingInputs/DisplayText)
  - [To Customize Inputs](#toCustomizeInputs)
    - [Display Rich Text](#displayRichText)
    - [Display Text](#displayText)
    - [Input Checkbox Group](#inputCheckboxGroup)
    - [Input Currency](#inputCurrency)
    - [Input Date](#inputDate)
    - [Input Date Time](#inputDateTime)
    - [Input File](#inputFile)
    - [Input Flow](#inputFlow)
    - [Input Number](#inputNumber)
    - [Input Picklist](#inputPicklist)
    - [Input Radio Group](#inputRadioGroup)
    - [Input Record List](#inputRecordList)
    - [Input Text](#inputText)
    - [Input Text Area Long](#inputTextAreaLong)
    - [Custom Components](#customComponents)
- [Application Response Flattener](#applicationResponseFlattener)
  - [Configuration](#configuration)
    - [Target Field Definition](#targetFieldDefinition)
    - [Record-Triggered Flow](#record-TriggeredFlow)

## Overview <a name="overview"></a>

This module provides a way for admins to build an application/form using LWC's. This is accomplished by building a skeleton structure of your application using the custom objects:

```
Reference_Application__c
Reference_Application_Language__c
Reference_Application_Section__c
Reference_Application_Section_Language__c
Reference_Application_Detail__c
Reference_Application_Detail_Language__c
```

The individual instances of an application are represented using the following custom objects:

```
Application__c
Application_Language__c
Application_Section__c
Application_Section_Language__c
Application_Detail__c
Application_Detail_Language__c
```

Below is a link to the ERD of the objects involved.

[﻿View on canvas](https://app.eraser.io/workspace/j87XwvKXc9ZZ6Hkt9Vne?origin=share)

Component Hierarchy:

[﻿View on canvas](https://app.eraser.io/workspace/4mzdiBc2NqPL5mLv0VEY?origin=share)

## Getting Started <a name="gettingStarted"></a>

Navigate to the App **Reference Application Helper** To create an application, simply create a `Application__c` record and populate the lookup `Reference_Application__c` to the application you want your instance modeled after. This is will trigger a process to write the following mapping:

```
Reference_Application__c => Application__c
Reference_Application_Language__c => Application_Language__c
Reference_Application_Section__c => Application_Section__c
Reference_Application_Section_Language__c => Application_Section_Language__c
Reference_Application_Detail__c => Application_Detail__c
Application_Detail_Language__c => Reference_Application_Detail_Language__c
```

### Creating Inputs / Display Text <a name="creatingInputs/DisplayText"></a>

The record type of `Reference_Application_Detail__c` Determines the type of input.

The following are the currently supported input fields / display types (Record Types):

- Display Rich Text
- Display Text
- Input Checkbox Group
- Input Currency
- Input Date
- Input Date Time
- Input File
- Input Flow
- Input Number
- Input Picklist
- Input Radio Group
- Input Record List
- Input Text
- Input Text Area Long
- Custom Component

#### To Customize Inputs <a name="toCustomizeInputs"></a>:

- `Required__c` - Determines if the input must be completed before saving the section.

- `Field_Label__c` - Label of the input to show on application.

- `Sort_Order__c` - Order of which the field should display.

- `Small_Device_Size__c` - Determines how the width of the input on a small device.

- `Medium_Device_Size__c` - Determines how the width of the input on a medium device.

- `Large_Device_Size__c` - Determines how the width of the input on a large device

- `Reference_Parent_Application_Detail__c` - Determines parent dependant question

- `Parent_Dependent_Answer__c` - Specifies the answer to show child component (when parent is = to answer → child will show)

- `Alignment__c` - Configures alignment (Left, Center, Right)

- `Required__c` - Specfies if the input should require a value before save (**Only available for inputs**)

- `Field_Label__c` - Label of the input 

- `Sort Order` - Specifies the order of the details

- `Target Field API Name` to do

[﻿See SLDS Grid Doc](https://www.lightningdesignsystem.com/utilities/grid/)
[﻿Example](https://developer.salesforce.com/docs/component-library/bundle/lightning-layout-item/example/)

#### Display Rich Text <a name="displayRichText"></a>
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-formatted-rich-text</a>
- ```Display_Rich_Text__c``` - Rich text to be displayed

#### Display Text <a name="displayText"></a>
- Displays <a href="https://www.lightningdesignsystem.com/utilities/text">slds-text-body_regular</a>
- ```Display_Text__c``` - Text to be displayed

#### Input Checkbox <a name="inputCheckbox"></a>
- Saves value to `Input_Checkbox__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="checkbox"

#### Input Checkbox Group <a name="inputCheckboxGroup"></a>
- Saves value to `Input_Text_Long__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-checkbox-group/documentation">base lightning-checkbox-group</a>

#### Input Currency <a name="inputCurrency"></a>

- Saves value to `Input_Currency__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="currency"
- `Maximum` - Specifies maximum value
- `Minimum` - Specifies minimum value
- `Step` - The value of step constrains the numbers that users can enter. If you don't specify step, the default value of 1 allows users to enter only integers. To enable decimal number entry, specify a value for step that represents the number of decimal places accepted and the increment. For example, specifying step=".01" permits numbers such as 0.99 and 123456.78. Specifying step=".20" permits numbers such as 18.60 but not 18.61 or 18.70.

#### Input Date <a name="inputDate"></a>
- Saves value to `Input_Date__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="date"
- `Default_Value__c` - For Date/Datetime use "TODAY" so set the default to the current date.

#### Input Date Time <a name="inputDateTime"></a>
- Saves value to `Input_Datetime__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="datetime"
- `Default_Value__c` - For Date/Datetime use "TODAY" so set the default to the current date.

#### Input Email <a name="inputEmail"></a>
- Saves value to `Input_Text__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="email"
- `Pattern__c` - Regex pattern to validate input
- `Message_When_Pattern_Mismatch__c` - When using pattern, you can provide a custom validation error message using the message-when-pattern-mismatch attribute.

#### Input File <a name="inputFile"></a>
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-file-upload/documentation">base lightning-file-upload</a> 
- `File_Rename__c` - The name that will be set as the file that was uploaded
- `Accepted_File_Types__c` - Set valid file types

#### Input Flow <a name="inputFlow"></a>
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-flow/documentation">base lightning-flow</a> 
- `Flow_API_Name__c` - The name that will be set as the file that was uploaded
- `Pass_Application_Id_into_Flow__c` - If checked, will pass the Application Id into the flow - recordId (text variable - available for input)

#### Input Number <a name="inputNumber"></a>
- Saves value to `Input_Number__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="number"
- `Maximum` - Specifies maximum value
- `Minimum` - Specifies minimum value
- `Step` - The value of step constrains the numbers that users can enter. If you don't specify step, the default value of 1 allows users to enter only integers. To enable decimal number entry, specify a value for step that represents the number of decimal places accepted and the increment. For example, specifying step=".01" permits numbers such as 0.99 and 123456.78. Specifying step=".20" permits numbers such as 18.60 but not 18.61 or 18.70.

#### Input Picklist <a name="inputPicklist"></a>
- Saves value to `Input_Number__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-combobox</a> 
- `Picklist_Values__c` - 	Semicolon separated list of values (EX. 'Yes; No; Maybe')

#### Input Radio Group <a name="inputRadioGroup"></a>
- Saves value to `Input_Number__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> type="radio"
- `Radio_Group_Values__c` - 	Semicolon separated list of values (EX. 'Yes; No; Maybe')

#### Input Record List <a name="inputRecordList"></a>
- Provides a way to add child records to the application
- `Child_sObject_API_Name__c` - API name of SObject related to Application__c
- `Child_sObject_Field_Set_API_Name__c` - Field set displayed when creating records
- `Child_sObject_Table_Field_Set_API_Name__c` - Columns in table showing child records
- `Child_To_Parent_Relationship_Api_Name__c` - Lookup/MD API name to `Application__c` (typically `Application__c`)

#### Input Long Text Area <a name="inputLongTextArea"></a>
- Saves value to `Input_Text_Long__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-textarea/documentation">base lightning-textarea</a>
- `Radio_Group_Values__c` - 	Semicolon separated list of values (EX. 'Yes; No; Maybe')

#### Custom Components <a name="customComponents"></a>

To add a custom component to the application choose the record type `Custom_Component`.
Populate `Component_Name__c` and if you need to pass information to the component you can do using `Custom_Component_JSON__c`.

In the LWC `applicationDetailType.lwc` set up a getter to display your component.

Ex. - This adds a component called `serviceProviders.lwc`

![image](https://github.com/effordDev/sf-application/assets/36901822/83a6ece7-f425-45c5-bb74-d4a8f55722dc)

applicationDetailType.html

```html
<template lwc:if="{isCustomComponent}">
	<template lwc:if="{isServiceProvider}">
		<c-service-providers
			lwc:ref="input"
			record-id="{recordId}"
			detail="{detail}"
			read-only="{readOnly}"
		></c-service-providers>
	</template>
</template>
```

applicationDetailType.js

```js
get isCustomComponent() {
  return this.recordTypeName === "Custom_Component";
}
get customCmpName() {
  return this.detail?.Component_Name__c
}
get isServiceProvider() {
  return this.customCmpName === 'serviceProviders'
}
```

##### Example of getting JSON.

serviceProviders.js

```js
get customJson() {
  if (isJSON(this.detail.Custom_Component_JSON__c)) {
    return JSON.parse(this.detail.Custom_Component_JSON__c)
    }
  return {}
}
```

## Application Response Flattener <a name="applicationResponseFlattener"></a>
```Flatten Application Responses``` is an invokable Apex method that can be used in a Record-Triggered Flow to write responses from Application Detail records into specific fields on a target object.

- A Record-Triggered Flow will control when the automation runs to write the responses.
- Target fields are defined on the **Reference Application Detail** records.
- Field data-types are handled by the Apex and are based on the Reference Application Detail record type.
   - The data type of your target field should match, otherwise errors may occur.

### Configuration <a href="configuration"></a>

#### Target Field Definition <a href="targetFieldDefinition"></a>

For any application responses that you wish to write to a field, you must first populate the ```Target_Field_API_Name__c``` on the **Reference Application Detail** record.
> The ```Target_Field_API_Name__c``` should be the API name of the field you wish to write the resonse to on the target object.
> *(The target object will be specified in a Record-Triggered Flow)*

#### Record-Triggered Flow <a href="record-TriggeredFlow"></a>

To allow for configurability of the criteria that trigger the responses to be flattened, a Record-Triggered flow should be created on the *Application* object, and fire based on your desired criteria (such as **Status** changing to *Submitted*)

1. Create a Record-Triggered Flow on **Application** 
2. Invoke the ```Flatten Application Responses``` Apex method, passing in:
    - ```Application Id``` which is the record Id of the Application that triggered the flow
    - ```Target Object Record Id``` which is the Id of the specific record you want to write the responses to (where the Target Object Field API Names will be populated with their respective responses.

Coded while petting [﻿tokyo🐱‍👤](https://www.tokyotech.us)

<!--- Eraser file: https://app.eraser.io/workspace/Bv2FEHxAoXE57wdPDlh7 --->

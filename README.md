# sf-application

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Demo

[﻿screen-recorder-tue-may-23-2023-11-14-03.webm](https://github.com/effordDev/sf-application/assets/36901822/16ea4480-2926-4933-b18b-b6aa0b3801e9)

# Table of Contents
- [Overview](#overview)
- [Getting Started](#gettingstarted)
- [Creating Inputs / Display Text](#creatinginputsdisplaytext)
  - [To Customize Inputs](#tocustomizeinputs)
    - [Display Rich Text](#displayrichtext)
    - [Display Text](#displaytext)
    - [Input Address](#inputaddress)
    - [Input Checkbox Group](#inputcheckboxgroup)
    - [Input Currency](#inputcurrency)
    - [Input Date](#inputdate)
    - [Input Date Time](#inputdatetime)
    - [Input File](#inputfile)
    - [Input Flow](#inputflow)
    - [Input Lookup](#inputlookup)
    - [Input Number](#inputnumber)
    - [Input Picklist](#inputpicklist)
    - [Input Radio Group](#inputradiogroup)
    - [Input Record List](#inputrecordlist)
    - [Input Text](#inputtext)
    - [Input Text Area Long](#inputtextarealong)
    - [Custom Components](#customcomponents)
- [Application Response Flattener](#applicationresponseflattener)
  - [Configuration](#configuration)
    - [Target Field Definition](#targetfielddefinition)
    - [Record-Triggered Flow](#recordtriggeredflow)

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

## Getting Started <a name="gettingstarted"></a>

Navigate to the App **Reference Application Helper** To create an application, simply create a `Application__c` record and populate the lookup `Reference_Application__c` to the application you want your instance modeled after. This is will trigger a process to write the following mapping:

```
Reference_Application__c => Application__c
Reference_Application_Language__c => Application_Language__c
Reference_Application_Section__c => Application_Section__c
Reference_Application_Section_Language__c => Application_Section_Language__c
Reference_Application_Detail__c => Application_Detail__c
Application_Detail_Language__c => Reference_Application_Detail_Language__c
```

### Creating Inputs / Display Text <a name="creatinginputsdisplaytext"></a>

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

#### To Customize Inputs <a name="tocustomizeinputs"></a>:

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

#### Display Rich Text <a name="displayrichtext"></a>
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-formatted-rich-text</a>
- ```Display_Rich_Text__c``` - Rich text to be displayed

#### Display Text <a name="displaytext"></a>
- Displays <a href="https://www.lightningdesignsystem.com/utilities/text">slds-text-body_regular</a>
- ```Display_Text__c``` - Text to be displayed

#### Input Address <a name="inputaddress"></a>
- Saves value to 
  - `Input_Street__c`
  - `Input_City__c`
  - `Input_State_Province__c`
  - `Input_Postal_Code__c`
  - `Input_Country__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input-address/documentation">base lightning-input-address</a>
- Optionally display <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-map/documentation">base lightning-map</a>

#### Input Checkbox <a name="inputCheckbox"></a>
- Saves value to `Input_Checkbox__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="checkbox"

#### Input Checkbox Group <a name="inputcheckboxgroup"></a>
- Saves value to `Input_Text_Long__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-checkbox-group/documentation">base lightning-checkbox-group</a>

#### Input Currency <a name="inputcurrency"></a>

- Saves value to `Input_Currency__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="currency"
- `Maximum` - Specifies maximum value
- `Minimum` - Specifies minimum value
- `Step` - The value of step constrains the numbers that users can enter. If you don't specify step, the default value of 1 allows users to enter only integers. To enable decimal number entry, specify a value for step that represents the number of decimal places accepted and the increment. For example, specifying step=".01" permits numbers such as 0.99 and 123456.78. Specifying step=".20" permits numbers such as 18.60 but not 18.61 or 18.70.

#### Input Date <a name="inputdate"></a>
- Saves value to `Input_Date__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="date"
- `Default_Value__c` - For Date/Datetime use "TODAY" so set the default to the current date.

#### Input Date Time <a name="inputdatetime"></a>
- Saves value to `Input_Datetime__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="datetime"
- `Default_Value__c` - For Date/Datetime use "TODAY" so set the default to the current date.

#### Input Email <a name="inputEmail"></a>
- Saves value to `Input_Text__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="email"
- `Pattern__c` - Regex pattern to validate input
- `Message_When_Pattern_Mismatch__c` - When using pattern, you can provide a custom validation error message using the message-when-pattern-mismatch attribute.

#### Input File <a name="inputfile"></a>
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-file-upload/documentation">base lightning-file-upload</a> 
- `File_Rename__c` - The name that will be set as the file that was uploaded
- `Accepted_File_Types__c` - Set valid file types

#### Input Flow <a name="inputflow"></a>
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-flow/documentation">base lightning-flow</a> 
- `Flow_API_Name__c` - The name that will be set as the file that was uploaded
- `Pass_Application_Id_into_Flow__c` - If checked, will pass the Application Id into the flow - recordId (text variable - available for input)
- To require a flow, Set `Require__c` = true. Create an output variable called `isComplete` and set it to true once the flow is valid

#### Input Lookup <a name="inputlookup"></a>
- Saves value to `Input_Text__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="search"
- `Object_Label__c` - Specifies the label of the object to search
- `Object_API_Name__c` - Specifies the object to search
- `Province_Target_Field_API_Name__c` - Specifies the field to search Ex. 'Name' `WHERE Name LIKE =: inputString`
- `Other_Field_API_Name__c` - Specifies another field to show when searching
- `SLDS_Icon_Name__c` - Specifies the <a target='_blank' href='https://www.lightningdesignsystem.com/icons/'>slds icon to display</a> 

#### Input Number <a name="inputnumber"></a>
- Saves value to `Input_Number__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> - type="number"
- `Maximum` - Specifies maximum value
- `Minimum` - Specifies minimum value
- `Step` - The value of step constrains the numbers that users can enter. If you don't specify step, the default value of 1 allows users to enter only integers. To enable decimal number entry, specify a value for step that represents the number of decimal places accepted and the increment. For example, specifying step=".01" permits numbers such as 0.99 and 123456.78. Specifying step=".20" permits numbers such as 18.60 but not 18.61 or 18.70.

#### Input Picklist <a name="inputpicklist"></a>
- Saves value to `Input_Number__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-combobox</a> 
- `Picklist_Values__c` - 	Semicolon separated list of values (EX. 'Yes; No; Maybe')

#### Input Radio Group <a name="inputradiogroup"></a>
- Saves value to `Input_Number__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-input/documentation">base lightning-input</a> type="radio"
- `Radio_Group_Values__c` - 	Semicolon separated list of values (EX. 'Yes; No; Maybe')

#### Input Record List <a name="inputrecordlist"></a>
- Provides a way to add child records to the application
- `Child_sObject_API_Name__c` - API name of SObject related to Application__c
- `Child_sObject_Field_Set_API_Name__c` - Field set displayed when creating records
- `Child_sObject_Table_Field_Set_API_Name__c` - Columns in table showing child records
- `Child_To_Parent_Relationship_Api_Name__c` - Lookup/MD API name to `Application__c` (typically `Application__c`)

#### Input Long Text Area <a name="inputLongTextArea"></a>
- Saves value to `Input_Text_Long__c`
- Displays <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-textarea/documentation">base lightning-textarea</a>
- `Radio_Group_Values__c` - 	Semicolon separated list of values (EX. 'Yes; No; Maybe')

#### Custom Components <a name="customcomponents"></a>

To add a custom component to the application choose the record type `Custom_Component`.
Populate `Component_Name__c` and if you need to pass information to the component you can do using `Custom_Component_JSON__c`.

In the LWC `applicationDetailType.lwc` set up a getter to display your component.

This adds two components called `applicationContactInfo.lwc` and `applicationAccountInfo.lwc`

![image](https://github.com/effordDev/sf-application/assets/36901822/83a6ece7-f425-45c5-bb74-d4a8f55722dc)

applicationDetailType.html

```html
<template lwc:if={isCustomComponent}>
  <template lwc:if={isApplicationContactInfo}>
    <c-application-contact-info
      lwc:ref="input"
      record-id={recordId}
      section-id={sectionId}
      detail={detail}
      contact={contact}
      language={language}
      languages={languages}
      read-only={readOnly}
      class={inputDisplayClass}
    ></c-application-contact-info>
  </template>

  <template lwc:if={isApplicationAccountInfo}>
    <c-application-account-info
      lwc:ref="input"
      record-id={recordId}
      section-id={sectionId}
      detail={detail}
      account={account}
      language={language}
      languages={languages}
      read-only={readOnly}
      class={inputDisplayClass}
    ></c-application-account-info>
  </template>
</template>
```

applicationDetailType.js

```js
get isCustomComponent() {
  return this.recordTypeName === "Custom_Component"
}
get customCmpName() {
  return this.detail?.Component_Name__c
}
get isApplicationContactInfo() {
  return this.customCmpName === "c-application-contact-info"
}
get isApplicationAccountInfo() {
  return this.customCmpName === "c-application-account-info"
}
```

##### Example of getting JSON.

applicationAccountInfo.js

```js
get customJson() {
  if (isJSON(this.detail.Custom_Component_JSON__c)) {
    return JSON.parse(this.detail.Custom_Component_JSON__c)
    }
  return {}
}

const isJSON = (string) => {
  try {
    JSON.parse(string);
    return true;
  } catch (error) {
    return false;
  }
}
```

## Application Response Flattener <a name="applicationresponseflattener"></a>
```Flatten Application Responses``` is an invokable Apex method that can be used in a Record-Triggered Flow to write responses from Application Detail records into specific fields on a target object.

- A Record-Triggered Flow will control when the automation runs to write the responses.
- Target fields are defined on the **Reference Application Detail** records.
- Field data-types are handled by the Apex and are based on the Reference Application Detail record type.
   - The data type of your target field should match, otherwise errors may occur.

### Configuration <a href="configuration"></a>

#### Target Field Definition <a href="targetfielddefinition"></a>

For any application responses that you wish to write to a field, you must first populate the ```Target_Field_API_Name__c``` on the **Reference Application Detail** record.
> The ```Target_Field_API_Name__c``` should be the API name of the field you wish to write the resonse to on the target object.
> *(The target object will be specified in a Record-Triggered Flow)* 
For ```Input_Address``` types use: 
- `Street_Target_Field_API_Name__c`
- `City_Target_Field_API_Name__c`
- `Province_Target_Field_API_Name__c`
- `Postal_Code_Target_Field_API_Name__c`
- `Country_Target_Field_API_Name__c`

#### Record-Triggered Flow <a href="recordtriggeredflow"></a>

To allow for configurability of the criteria that trigger the responses to be flattened, a Record-Triggered flow should be created on the *Application* object, and fire based on your desired criteria (such as **Status** changing to *Submitted*)

1. Create a Record-Triggered Flow on **Application** 
2. Invoke the ```Flatten Application Responses``` Apex method, passing in:
    - ```Application Id``` which is the record Id of the Application that triggered the flow
    - ```Target Object Record Id``` which is the Id of the specific record you want to write the responses to (where the Target Object Field API Names will be populated with their respective responses.

Coded while petting [﻿tokyo🐱‍👤](https://www.tokyotech.us)

<!--- Eraser file: https://app.eraser.io/workspace/Bv2FEHxAoXE57wdPDlh7 --->

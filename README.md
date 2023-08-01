<p><a target="_blank" href="https://app.eraser.io/workspace/Bv2FEHxAoXE57wdPDlh7" id="edit-in-eraser-github-link"><img alt="Edit in Eraser" src="https://firebasestorage.googleapis.com/v0/b/second-petal-295822.appspot.com/o/images%2Fgithub%2FOpen%20in%20Eraser.svg?alt=media&amp;token=968381c8-a7e7-472a-8ed6-4a6626da5501"></a></p>

# sf-application
![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png "")

 Demo 

 [﻿screen-recorder-tue-may-23-2023-11-14-03.webm](https://github.com/effordDev/sf-application/assets/36901822/16ea4480-2926-4933-b18b-b6aa0b3801e9) 

This module provides a way for admins to build an application/form using LWC's. This is accomplished by building a skeleton structure of your application using the custom objects: `Reference_Application__c, Reference_Application_Section__c, Reference_Application_Detail__c`. The individual instances of an application are represented using the following custom objects: `Application__c, Application_Section__c, Application_Detail__c`. 

Below is a basic ERD of the objects involved.

 ERD 

[﻿View on canvas](https://app.eraser.io/workspace/Bv2FEHxAoXE57wdPDlh7?elements=W4XHUAysl0YEJB7lStMyAQ) 

## Getting Started
Naviagte to the App **Reference Application Helper** To create an application, simply create a `Application__c` record and populate the lookup `Reference_Application__c` to the application you want your instance modeled after. This is will trigger a process to write the following mapping: 

```
Reference_Application__c => Application__c
Reference_Application_Section__c => Application_Section__c
Reference_Application_Detail__c => Application_Detail__c
```
### Creating Inputs
The record type of `Reference_Application_Detail__c` Determines the type of input.

The following are the currently supported input fields:

- Input Text
- Input Text Area Long
- Input Picklist
- Input Number
- Input File
- Input Date Time
- Input Date
- Input Currency
- Input Checkbox
- Display Text
- Display Rich Text
- Custom Component
To Customize inputs:
`Required__c` - Determines if the input must be completed before saving the section.

`Field_Label__c` - Label of the input to show on application.

`Sort_Order__c` - Order of which the field should display.

`Small_Device_Size__c` - Determines how the width of the input on a small device.

`Medium_Device_Size__c` - Determines how the width of the input on a medium device.

`Large_Device_Size__c` - Determines how the width of the input on a large device
[﻿See SLDS Grid Doc](https://www.lightningdesignsystem.com/utilities/grid/)
[﻿Example](https://developer.salesforce.com/docs/component-library/bundle/lightning-layout-item/example/) 

#### Custom Components
To add a custom component to the application choose the record type `Custom_Component`.
Populate `Component_Name__c` and if you need to pass information to the component you can do using `Custom_Component_JSON__c`.

In the LWC `applicationDetailType.lwc` set up a getter to display your component.

Ex. - This adds a component called `serviceProviders.lwc` 

![image](https://github.com/effordDev/sf-application/assets/36901822/83a6ece7-f425-45c5-bb74-d4a8f55722dc "")

applicationDetailType.html

```html
<template lwc:if={isCustomComponent}>
  <template lwc:if={isServiceProvider}>
    <c-service-providers
      lwc:ref="input"
      record-id={recordId}
      detail={detail}
      read-only={readOnly}
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
## serviceProviders.js
`js get customJson() { if (isJSON(this.detail.Custom_Component_JSON__c)) { return JSON.parse(this.detail.Custom_Component_JSON__c) } return {} } ` 
Coded while petting [﻿tokyo🐱‍👤](https://www.tokyotech.us) 


<!--- Eraser file: https://app.eraser.io/workspace/Bv2FEHxAoXE57wdPDlh7 --->
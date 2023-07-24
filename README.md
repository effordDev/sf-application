# sf-application

<a href="https://githubsfdeploy.herokuapp.com?owner=effordDev&repo=sf-application">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
<br />
<a href="https://github.com/jsmithdev/sfdx-deploy-instructions">
  Deploy via sfdx instead
</a>

<details>
  <summary>
    Demo
  </summary>

  [screen-recorder-tue-may-23-2023-11-14-03.webm](https://github.com/effordDev/sf-application/assets/36901822/16ea4480-2926-4933-b18b-b6aa0b3801e9)

</details>

This module provides a way for admins to build an application/form using LWC's. This is accomplished by building a skeleton structure of your application using the custom objects: ```sf_Ref_Application__c, sf_Ref_Application_Section__c, sf_Ref_Application_Detail__c```. The individual instances of an application are represented using the following custom objects: ```sf-Application__c, sf-Application_Section__c, sf-Application_Detail__c```. 

Below is a basic ERD of the objects involved.
<details>
  <summary>
    ERD
  </summary>

  ![image](https://github.com/effordDev/sf-application/assets/36901822/282fcfa4-d1a9-4399-8156-732e263bebbf)
</details>

## Getting Started
Naviagte to the App **Reference Application Helper** To create an application, simply create a ```sf-Application__c``` record and populate the lookup ```sf_Ref_Application__c``` to the application you want your instance modeled after. This is will trigger a process to write the following mapping: 
```
  sf_Ref_Application__c => sf-Application__c
  sf_Ref_Application_Section__c => sf-Application_Section__c
  sf_Ref_Application_Detail__c => sf-Application_Detail__c
```
### Creating Inputs

The record type of ```sf_Ref_Application_Detail__c``` Determines the type of input.

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
```Required__c``` - Determines if the input must be completed before saving the section.

```Field_Label__c``` - Label of the input to show on application.

```Sort_Order__c``` - Order of which the field should display.

```Small_Device_Size__c``` - Determines how the width of the input on a small device.

```Medium_Device_Size__c``` - Determines how the width of the input on a medium device.

```Large_Device_Size__c``` - Determines how the width of the input on a large device
[See SLDS Grid Doc](https://www.lightningdesignsystem.com/utilities/grid/)
[Example](https://developer.salesforce.com/docs/component-library/bundle/lightning-layout-item/example/)

#### Custom Components

To add a custom component to the application choose the record type ```Custom_Component```.
Populate ```Component_Name__c``` and if you need to pass information to the component you can do using ```Custom_Component_JSON__c```.

In the LWC ```applicationDetailType.lwc``` set up a getter to display your component.

Ex. - This adds a component called ```serviceProviders.lwc```

![image](https://github.com/effordDev/sf-application/assets/36901822/83a6ece7-f425-45c5-bb74-d4a8f55722dc)


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

serviceProviders.js
```js
get customJson() {
  if (isJSON(this.detail.Custom_Component_JSON__c)) {
    return JSON.parse(this.detail.Custom_Component_JSON__c)
  }
  return {}
}
```
---
Coded while petting [tokyo🐱‍👤](https://www.tokyotech.us)

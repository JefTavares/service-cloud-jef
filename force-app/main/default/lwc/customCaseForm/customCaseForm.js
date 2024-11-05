import { LightningElement, api, wire, track } from "lwc";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import ID_FIELD from "@salesforce/schema/Case.Id";
import RTID_FIELD from "@salesforce/schema/Case.RecordTypeId";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class CustomCaseForm extends LightningElement {

  @track options;
  @track value;
  @api recordId;
  @api recordTypeId;

  @wire(getRecord, { recordId: "$recordId", fields: [STATUS_FIELD, RTID_FIELD] })
  caseRecord({ error, data }) {
    if (data) {
      this.value = getFieldValue(data, STATUS_FIELD);
      this.recordTypeId = getFieldValue(data, RTID_FIELD);
    }
  }

  @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: STATUS_FIELD })
  picklistResults({ error, data }) {
    if (data) {
      console.log("picklist data >>" + data.values);
      this.options = data.values;
    }
  }

  handleSave() {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[STATUS_FIELD.fieldApiName] = this.value;
    const recordInput = {
      fields: fields
    };
    updateRecord(recordInput).then((record) => {
      const evt = new ShowToastEvent({
        title: "Success",
        message: "Case Status updated successfully.!",
        variant: "success"
      });
      this.dispatchEvent(evt);
    });
  }

  handleChange(event) {
    this.value = event.detail.value;
  }
}
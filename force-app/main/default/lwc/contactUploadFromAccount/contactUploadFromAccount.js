import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import readFileData from "@salesforce/apex/ContactUploadFromAccountController.readFileData";
import loadFileData from "@salesforce/apex/ContactUploadFromAccountController.loadFileData";
import { CloseActionScreenEvent } from "lightning/actions";

export default class ContactUploadFromAccount extends LightningElement {
  error;
  isLoaded = false;
  showFileUpload = true;
  contactList; 
  @api recordId;
  strContentDocumentId;
  contactColumns = [
    { label: "First Name", fieldName: "FirstName" },
    { label: "Last Name", fieldName: "LastName" },
    { label: "Email", fieldName: "Email" }
  ];

  get acceptedFormats() {
    return [".csv"];
  }

  uploadFileHandler(event) {
    this.isLoaded = true;
    const uploadedFiles = event.detail.files;
    this.strContentDocumentId = uploadedFiles[0].documentId;

    readFileData({ contentDocumentId: this.strContentDocumentId })
      .then((result) => {
        this.isLoaded = false;
        window.console.log("result", JSON.stringify(result));
        let strMessage = result.message;
        this.contactList = result.Contacts;
        this.showFileUpload = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: strMessage.includes("success") ? "Success" : "Error",
            message: strMessage,
            variant: strMessage.includes("success") ? "success" : "error",
            mode: "dismissible"
          })
        );
      })
      .catch((error) => {
        this.isLoaded = false;
        this.error = error;

        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: JSON.stringify(error),
            variant: "error",
            mode: "sticky"
          })
        );
      });
  }

  loadContacts() {
    this.isLoaded = true;

    loadFileData({
      strAccountId: this.recordId,
      contactListObjects: JSON.stringify(this.contactList)
    })
      .then((result) => {
        window.console.log("result", JSON.stringify(result));
        let strMessage = result.message;

        if (strMessage.includes("success")) {
          this.dispatchEvent(new CloseActionScreenEvent());
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: strMessage,
              variant: "success",
              mode: "dismissible"
            })
          );
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: strMessage,
              variant: "error",
              mode: "dismissible"
            })
          );
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!!",
            message: JSON.stringify(error),
            variant: "error",
            mode: "sticky"
          })
        );
      });

    this.isLoaded = false;
  }
}
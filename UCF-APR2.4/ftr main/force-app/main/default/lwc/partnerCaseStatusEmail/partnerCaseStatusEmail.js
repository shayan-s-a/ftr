/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 19-08-2023
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   17-08-2023   Monir Zaman   Initial Version
 **/
import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";

import allEmailTemplate from "@salesforce/apex/aps_PartnerCaseStatusEmail.allEmailTemplate";
import getEmailInfo from "@salesforce/apex/aps_PartnerCaseStatusEmail.getEmailInfo";
import sendEmailController from "@salesforce/apex/aps_PartnerCaseStatusEmail.sendEmailController";

export default class PartnerCaseStatusEmail extends LightningElement {
  rId;
  eTempOptions;
  AllTemplate;
  eTempPreview;
  form1 = true;
  form2 = false;
  toEmail;
  ccEmail;
  subject;
  caseId;
  newCCEmail;
  newSubject;
  newETemplate;
  fileName;
  fileArr = [];

  @api set recordId(value) {
    this.rId = value;

    getEmailInfo({ rId: this.rId })
      .then((result) => {
        this.toEmail = JSON.parse(result).ToAddress;
        this.ccEmail = JSON.parse(result).CCAddress;
        this.subject = JSON.parse(result).Subject;
        this.caseId = JSON.parse(result).CaseId;
      })
      .catch((error) => {
        console.log(error);
      });
  }
  get recordId() {
    return this.rId;
  }

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  connectedCallback() {
    allEmailTemplate({})
      .then((result) => {
        var tmpArry = [];

        this.AllTemplate = JSON.parse(result);
        this.AllTemplate.forEach((field) => {
          tmpArry.push({
            label: field.Name,
            value: field.DeveloperName
          });

          this.eTempOptions = tmpArry;
        });
      })
      .catch((error) => {
        console.log(error);
      });
  }

  eTempOptionsChange(event) {
    this.AllTemplate.forEach((field) => {
      if (field.DeveloperName === event.detail.value) {
        this.eTempPreview = field.Markup.replaceAll(
          "{!relatedTo.Id}",
          this.caseId
        );
      }
    });
  }

  handleNextForm() {
    this.form1 = false;
    this.form2 = true;
  }

  handleCCEmailChange(event) {
    this.newCCEmail = event.target.value;
  }

  handleSubjectChange(event) {
    this.newSubject = event.target.value;
  }

  handleETempChange(event) {
    this.newETemplate = event.target.value;
  }

  handleFilesChange(event) {
    var fName = "";

    if (event.target.files.length > 0) {
      for (let i = 0; i < event.target.files.length; i++) {
        let file = event.target.files[i];
        let reader = new FileReader();
        reader.onload = (e) => {
          var fileContents = reader.result.split(",")[1];
          this.fileArr.push({
            fileName: file.name,
            fileContent: fileContents
          });
        };
        reader.readAsDataURL(file);

        fName = fName + file.name + ", ";
      }
    }

    this.fileName = fName;
  }

  handleSendEmail() {
    let emailDetails = {
      toAddress: this.toEmail,
      ccAddress: this.newCCEmail ? this.newCCEmail : this.ccEmail,
      subject: this.newSubject ? this.newSubject : this.subject,
      body: this.newETemplate ? this.newETemplate : this.eTempPreview,
      files: this.fileArr
    };

    sendEmailController({
      toAddress: emailDetails.toAddress,
      ccAddress: emailDetails.ccAddress,
      subject: emailDetails.subject,
      body: emailDetails.body,
      files: JSON.stringify(emailDetails.files),
      caseId: this.rId
    })
      .then((result) => {})
      .catch((error) => {
        console.log(error);
      });

    this.closeAction();
  }
}
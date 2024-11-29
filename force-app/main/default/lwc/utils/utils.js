/**
 * Created by EX300265 on 18/11/2024.
 */

import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Utils extends LightningElement {

  static showToast(context, variant, title, message, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    context.dispatchEvent(evt);
  }

  static splitString(stringToSplit, oldSeparator, newSeparator) {
    let arrayOfStrings = stringToSplit.split(oldSeparator);

    return arrayOfStrings.join(newSeparator);
  }

  static removeRef(data) {
    return JSON.parse(JSON.stringify(data));
  }

  static filterUndefined(data) {
    return data.filter(element => {
      return element !== undefined;
    });
  }

  static isEmptyString(content) {
    return content === null || content === undefined || content === "";
  }

  static isEmptyArray(content) {
    return content === null || content === undefined || content.length === 0;
  }

  static isEmptyObject(content) {
    let arr = Object.keys(content);
    return this.isEmptyArray(arr);
  }

  static getDateLocale(date) {
    return new Date(date).toLocaleDateString();
  }

  static getMonthName(date) {
    return date.toLocaleString("pt-BR", { month: "long" });
  }

  static getPtBrMonthName(monthNumber) {
    switch (monthNumber) {
      case "01":
        return "Janeiro";
      case "02":
        return "Fevereiro";
      case "03":
        return "Março";
      case "04":
        return "Abril";
      case "05":
        return "Maio";
      case "06":
        return "Junho";
      case "07":
        return "Julho";
      case "08":
        return "Agosto";
      case "09":
        return "Setembro";
      case "10":
        return "Outubro";
      case "11":
        return "Novembro";
      case "12":
        return "Dezembro";
      default:
        break;
    }
  }

  static getMonthNumber(monthName) {
    monthName = monthName.toLowerCase();
    switch (monthName) {
      case "janeiro":
        return "01";
      case "fevereiro":
        return "02";
      case "março":
        return "03";
      case "abril":
        return "04";
      case "maio":
        return "05";
      case "junho":
        return "06";
      case "julho":
        return "07";
      case "agosto":
        return "08";
      case "setembro":
        return "09";
      case "outubro":
        return "10";
      case "novembro":
        return "11";
      case "dezembro":
        return "12";
      default:
        break;
    }
  }
}

const invokeWorkspaceAPI = (methodName, methodArgs) => {
  return new Promise((resolve, reject) => {
    const apiEvent = new CustomEvent("internalapievent", {
      bubbles: true,
      composed: true,
      cancelable: false,
      detail: {
        category: "workspaceAPI",
        methodName,
        methodArgs,
        callback: (err, response) => (err ? reject(err) : resolve(response))
      }
    });

    window.dispatchEvent(apiEvent);
  });

};

export {
  invokeWorkspaceAPI
};
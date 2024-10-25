public with sharing class ContactUploadFromAccountController {
  @AuraEnabled
  public static Map<String, Object> readFileData(Id contentDocumentId) {
    String strMessage;
    List<Contact> contactList = new List<Contact>();
    Map<String, Object> mapResponse = new Map<String, Object>();

    if (contentDocumentId != null) {
      ContentVersion contentVersionObj = [
        SELECT Id, VersionData
        FROM ContentVersion
        WHERE ContentDocumentId = :contentDocumentId
      ];
      List<String> contactRecords = contentVersionObj.VersionData.toString()
        .split('\n');
      System.debug('contactRecords are ' + contactRecords);

      //Removing the Header
      contactRecords.remove(0);

      for (String contactRecord : contactRecords) {
        System.debug('contactRecord is ' + contactRecord);
        if (String.isNotBlank(contactRecord)) {
          Contact objContact = new Contact();
          List<String> contactInfo = contactRecord.split(',');
          objContact.FirstName = contactInfo[0];
          objContact.LastName = contactInfo[1];
          objContact.Email = contactInfo[2];
          contactList.add(objContact);
        }
      }

      Database.DeleteResult deleteResult = Database.delete(
        contentDocumentId,
        true
      );

      mapResponse.put('Contacts', contactList);
      mapResponse.put('message', 'File read successfully!!!');
    }

    return mapResponse;
  }

  @AuraEnabled
  public static Map<String, Object> loadFileData(
    Id strAccountId,
    String contactListObjects
  ) {
    List<Contact> contactList = new List<Contact>();
    Map<String, Object> mapResponse = new Map<String, Object>();

    try {
      System.debug('contactListObjects is ' + contactListObjects);

      contactList = (List<Contact>) JSON.deserialize(
        contactListObjects,
        List<Contact>.class
      );

      for (Contact objContact : contactList) {
        objContact.AccountId = strAccountId;
      }

      if (contactList.size() > 0) {
        insert contactList;
        mapResponse.put('message', 'Contacts loaded successfully');
      } else {
        mapResponse.put(
          'message',
          'Please check the Contacts before uploading'
        );
      }
    } catch (Exception e) {
      mapResponse.put(
        'message',
        'Some error occured. Please reach out to your System Admin'
      );
      system.debug('Exception is ' + e.getMessage());
    }

    return mapResponse;
  }
}
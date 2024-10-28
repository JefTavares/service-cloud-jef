ComponentViewController.DataWrapper dataWrapper = new ComponentViewController.DataWrapper();

dataWrapper.metadataName = 'Afinidades';
dataWrapper.objectApiName = 'Account';
dataWrapper.recordId = '';


ComponentViewController.getRecords(JSON.serialize(dataWrapper));


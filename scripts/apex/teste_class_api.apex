ComponentViewController.DataWrapper dataWrapper = new ComponentViewController.DataWrapper();

dataWrapper.metadataName = 'Afinidades';
dataWrapper.objectApiName = 'Account';
dataWrapper.recordId = '001HZ00000KaHk5YAF'; //conta jeferson


Map<String, String> teste = ComponentViewController.getRecords(JSON.serialize(dataWrapper));

System.debug('OUT--->' + teste);


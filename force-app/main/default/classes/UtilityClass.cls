/**
 * Created by EX300265 on 05/11/2024.
 */

public with sharing class UtilityClass {

    public static String replaceValues(String value, Map<String, String> retrieveValues) {
        return retrieveValues.get(value);
    }

}
/*
Use of Class : This class will be ue as Seletor class for Custom Metadta 
*/
public with sharing class MetadataSelector {
   
    //Author - TCS
   /* Method is Select Custom Metadta for Two Way Communication Switch Enablement */
   public static Map<String, Two_way_communication__mdt> getTwoWayCommSwitchMtData() {
       Map<String, Two_way_communication__mdt> twoWayMtdataMap = Two_way_communication__mdt.getAll();
       return twoWayMtdataMap;
    }
   
 }
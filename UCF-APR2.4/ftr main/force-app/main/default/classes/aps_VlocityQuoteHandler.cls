/**
 * @description       :
 * @author            : Monir Zaman
 * @group             :
 * @last modified on  : 28-09-2023
 * @last modified by  : Monir Zaman
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   11-09-2023   Monir Zaman   Initial Version
 **/
public with sharing class aps_VlocityQuoteHandler {
  @testVisible public static Boolean stopTrigger = false;
public static void processAttr_After(Set<Id> setOLIId) {
  List<OpportunityLineItem> lstNewOLI = new List<OpportunityLineItem>();
  Set<Id> setQLIIds = new Set<Id>();
  Map<String, String> mapQLIvsSAddress = new Map<String, String>();

  for (OpportunityLineItem oli : [
    SELECT
      Id,
      Product2.Name,
      QuoteLineItem__r.vlocity_cmt__ParentItemId__c,
      QuoteLineItem__c
    FROM OpportunityLineItem
    WHERE Id IN :setOLIId
  ]) {
    if (oli.Product2.Name.contains('EVPL (Z Location)')) {
      setQLIIds.add(oli.QuoteLineItem__r.vlocity_cmt__ParentItemId__c);
    }
  }

  for (OpportunityLineItem oli : [
    SELECT
      Id,
      Product2.Name,
      QuoteLineItem__r.vlocity_cmt__ParentItemId__c,
      QuoteLineItem__c,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingStreet,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingCity,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingState,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode
    FROM OpportunityLineItem
    WHERE QuoteLineItem__c IN :setQLIIds
  ]) {
    mapQLIvsSAddress.put(
      oli.QuoteLineItem__c,
      oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingStreet +
        ',' +
        oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingCity +
        ',' +
        oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingState +
        ',' +
        oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode
    );
  }

  for (OpportunityLineItem oli : [
    SELECT
      Id,
      Product2.Name,
      vlocity_cmt__JSONAttribute__c,
      QuoteLineItem__r.vlocity_cmt__JSONAttribute__c,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingStreet,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingCity,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingState,
      QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
      QuoteLineItem__r.vlocity_cmt__OneTimeCharge__c,
      QuoteItem__r.Service_Address__c,
      QuoteItem__r.AdjustedNRC__c,
      QuoteLineItem__c,
      QuoteLineItem__r.vlocity_cmt__ParentItemId__c
    FROM OpportunityLineItem
    WHERE Id IN :setOLIId
  ]) {
    String tmpData = '';
    String tmpSpeed = '';
    String tmpIpBlocks = '';
    String tmpClassOfService = '';
    String tmpPBXHandOff = '';
    String tmpDIDIncludedNumber = '';
    String tmpOverageRate = '';
    String tmpIncludedLDBlockOfTime = '';
    String tmpMinuteBlocks = '';
    String tmpFirewallModel = '';

    if (oli.QuoteLineItem__c != null) {
      Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(
        oli.vlocity_cmt__JSONAttribute__c
      );

      if ((List<object>) mapResponse.get('FTR_ENT_PRI_ATTCAT') != null) {
        for (
          Object recObj : (List<object>) mapResponse.get('FTR_ENT_PRI_ATTCAT')
        ) {
          Map<String, Object> mapAttributes = (Map<String, Object>) recObj;

          String attName = String.valueOf(
            mapAttributes.get('attributedisplayname__c')
          );

          if (attName.equals('Speed')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpSpeed = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('IP Blocks')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpIpBlocks = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('Class of Service')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpClassOfService = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('PBX Hand Off')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpPBXHandOff = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('DID Included Number')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            tmpDIDIncludedNumber = String.valueOf(
              mapRunTimeInfo.get('value')
            );
          }

          if (attName.equals('Overage Rate')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            tmpOverageRate = String.valueOf(mapRunTimeInfo.get('value'));
          }

          if (attName.equals('Included LD Block of Time')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpIncludedLDBlockOfTime = String.valueOf(
              mapSelectedItem.get('value')
            );
          }

          if (attName.equals('Minute Blocks')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpMinuteBlocks = String.valueOf(mapSelectedItem.get('value'));
          }
        }
      }

      if ((List<object>) mapResponse.get('FTR_ENT_TECH_ATTCAT') != null) {
        for (
          Object recObj : (List<object>) mapResponse.get(
            'FTR_ENT_TECH_ATTCAT'
          )
        ) {
          Map<String, Object> mapAttributes = (Map<String, Object>) recObj;

          String attName = String.valueOf(
            mapAttributes.get('attributedisplayname__c')
          );

          if (attName.equals('Firewall Model')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpFirewallModel = String.valueOf(mapSelectedItem.get('value'));
          }
        }
      }

      tmpData =
        oli.Product2.Name +
        (String.isEmpty(tmpSpeed) ? '' : '/' + tmpSpeed) +
        (String.isEmpty(tmpIpBlocks) ? '' : '/' + tmpIpBlocks) +
        (String.isEmpty(tmpClassOfService) ? '' : '/' + tmpClassOfService) +
        (String.isEmpty(tmpPBXHandOff) ? '' : '/' + tmpPBXHandOff) +
        (String.isEmpty(tmpDIDIncludedNumber)
          ? ''
          : '/' + tmpDIDIncludedNumber) +
        (String.isEmpty(tmpOverageRate) ? '' : '/ORate' + tmpOverageRate) +
        (String.isEmpty(tmpIncludedLDBlockOfTime)
          ? ''
          : '/' + tmpIncludedLDBlockOfTime) +
        (String.isEmpty(tmpMinuteBlocks)
          ? ''
          : '/MBlocks' + tmpMinuteBlocks) +
        (String.isEmpty(tmpFirewallModel) ? '' : '/' + tmpFirewallModel);
    }

    oli.Attribute_Info__c = (oli.QuoteLineItem__c != null)
      ? tmpData
      : oli.Product2.Name;

    oli.Service_Address__c = (oli.QuoteLineItem__c != null)
      ? oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingStreet +
        ',' +
        oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingCity +
        ',' +
        oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingState +
        ',' +
        oli.QuoteLineItem__r.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode
      : oli.QuoteItem__r.Service_Address__c;

    oli.NRC__c = (oli.QuoteLineItem__c != null)
      ? oli.QuoteLineItem__r.vlocity_cmt__OneTimeCharge__c
      : oli.QuoteItem__r.AdjustedNRC__c;

    oli.ZAddress__c = mapQLIvsSAddress.get(
      oli.QuoteLineItem__r.vlocity_cmt__ParentItemId__c
    );

    lstNewOLI.add(oli);
  }

  update lstNewOLI;
}

public static void processAttr_Before(List<OpportunityLineItem> listOli) {
    if (stopTrigger && Test.isRunningTest()) {
          return;
    }
  Map<Id, Id> mapOLIvsQLI = new Map<Id, Id>();
  Map<Id, Id> mapOLIvsSQI = new Map<Id, Id>();
  Map<Id, Id> mapOLIvsProductId = new Map<Id, Id>();
  Map<Id, String> mapPIdvsProName = new Map<Id, String>();
  Map<Id, String> mapQLIvsSAddress = new Map<Id, String>();
  Map<Id, String> mapQLIvsParentSAddress = new Map<Id, String>();
  Map<Id, Id> mapQLIvsParentId = new Map<Id, Id>();
  Map<Id, Decimal> mapQLIvsNRC = new Map<Id, Decimal>();
  Map<Id, String> mapSQIvsSAddress = new Map<Id, String>();
  Map<Id, Decimal> mapSQIvsNRC = new Map<Id, Decimal>();

  for (OpportunityLineItem oli : listOli) {
    if (oli.QuoteLineItem__c != null) {
      mapOLIvsQLI.put(oli.Id, oli.QuoteLineItem__c);
    }

    if (oli.QuoteItem__c != null) {
      mapOLIvsSQI.put(oli.Id, oli.QuoteItem__c);
    }

    if (oli.Product2Id != null) {
      mapOLIvsProductId.put(oli.Id, oli.Product2Id);
    }
  }

  if (mapOLIvsProductId.values() != null) {
    for (Product2 pro : [
      SELECT Id, Name
      FROM Product2
      WHERE Id = :mapOLIvsProductId.values()
    ]) {
      mapPIdvsProName.put(pro.Id, pro.Name);
    }
  }

  if (mapOLIvsQLI.values() != null) {
    for (QuoteLineItem qli : [
      SELECT
        Id,
        Product2.Name,
        vlocity_cmt__ParentItemId__c,
        vlocity_cmt__ServiceAccountId__r.ShippingStreet,
        vlocity_cmt__ServiceAccountId__r.ShippingCity,
        vlocity_cmt__ServiceAccountId__r.ShippingState,
        vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
        vlocity_cmt__OneTimeCharge__c
      FROM QuoteLineItem
      WHERE Id = :mapOLIvsQLI.values()
    ]) {
      mapQLIvsSAddress.put(
        qli.Id,
        qli.vlocity_cmt__ServiceAccountId__r.ShippingStreet +
          ',' +
          qli.vlocity_cmt__ServiceAccountId__r.ShippingCity +
          ',' +
          qli.vlocity_cmt__ServiceAccountId__r.ShippingState +
          ',' +
          qli.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode
      );

      if (
        qli.vlocity_cmt__ParentItemId__c != null &&
        qli.Product2.Name.contains('EVPL (Z Location)')
      ) {
        mapQLIvsParentId.put(qli.Id, qli.vlocity_cmt__ParentItemId__c);
      }

      mapQLIvsNRC.put(qli.Id, qli.vlocity_cmt__OneTimeCharge__c);
    }
  }

  if (mapOLIvsSQI.values() != null) {
    for (SterlingQuoteItem__c sqi : [
      SELECT Id, AdjustedNRC__c, Service_Address__c
      FROM SterlingQuoteItem__c
      WHERE Id = :mapOLIvsSQI.values()
    ]) {
      mapSQIvsSAddress.put(sqi.Id, sqi.Service_Address__c);
      mapSQIvsNRC.put(sqi.Id, sqi.AdjustedNRC__c);
    }
  }

  if (mapQLIvsParentId.values() != null) {
    for (QuoteLineItem qli : [
      SELECT
        Id,
        Product2.Name,
        vlocity_cmt__ParentItemId__c,
        vlocity_cmt__ServiceAccountId__r.ShippingStreet,
        vlocity_cmt__ServiceAccountId__r.ShippingCity,
        vlocity_cmt__ServiceAccountId__r.ShippingState,
        vlocity_cmt__ServiceAccountId__r.ShippingPostalCode
      FROM QuoteLineItem
      WHERE Id = :mapQLIvsParentId.values()
    ]) {
      for (Id oliID : mapQLIvsParentId.keySet()) {
        if (mapQLIvsParentId.get(oliID) == qli.Id) {
          mapQLIvsParentSAddress.put(
            oliID,
            qli.vlocity_cmt__ServiceAccountId__r.ShippingStreet +
              ',' +
              qli.vlocity_cmt__ServiceAccountId__r.ShippingCity +
              ',' +
              qli.vlocity_cmt__ServiceAccountId__r.ShippingState +
              ',' +
              qli.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode
          );
        }
      }
    }
  }

  for (OpportunityLineItem oli : listOli) {
    String tmpData = '';
    String tmpSpeed = '';
    String tmpIpBlocks = '';
    String tmpClassOfService = '';
    String tmpPBXHandOff = '';
    String tmpDIDIncludedNumber = '';
    String tmpOverageRate = '';
    String tmpIncludedLDBlockOfTime = '';
    String tmpMinuteBlocks = '';
    String tmpFirewallModel = '';

    if (oli.QuoteLineItem__c != null) {
      Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(
        oli.vlocity_cmt__JSONAttribute__c
      );

      if ((List<object>) mapResponse.get('FTR_ENT_PRI_ATTCAT') != null) {
        for (
          Object recObj : (List<object>) mapResponse.get('FTR_ENT_PRI_ATTCAT')
        ) {
          Map<String, Object> mapAttributes = (Map<String, Object>) recObj;

          String attName = String.valueOf(
            mapAttributes.get('attributedisplayname__c')
          );

          if (attName.equals('Speed')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpSpeed = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('IP Blocks')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpIpBlocks = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('Class of Service')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpClassOfService = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('PBX Hand Off')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpPBXHandOff = String.valueOf(mapSelectedItem.get('value'));
          }

          if (attName.equals('DID Included Number')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            tmpDIDIncludedNumber = String.valueOf(
              mapRunTimeInfo.get('value')
            );
          }

          if (attName.equals('Overage Rate')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            tmpOverageRate = String.valueOf(mapRunTimeInfo.get('value'));
          }

          if (attName.equals('Included LD Block of Time')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpIncludedLDBlockOfTime = String.valueOf(
              mapSelectedItem.get('value')
            );
          }

          if (attName.equals('Minute Blocks')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpMinuteBlocks = String.valueOf(mapSelectedItem.get('value'));
          }
        }
      }

      if ((List<object>) mapResponse.get('FTR_ENT_TECH_ATTCAT') != null) {
        for (
          Object recObj : (List<object>) mapResponse.get(
            'FTR_ENT_TECH_ATTCAT'
          )
        ) {
          Map<String, Object> mapAttributes = (Map<String, Object>) recObj;

          String attName = String.valueOf(
            mapAttributes.get('attributedisplayname__c')
          );

          if (attName.equals('Firewall Model')) {
            Object runTimeInfo = mapAttributes.get('attributeRunTimeInfo');
            Map<String, Object> mapRunTimeInfo = (Map<String, Object>) runTimeInfo;

            Object selectedItem = mapRunTimeInfo.get('selectedItem');
            Map<String, Object> mapSelectedItem = (Map<String, Object>) selectedItem;

            tmpFirewallModel = String.valueOf(mapSelectedItem.get('value'));
          }
        }
      }

      tmpData =
        mapPIdvsProName.get(oli.Product2Id) +
        (String.isEmpty(tmpSpeed) ? '' : '/' + tmpSpeed) +
        (String.isEmpty(tmpIpBlocks) ? '' : '/' + tmpIpBlocks) +
        (String.isEmpty(tmpClassOfService) ? '' : '/' + tmpClassOfService) +
        (String.isEmpty(tmpPBXHandOff) ? '' : '/' + tmpPBXHandOff) +
        (String.isEmpty(tmpDIDIncludedNumber)
          ? ''
          : '/' + tmpDIDIncludedNumber) +
        (String.isEmpty(tmpOverageRate) ? '' : '/ORate' + tmpOverageRate) +
        (String.isEmpty(tmpIncludedLDBlockOfTime)
          ? ''
          : '/' + tmpIncludedLDBlockOfTime) +
        (String.isEmpty(tmpMinuteBlocks)
          ? ''
          : '/MBlocks' + tmpMinuteBlocks) +
        (String.isEmpty(tmpFirewallModel) ? '' : '/' + tmpFirewallModel);
    }

    oli.Attribute_Info__c = (oli.QuoteLineItem__c != null)
      ? tmpData
      : mapPIdvsProName.get(oli.Product2Id);

    oli.Service_Address__c = (oli.QuoteLineItem__c != null)
      ? mapQLIvsSAddress.get(oli.QuoteLineItem__c)
      : mapSQIvsSAddress.get(oli.QuoteItem__c);

    oli.NRC__c = (oli.QuoteLineItem__c != null)
      ? mapQLIvsNRC.get(oli.QuoteLineItem__c)
      : mapSQIvsNRC.get(oli.QuoteItem__c);

    oli.ZAddress__c = mapQLIvsParentSAddress.get(oli.QuoteLineItem__c);
  }
}
}
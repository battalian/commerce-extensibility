/**
 * BuyerGroupRegionEvaluationSample is a sample implementation of the BuyerGroupEvaluationService used to determine buyer group IDs for a user based on region.
 * The use case for this sample implementation is as follows:
 * - Out-of-the-box buyer groups based on account, market, and data cloud segment should be returned for both logged-in and guest users.
 * - In addition, buyer groups associated with the user's region (passed as a request parameter) are also returned.
 * - The region can be determined from various sources like user preferences, geolocation, or explicit selection.
 * 
 * Data model changes to support the sample code are as follows:
 * - Region__c: Stores the supported regions in the Region field.
 * - Active_Region__c: Stores the association between deviceId (Guest UUID cookie value) and Region__c. 
 *                     This can typically be populated via a custom LWC component where a customer chooses a region from a list of available regions.
 * - Region_Buyer_Group__c: A junction entity that stores a static mapping between Region__c and the buyer groups associated with it.
 * 
 * Important considerations in the code below:
 * - Buyer group responses should be cached using Org Cache to support low latency. 
 * - No more than MAX_BUYER_GROUPS should be returned by the code. 
 */
public without sharing class BuyerGroupShareableURLSample extends commercebuygrp.BuyerGroupEvaluationService {

    private static Integer MAX_BUYER_GROUPS = 30;

    public override commercebuygrp.BuyerGroupResponse getBuyerGroupIds(commercebuygrp.BuyerGroupRequest request) {
        Map<String, Object> requestParameters = request.getRequestContextParameters();

        //Here we are retreiving value that we set in Request Param for the store using Shareable URL 
        String region  = (Boolean) requestParameters.get('region');
       

        // Getting default out-of-the-box buyer groups based on existing logic: account, market, and data cloud segment-based buyer groups
        commercebuygrp.BuyerGroupResponse defaultBuyerGroupResponse = super.getBuyerGroupIds(request);
        Set<String> buyerGroupIds = new Set<String>(defaultBuyerGroupResponse.getBuyerGroupIds());

        if(region!=null && region.equals('asia')){
            //filter buyer groups based on region value passed in Request
        }
        // Buyer group extensibility supports only up to MAX_BUYER_GROUPS buyer groups
        if (buyerGroupIds.size() > MAX_BUYER_GROUPS) {
            commercebuygrp.BuyerGroupResponse response = new commercebuygrp.BuyerGroupResponse();
            String errorMessage = 'More than ' + MAX_BUYER_GROUPS + ' buyer groups retrieved for the user. Contact Store Administrator.';
            response.setError(errorMessage, errorMessage);
            return response;
        }

        orgPartition.put(cacheKey, buyerGroupIds);
        return new commercebuygrp.BuyerGroupResponse(buyerGroupIds);
    }
} 
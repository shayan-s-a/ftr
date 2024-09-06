/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class ftr_ResourcemanagementTest {
    
    @isTest
    public static void resourcemanagementTest(){
        ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort httpPort = new ftr_Resourcemanagement.ResourceManagement_ResourceManagementHttpPort();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ftr_WebServiceMockImpl());
        httpPort.RetrieveHuntGroupDetails(new ftr_Resourcemanagement.msg_RetrieveHuntGroupDetailsRequest());
        httpPort.RetrieveServiceDesign(new ftr_Resourcemanagement.msg_RetrieveServiceDesignRequest());
        httpPort.GeneratePasscode(new ftr_Resourcemanagement.msg_GeneratePasscodeRequest());
        httpPort.ReserveTelephoneNumber(new ftr_Resourcemanagement.msg_ReserveTelephoneNumberRequest());
        httpPort.RetrievePreferredExchange(new ftr_Resourcemanagement.msg_RetrievePreferredExchangeRequest());
        httpPort.RetrieveCustomerFacilitiesSummary(new ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesSummaryRequest());
        httpPort.ReleaseTelephoneNumber(new ftr_Resourcemanagement.msg_ReleaseTelephoneNumberRequest());
        httpPort.RetrieveCustomerFacilities(new ftr_Resourcemanagement.msg_RetrieveCustomerFacilitiesRequest());
        httpPort.SynchronizePlantDetails(new ftr_Resourcemanagement.msg_SynchronizePlantDetailsRequest());
        httpPort.ValidatePasscode(new ftr_Resourcemanagement.msg_ValidatePasscodeRequest());
        httpPort.RetrieveCustomerFacilityHistory(new ftr_Resourcemanagement.msg_RetrieveCustomerFacilityHistoryRequest());
        httpPort.findCircuit(new ftr_Resourcemanagement.msg_FindCircuitRequest());
        httpPort.RetrieveTelephoneNumberHistory(new ftr_Resourcemanagement.msg_RetrieveTelephoneNumberHistoryRequest());
        httpPort.UpdateCustomerVoiceMailDetails(new ftr_Resourcemanagement.msg_UpdateCustomerVoiceMailDetailsRequest());
        httpPort.FindEmailAccounts(new ftr_Resourcemanagement.msg_FindEmailAccountsRequest());
        httpPort.FindLocalLoop(new ftr_Resourcemanagement.msg_FindLocalLoopRequest());
        httpPort.IsFrontierEmailAddressAvailable(new ftr_Resourcemanagement.msg_IsFrontierEmailAddressAvailableRequest());
        httpPort.FindAvailableTelephoneNumbers(new ftr_Resourcemanagement.msg_FindAvailableTelephoneNumbersRequest());
        httpPort.RetrieveEmailAccountDetails(new ftr_Resourcemanagement.msg_RetrieveEmailAccountDetailsRequest());
        
        
        new ftr_Resourcemanagement.FindAvailableTelephoneNumbersRequest_ExchangeFilter();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_FiberAccessTerminal();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_MDU_ServiceAddress();
        new ftr_Resourcemanagement.FindLocalLoopResponse_LoadCoil();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesSummaryResponse_Cable();
        new ftr_Resourcemanagement.FindLocalLoopResponse_GlobalPosition();
        new ftr_Resourcemanagement.RetrieveCustomerFacilities_OpticalNetworkTerminal_ManufacturerDetails();
        new ftr_Resourcemanagement.RetrieveCustomerFacilityHistoryResponse_CustomerFacilityHistory();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceAddress();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Connection();
        new ftr_Resourcemanagement.FindEmailAccountsResponse_EmailAccount();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_Terminal();
        new ftr_Resourcemanagement.RetrieveCustomerFaclitiesSummaryResponse_CustomerFacilities();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_ONTPortAssignments();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceQualification_HomeOwnersAssociation();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesSummaryResponse_Port();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_OpticalNetworkTerminal();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_AvailablePorts();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Dslam();
        new ftr_Resourcemanagement.FindAvailableTelephoneNumbersRequest_LastFourDigitsFilter();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_AccountId();
        new ftr_Resourcemanagement.SynchronizePlantDetails_User();
        new ftr_Resourcemanagement.RetrievePreferredExchangeRequest_CityStateId();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_ManufacturerDetails();
        new ftr_Resourcemanagement.ResourceManagement_ServiceAddressMasterId();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_CustomerFacilities();
        new ftr_Resourcemanagement.RetrieveHuntGroupDetailsResponse_HuntGroup();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_OpticalLineTerminal();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_ServicesRouter();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_Switch();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceQualification_ConnectAmericaFund();
        new ftr_Resourcemanagement.FindLocalLoop_Cable();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesSummaryResponse_ManufacturerDetails();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_CustomerFacilities();
        new ftr_Resourcemanagement.FindAvailableTelephoneNumbersRequest_WireCenterFilter();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_FiberDistributionHub();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_Cable();
        new ftr_Resourcemanagement.RetrieveEmailAccountDetailsResponse_EmailAccount();
        new ftr_Resourcemanagement.FindLocalLoopResponse_BridgeTap();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_OpticalNetworkTerminal();
        new ftr_Resourcemanagement.FindLocalLoopRequest_DistributionPoint();
        new ftr_Resourcemanagement.FindLocalLoopResponse_LoopSegment();
        new ftr_Resourcemanagement.RetrieveServiceDesignResponse_Dslam();
        new ftr_Resourcemanagement.RetrieveTelephoneNumberHistoryResponse_TelephoneHistory();
        new ftr_Resourcemanagement.FindLocalLoopResponse_NetworkLocation();
        new ftr_Resourcemanagement.PasscodeRequest_Override();
        new ftr_Resourcemanagement.FindLocalLoopResponse_GaugeSegment();
        new ftr_Resourcemanagement.RetrieveHuntGroupDetailsResponse_HuntGroupMember();
        new ftr_Resourcemanagement.FindEmailAccountsRequest_EmailAccountId();
        new ftr_Resourcemanagement.FindAvailableTelephoneNumbersRequest_TelephoneNumberFilter();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Cable();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Location();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Port();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_Technology();
        new ftr_Resourcemanagement.RetrieveCustomerFacilitiesResponse_ServiceQualification();
        
        
        Test.stopTest();
    }
}
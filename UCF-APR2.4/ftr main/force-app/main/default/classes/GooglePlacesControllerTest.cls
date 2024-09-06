/**
 * @description       : This test class covers the following Apex classes:
 *      TBD_CLASS1
 *      TBD_CLASS2
 *      TBD_CLASS3
 * @author            : TBD
 * @version           : 1 
**/
@isTest
public class GooglePlacesControllerTest {
    
    
    @isTest static  void testGetPredictionsCallout() {
        Test.setMock(HttpCalloutMock.class, new GoogleSuggestionsTestMock());
        String input = '1401 S MacArthur Blvd'; 
        String actualValue = GooglePlacesController.getSuggestions(input);
        
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //String actualValue = res.getBody();
        //String expectedValue  = '{"predictions" : [{"description" : "1401 S MacArthur Blvd, Irving, TX, USA", "matched_substrings" :[{"length" : 4,"offset" : 0}, {"length" : 16,"offset" : 5}], "place_id" : "ChIJt2EXx36DToYRW6Am0ycK0BI", "reference" : "ChIJt2EXx36DToYRW6Am0ycK0BI", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 4,   "offset" : 0},{   "length" : 16,   "offset" : 5}    ],    "secondary_text" : "Irving, TX, USA" }, "terms" :[{"offset" : 0,"value" : "1401"}, {"offset" : 5,"value" : "S MacArthur Blvd"}, {"offset" : 23,"value" : "Irving"}, {"offset" : 31,"value" : "TX"}, {"offset" : 35,"value" : "USA"}], "types" : [ "premise", "geocode" ]      },      { "description" : "1401 S MacArthur Blvd, Oklahoma City, OK, USA", "matched_substrings" :[{"length" : 21,"offset" : 0}], "place_id" : "Ei0xNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIE9rbGFob21hIENpdHksIE9LLCBVU0EiURJPCjQKMgkH4ME6LA6yhxFBFsXVrRJpzBoeCxDuwe6hARoUChIJt8iRQU4OsocRx7x69PYD8WcMEPkKKhQKEgllGKPkBA6yhxG58v4eZn-0yg", "reference" : "Ei0xNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIE9rbGFob21hIENpdHksIE9LLCBVU0EiURJPCjQKMgkH4ME6LA6yhxFBFsXVrRJpzBoeCxDuwe6hARoUChIJt8iRQU4OsocRx7x69PYD8WcMEPkKKhQKEgllGKPkBA6yhxG58v4eZn-0yg", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 21,   "offset" : 0}    ],    "secondary_text" : "Oklahoma City, OK, USA" }, "terms" :[{"offset" : 0,"value" : "1401 S MacArthur Blvd"}, {"offset" : 23,"value" : "Oklahoma City"}, {"offset" : 38,"value" : "OK"}, {"offset" : 42,"value" : "USA"}], "types" : [ "street_address", "geocode" ]      },      { "description" : "1401 S MacArthur Blvd, Springfield, IL, USA", "matched_substrings" :[{"length" : 4,"offset" : 0}, {"length" : 16,"offset" : 5}], "place_id" : "ChIJg8OmIU44dYgRzHZmbSrMepo", "reference" : "ChIJg8OmIU44dYgRzHZmbSrMepo", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 4,   "offset" : 0},{   "length" : 16,   "offset" : 5}    ],    "secondary_text" : "Springfield, IL, USA" }, "terms" :[{"offset" : 0,"value" : "1401"}, {"offset" : 5,"value" : "S MacArthur Blvd"}, {"offset" : 23,"value" : "Springfield"}, {"offset" : 36,"value" : "IL"}, {"offset" : 40,"value" : "USA"}], "types" : [ "street_address", "geocode" ]      },      { "description" : "1401 S MacArthur Blvd, Guthrie, OK, USA", "matched_substrings" :[{"length" : 21,"offset" : 0}], "place_id" : "EicxNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIEd1dGhyaWUsIE9LLCBVU0EiURJPCjQKMgkp-ZqUBPqxhxGcLhNlURykNRoeCxDuwe6hARoUChIJuXu2aGqNsYcR8G-cDy_hCnQMEPkKKhQKEglvbdoN5fmxhxHh8XD1GjuQLg", "reference" : "EicxNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIEd1dGhyaWUsIE9LLCBVU0EiURJPCjQKMgkp-ZqUBPqxhxGcLhNlURykNRoeCxDuwe6hARoUChIJuXu2aGqNsYcR8G-cDy_hCnQMEPkKKhQKEglvbdoN5fmxhxHh8XD1GjuQLg", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 21,   "offset" : 0}    ],    "secondary_text" : "Guthrie, OK, USA" }, "terms" :[{"offset" : 0,"value" : "1401 S MacArthur Blvd"}, {"offset" : 23,"value" : "Guthrie"}, {"offset" : 32,"value" : "OK"}, {"offset" : 36,"value" : "USA"}], "types" : [ "street_address", "geocode" ]      }   ],   "status" : "OK"}';
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }

       @isTest static  void testGetPlaceDetailsCallout() {
        Test.setMock(HttpCalloutMock.class, new GooglePlaceDetailsTestMock());
        String placeId = 'ChIJt2EXx36DToYRW6Am0ycK0BI'; 
        String actualValue = GooglePlacesController.getPlaceDetails(placeId);
        
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //String actualValue = res.getBody();
        //String expectedValue  = '{"predictions" : [{"description" : "1401 S MacArthur Blvd, Irving, TX, USA", "matched_substrings" :[{"length" : 4,"offset" : 0}, {"length" : 16,"offset" : 5}], "place_id" : "ChIJt2EXx36DToYRW6Am0ycK0BI", "reference" : "ChIJt2EXx36DToYRW6Am0ycK0BI", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 4,   "offset" : 0},{   "length" : 16,   "offset" : 5}    ],    "secondary_text" : "Irving, TX, USA" }, "terms" :[{"offset" : 0,"value" : "1401"}, {"offset" : 5,"value" : "S MacArthur Blvd"}, {"offset" : 23,"value" : "Irving"}, {"offset" : 31,"value" : "TX"}, {"offset" : 35,"value" : "USA"}], "types" : [ "premise", "geocode" ]      },      { "description" : "1401 S MacArthur Blvd, Oklahoma City, OK, USA", "matched_substrings" :[{"length" : 21,"offset" : 0}], "place_id" : "Ei0xNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIE9rbGFob21hIENpdHksIE9LLCBVU0EiURJPCjQKMgkH4ME6LA6yhxFBFsXVrRJpzBoeCxDuwe6hARoUChIJt8iRQU4OsocRx7x69PYD8WcMEPkKKhQKEgllGKPkBA6yhxG58v4eZn-0yg", "reference" : "Ei0xNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIE9rbGFob21hIENpdHksIE9LLCBVU0EiURJPCjQKMgkH4ME6LA6yhxFBFsXVrRJpzBoeCxDuwe6hARoUChIJt8iRQU4OsocRx7x69PYD8WcMEPkKKhQKEgllGKPkBA6yhxG58v4eZn-0yg", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 21,   "offset" : 0}    ],    "secondary_text" : "Oklahoma City, OK, USA" }, "terms" :[{"offset" : 0,"value" : "1401 S MacArthur Blvd"}, {"offset" : 23,"value" : "Oklahoma City"}, {"offset" : 38,"value" : "OK"}, {"offset" : 42,"value" : "USA"}], "types" : [ "street_address", "geocode" ]      },      { "description" : "1401 S MacArthur Blvd, Springfield, IL, USA", "matched_substrings" :[{"length" : 4,"offset" : 0}, {"length" : 16,"offset" : 5}], "place_id" : "ChIJg8OmIU44dYgRzHZmbSrMepo", "reference" : "ChIJg8OmIU44dYgRzHZmbSrMepo", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 4,   "offset" : 0},{   "length" : 16,   "offset" : 5}    ],    "secondary_text" : "Springfield, IL, USA" }, "terms" :[{"offset" : 0,"value" : "1401"}, {"offset" : 5,"value" : "S MacArthur Blvd"}, {"offset" : 23,"value" : "Springfield"}, {"offset" : 36,"value" : "IL"}, {"offset" : 40,"value" : "USA"}], "types" : [ "street_address", "geocode" ]      },      { "description" : "1401 S MacArthur Blvd, Guthrie, OK, USA", "matched_substrings" :[{"length" : 21,"offset" : 0}], "place_id" : "EicxNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIEd1dGhyaWUsIE9LLCBVU0EiURJPCjQKMgkp-ZqUBPqxhxGcLhNlURykNRoeCxDuwe6hARoUChIJuXu2aGqNsYcR8G-cDy_hCnQMEPkKKhQKEglvbdoN5fmxhxHh8XD1GjuQLg", "reference" : "EicxNDAxIFMgTWFjQXJ0aHVyIEJsdmQsIEd1dGhyaWUsIE9LLCBVU0EiURJPCjQKMgkp-ZqUBPqxhxGcLhNlURykNRoeCxDuwe6hARoUChIJuXu2aGqNsYcR8G-cDy_hCnQMEPkKKhQKEglvbdoN5fmxhxHh8XD1GjuQLg", "structured_formatting" : {    "main_text" : "1401 S MacArthur Blvd",    "main_text_matched_substrings" : [{   "length" : 21,   "offset" : 0}    ],    "secondary_text" : "Guthrie, OK, USA" }, "terms" :[{"offset" : 0,"value" : "1401 S MacArthur Blvd"}, {"offset" : 23,"value" : "Guthrie"}, {"offset" : 32,"value" : "OK"}, {"offset" : 36,"value" : "USA"}], "types" : [ "street_address", "geocode" ]      }   ],   "status" : "OK"}';
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }
    
    @isTest static  void testGetPlaceDetailsWithLatLngCallout() {
        Test.setMock(HttpCalloutMock.class, new GoogleLatLngTestMock());
        String lat = '40.714224'; 
        String lng = '-73.961452';
        String actualValue = GooglePlacesController.getPlaceDetailsWithLatLong(lat, lng);
        
    }
}
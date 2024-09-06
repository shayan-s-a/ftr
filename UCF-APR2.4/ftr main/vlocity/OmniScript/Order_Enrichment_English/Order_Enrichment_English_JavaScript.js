$( function() { 
    $('#BilltoContact').select(function() { 
        baseCtrl.prototype.$scope.applyCallResp( { "BilltoContactPhoneNumber": $('#BilltoContactPhoneNumberInvisible').val() } );
        baseCtrl.prototype.$scope.applyCallResp( { "BilltoContactEmail": $('#BilltoContactEmailInvisible').val() } );
    });  
});
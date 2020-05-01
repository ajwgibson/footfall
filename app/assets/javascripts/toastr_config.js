
$(function() {

  toastr.options = {
    "closeButton": true,
    "debug": true,
    "progressBar": true,
    "preventDuplicates": false,
    "positionClass": "toast-top-right",
    "onclick": null,
    "showDuration": "400",
    "hideDuration": "1000",
    "timeOut": "2000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  };

  $('.toastr-message').each(function() {
    window["toastr"][$(this).attr('data-toastr-type')]($(this).text());
  });

});

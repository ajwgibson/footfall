// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery3
//= require popper
//= require bootstrap
//= require pace/pace.min.js
//= require slimscroll/jquery.slimscroll.min.js
//= require metisMenu/jquery.metisMenu.js
//= require datepicker/bootstrap-datepicker.js
//= require chartjs/Chart.bundle.min.js
//= require chartjs/chartjs-plugin-annotation.min.js
//= require toastr/toastr.min.js
//= require toastr_config
//= require sweetalert/sweetalert.min.js
//= require typeahead/bootstrap3-typeahead.min.js
//= require inspinia.js

$(function () {

  //
  // File inputs the Inspinia way?
  //
  $('.custom-file-input').on('change', function () {
    var fileName = $(this).val().split('\\').pop();
    $(this).next('.custom-file-label').addClass("selected").html(fileName);
  });

  //
  // Sweet alert
  //
  function warn(e) {
    e.preventDefault();
    var source = $(this);
    swal({
        title: "Warning",
        text: "You may not be able to undo this action. Are you sure you want to continue?",
        type: "warning",
        showCancelButton: true,
        cancelButtonText: "No, cancel",
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes, continue",
        closeOnConfirm: false,
        html: false
      },
      function (confirmed) {
        if (confirmed) {
          source.off(e.type, warn);
          source.trigger(e.type);
        }
      });
  }

  $("form[data-warn]").submit(warn);
  $("button[data-warn]").click(warn);

  //
  // Date picker inputs
  //
  $('.datepicker').datepicker({
    format: "dd/mm/yyyy",
    startView: "days",
    todayBtn: true,
    clearBtn: true,
    todayHighlight: true,
    keyboardNavigation: false,
    forceParse: false,
    autoclose: true,
    weekStart: 1,
  });

  //
  // Find a device using a 'typeahead' text input
  //
  $('.typeahead-find-device').typeahead({
    minLength: 2,
    autoSelect: false,
    fitToElement: false,
    displayText: function (item) {
      return item.text;
    },
    source: function (query, process) {
      return $.ajax({
        url: '/api/devices',
        data: {
          name: query
        },
        dataType: 'json',
        success: function (data) {
          let json = $.map(data, function (device) {
            return {
              id: device.id,
              text: device.device_id
            }
          });
          return process(json);
        }
      });
    },
    afterSelect: function (item) {
      window.location.href = '/devices/' + item.id;
    }
  });
});
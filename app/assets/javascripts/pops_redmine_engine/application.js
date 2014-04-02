//= require ./vendor/vendor

$(document).ready(function() {

  if(document.getElementById("project_id")) {
    $.ajax({
      type: 'get',
      url: '/projects/'+$("#project_id").attr('value')+'/timeline',
      success: function (data) {
        createTimeline(data);
      }
    });

    function createTimeline(data) {
        createStoryJS({
            width: "100%",
            height: "350",
            start_zoom_adjust:  '0',
            source: data,
            type: 'timeline',
            embed_id: 'time_line'
        });
    }
  }

  jQuery('input[name=switch]:radio').click(function(){
      var v = jQuery(this).val();
      if(v == "radio_file") {
        $("#file").show();
        $("#hal").hide();
        $("#url").hide();
        $("#document_url_to").val('');
        $("#url_input_doc").val('');
      }
      else if(v == "radio_hal") {
        $("#file").hide();
        $("#hal").show();
        $("#url").hide();
        $("#document_url_to").val('');
        $("#url_input_doc").val('');
      }
      else if(v == "radio_url") {
        $("#file").hide();
        $("#hal").hide();
        $("#url").show();
        $("#document_url_to").val('');
        $("#url_input_doc").val('');
      }
  });
});

function searchHal() {
  if(document.getElementById("hal_url")) {
    if($("#hal_url").val() != "") {
      $.ajax({
        type: 'get',
        url: '/searchHal?title=' + $("#hal_url").val(),
        success: function (data) {
          setSelect(data)
        }
      });
    }
  }
}

function setSelect(data) {
  $('#hal_url_list').find('option').remove();
  $("#hal_url_list").append(new Option('', ''));
  document.getElementById("hal_results").innerHTML= 'La recherche a retournée ' + data.length + ' résultats.';
  for (var i=0; i<data.length; i++) {
    $("#hal_url_list").append(new Option(data[i].title + " - version "+data[i].version, data[i].url));
  }
}

function setUrlHal(url) {
  if(document.getElementById("document_url_to")) {
    $("#document_url_to").val($("#hal_url_list").val());
    $("#url_input_doc").val($("#hal_url_list").val());
  }
}
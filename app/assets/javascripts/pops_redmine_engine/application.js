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
            start_at_end: true,
            start_zoom_adjust: '0',
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

  if(document.getElementById("document_tag_list")) {
    var tag = $("#document_tag_list").val();
    var $radios = $('input:radio[name=switch2]');
    if($radios.is(':checked') === false) {
      $radios.filter('[value="'+tag+'"]').prop('checked', true);
      if($radios.is(':checked') === false) {
        $radios.first().prop('checked', true);
        $("#document_tag_list").val($radios.first().val());
      }
    }

    jQuery('input[name=switch2]:radio').click(function(){
      var v = jQuery(this).val();
      $("#document_tag_list").val(v);
    });
  }

});

function searchHal() {
  if(document.getElementById("hal_url")) {
    if($("#hal_url").val() != "") {
      $.ajax({
        type: 'get',
        url: '/searchHal?title=' + $("#hal_url").val(),
        success: function (data) {
          setSelect(data);
        }
      });
    }
  }
}

function searchArticleOnHal() {
  if(document.getElementById("hal_url")) {
    if($("#hal_url").val() != "") {
      $.ajax({
        type: 'get',
        url: '/searchArticleOnHal?identifiant=' + $('#hal_url_list').find(":selected").attr('identifiant') + '&version=' + $('#hal_url_list').find(":selected").attr('version') ,
        success: function (data) {
          $("#document_title").val(data.title);
          $("#document_created_date").val('01/01/'+data.datepub);
          $("#document_description").val(data.resume + "\n" + data.description);
        }
      });
    }
  }
}

function setSelect(data) {
  $('#hal_url_list').show();
  $('#hal_url_list').empty();
  $("#hal_url_list").append(new Option('', ''));
  document.getElementById("hal_results").innerHTML= 'La recherche a retournée ' + data.length + ' résultats.';
  for (var i=0; i<data.length; i++) {
    var op = new Option(data[i].title + " - version "+data[i].version, data[i].url);
    op.setAttribute("identifiant",data[i].identifiant);
    op.setAttribute("version",data[i].version);
    $("#hal_url_list").append(op);
  }
}

function setUrlHal(url) {
  if(document.getElementById("document_url_to")) {
    $("#document_url_to").val($("#hal_url_list").val());
    $("#url_input_doc").val($("#hal_url_list").val());
    searchArticleOnHal();
  }
}
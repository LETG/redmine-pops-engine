//= require ./vendor/vendor

var root_path = "/pops"

$(document).ready(function() {
  $("body").delegate(".new_document input[name='document[title]']", "change", function(e) {
    if ($(e.currentTarget).val().length == 0) {
      $("input[name='mode']").prop('disabled', false);
    } else {
      $("input[name='mode']").prop('disabled', true);
    }
  });
  
  $("body").delegate(".new_document input[name='mode']", "change", function(e) {
    switch($(e.currentTarget).val()) {
      case 'hal':
        activateSearch("/searchHal", {});
        break;
      case 'datacite':
        activateSearch("/datacite/search", {
          id: function(hit) { 
            return hit.id; 
          },
          formatResult: function(item) { return item.title; },
          formatSelection: function(item) {
            $("#document_title").val(item.title);
            $("#document_description").val(item.abstract);
            $("#document_created_date").val(item.published_at);
            $("#document_url_to").val("https://doi.org/" + item.id);
            $("#url_input_doc").val("https://doi.org/" + item.id);
            return item.title;
          }
        });
        break;
      default:
        $("#document_title").select2('destroy');
    }
  });
});

function activateSearch(url, options) {
  default_options = {
    minimumInputLength: 3,
    placeholder: "Rechercher un article par son titre et/ou ses auteurs",
    allowClear: true,
    multiple: false,
    id: function(hit) { return hit.identifiant; },
    ajax: {
      url: root_path + url,
      dataType: 'json',
      quietMillis: 300,
      type: 'get',
      data: function (term) { return { title: term }; },
      results: function (data) { 
        console.log(data);
        return { results: data }; 
      }
    },
    formatResult: halFormatResult,
    formatSelection: halFormatSelection
  }
  
  var select2_options = $.extend(default_options, options);


  $("#document_title").addClass("select2");
  $("#document_title").select2(select2_options);
}

function halFormatResult(item) {
  return item.title;
}

function halFormatSelection(item) {
  searchArticleOnHal(item.identifiant, item.version, item.url)
  return item.title;
}

function searchArticleOnHal(id, version, url) {
  $.ajax({
    type: 'get',
    url: root_path + '/searchArticleOnHal?identifiant=' + id + '&version=' + version,
    success: function (data) {
      $("#document_title").val(data.title);
      $("#document_created_date").val(data.datepub);
      $("#document_description").val(data.resume + "\n" + data.description);
      $("#document_url_to").val(url);
      $("#url_input_doc").val(url);
    }
  });
}

function addFilter(field, operator, values) {
  var fieldId = field.replace('.', '_');
  var tr = $('#tr_'+fieldId);

  var filterOptions = availableFilters[field];
  if (!filterOptions) return;

  if (filterOptions['remote'] && filterOptions['values'] == null) {
    $.getJSON(filtersUrl, {'name': field}).done(function(data) {
      filterOptions['values'] = data;
      addFilter(field, operator, values);
    });

    return;
  }

  if (tr.length > 0) {
    tr.show();
  } else {
    buildFilterRow(field, operator, values);
  }
  $('#cb_'+fieldId).prop('checked', true);
  toggleFilter(field);
  toggleMultiSelectIconInit();
  $('#add_filter_select').val('').find('option').each(function() {
    if ($(this).attr('value') == field) {
      $(this).attr('disabled', true);
    }
  });

  $("#filters-table").trigger("filter:loaded");
}
         function updatePage() {
            // reference:
            //   - http://boilingplastic.com/using-mustache-templates-for-javascript-practical-examples/
            //   - http://jonnyreeves.co.uk/2012/using-external-templates-with-mustachejs-and-jquery/
            $.ajax({
               type: 'GET',
               url: '/wado/wado-api?action=wado-installation-status',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(body_data) {
                  if(body_data.status == "ok") {
                     addQueryParamsForMustache(document.location.search, body_data);
                     var body = $('#main').html();
                     var body_html = Mustache.to_html(body, body_data);
                     $('#outer').html(body_html);
                     trans();
                  } else {
                     var error = $('#error').html();
                     var error_html = Mustache.to_html(error, body_data);
                     $('#outer').replaceWith(error_html);                  
                  }
               }
            });            
         }

         function fetch() {
            document.getElementById("download").innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/wado/wado-api?action=wado-fetch-files',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  updatePage();
               }
            });
         }

         function enviro() {
            document.getElementById("enviro").innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/wado/wado-api?action=wado-build-env',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  updatePage();
               }
            });
         }

         function cstore() {
            document.getElementById("cstore").innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/wado/wado-api?action=wado-cstore-samples',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  updatePage();
               }
            });
         }

         function trans() {
            $.ajax({
               type: 'GET',
               url: '/wado/wado-api?action=wado-launch-editor',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                   console.log(data.transUrl);
                  $('#transLink').attr('href', data.transUrl);
                  $('#download').attr()
               }
            });
         }

         function reset() {
            document.getElementById("reset").innerHTML = "<img src=\"http://static.interfaceware.com/devops/spinner.gif\"/>";
            $.ajax({
               type: 'GET',
               url: '/wado/wado-api?action=wado-reset-example',
               error: function (request, status, error) {
                  handleAjaxError(request, status, error);
               },
               success: function(data) {
                  updatePage();
               }
            });
         }

         // http://stackoverflow.com/questions/2276463/how-can-i-get-form-data-with-javascript-jquery
         function getFormData(dom_query){
            var out = {};
            var s_data = $(dom_query).serializeArray();
            for(var i = 0; i<s_data.length; i++){
              var record = s_data[i];
              out[record.name] = record.value;
            }
            return out;
         }

         
         function handleAjaxError(request, status, error) {
            var error_data = { message : request.statusText + ": " + request.responseText + " (" + status + ")" };
            var error = $('#error').html();
            var error_html = Mustache.to_html(error, error_data);
            $('#outer').replaceWith(error_html);            
         }
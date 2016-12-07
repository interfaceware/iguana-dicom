// http://stackoverflow.com/questions/979975/how-to-get-the-value-from-the-url-parameter

function getQueryParams(qs) {
   qs = qs.split('+').join(' ');
   var params = {}, tokens, re = /[?&]?([^=]+)=([^&]*)/g;
   while (tokens = re.exec(qs)) {
      params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
   }
   return params;
}
//var query = getQueryParams(document.location.search);
//alert(query.foo);

function addQueryParamsForMustache(qs, data) {
   qs = qs.split('+').join(' ');
   var params = {}, tokens, re = /[?&]?([^=]+)=([^&]*)/g;
   while (tokens = re.exec(qs)) {
      params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);               
      data[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
   }
   return params;
}

function redirect(initial, newlocation) {
   if (typeof redirect.counter == 'undefined' ) {
      redirect.counter = initial;
      redirect.newlocation = newlocation;
   }
   if(redirect.counter > 0) {
      document.getElementById('count').innerHTML = redirect.counter--;
      setTimeout(redirect, 1000);
   } else {
      location.href = redirect.newlocation
   }
}

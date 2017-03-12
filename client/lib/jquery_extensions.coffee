module.exports = load: ({$}) ->

  # ------------------------------------------------
  # credit to http://stepansuvorov.com/blog/2014/04/jquery-put-and-delete/ for these
  # ------------------------------------------------

  put: ```
    function(url, data, callback, type){
     
      if ( $.isFunction(data) ){
        type = type || callback,
        callback = data,
        data = {}
      }
     
      return $.ajax({
        url: url,
        type: 'PUT',
        success: callback,
        data: data,
        contentType: type
      });
    }
  ``` 

  delete: ```
    function(url, data, callback, type){
   
      if ( $.isFunction(data) ){
        type = type || callback,
            callback = data,
            data = {}
      }
     
      return $.ajax({
        url: url,
        type: 'DELETE',
        success: callback,
        data: data,
        contentType: type
      });
    }

  ```

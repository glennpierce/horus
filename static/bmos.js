function post_form (form, additions) {

    var f = document.forms[form];

    for (var a in additions) {
	  
	  console.log(a);
	  
      var myInput = document.createElement("input");
	  
	  // Check any inputs with the same id exist
	  if ($("#" + a).length > 0){
		continue;
	  }
	  myInput.setAttribute("id", a);
      myInput.setAttribute("name", a);
      myInput.setAttribute("type", "hidden");
      myInput.setAttribute("value", additions[a]);
      f.appendChild(myInput);
    }

    f.submit();

	return false;
};

function post_form_to_action (form, action, additions) {

    var f = document.forms[form];
    f.action = action;
    post_form (form, additions);

};

// Creates a Date.fromISO
// Ie6-8 can not even pass dates !
// Need to pass "1970-01-01 00:00:00 UTC"
(function() {
  var D = new Date('1970-01-01 00:00:00 UTC');
  if (!D || +D!== 1307000069000) {
    Date.fromBmosDate= function(s){
      var rx=/^(\d{4})\-(\d\d)\-(\d\d)\s(\d\d):(\d\d):(\d\d)\sUTC?$/,
      p= rx.exec(s) || [];
     
      // Not sure what todo with the timezone offset yet.
      //return new Date(p[1], p[2]-1, p[3], p[4], p[5], p[6]);   
      return new Date(Date.UTC(p[1], p[2]-1, p[3], p[4], p[5], p[6]));
     }
  }
  else {
      Date.fromBmosDate = function(s) {
          return new Date(s);
      }
  }
})();


function setup_popup(id) {
   
    hack = typeof hack == 'undefined' || hack==true ? true : false;
 
    var overlayOpacityNormal = 1.0;
    var overlayOpacitySpecial = 0;
    var dialog_height = $(document).height()-$(document).height()/5;

    $(id).dialog({
        autoOpen: false,
        bgiframe: false,
        modal: true,
        width: $(document).width()-$(document).width()/5,
        height: dialog_height,
        position: 'center',
        resizable: false,
        draggable: false,
        title:null,
        open: function(event, ui) {
             $(this).css({'max-height': dialog_height });
        },
        close: function(event, ui) {
        }
    });
    
    $(".ui-dialog-titlebar").hide();
    
    $(id + ' iframe').attr('height', dialog_height-60);
    
    $(id + ' .close').click(function (e) {
        
        $(id).dialog('close');
        
        // Nasty hack as video on the popup frame continues to play when the popup is closed.
        if (hack) {
            $(id + ' iframe').attr('src', '');
        }
    });
};


function open_popup(id) {

    scrolling = typeof scrolling !== 'undefined' ? scrolling : "auto";

    $(id).attr('scrolling', scrolling);
    $(id).dialog('open');
   
    return false;
}
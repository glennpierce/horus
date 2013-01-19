<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <title>Ecoeye energy viewer</title>
  <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7; IE=EmulateIE9,chrome=1">
  <link href="/static/style.css" media="screen" rel="stylesheet" type="text/css"> 
  <link href="/static/jquery-ui-1.8.21.custom.css" media="screen" rel="stylesheet" type="text/css"> 
  <script type="text/javascript" src="/static/jquery-1.7.2.min.js"></script>
  <script type="text/javascript" src="/static/jquery-ui-1.8.21.custom.min.js"></script>
 
  <!--[if IE]><script src="/static/excanvas.js"></script><![endif]-->
  <script type="text/javascript" src="/static/dygraph-combined.js"></script>
  
  <script src="/static/data.js"></script>
  
  <script type="text/javascript">

    /*determines if 'url' is being used as a data-source and appends url 
with 'from' and 'to' fields, 
corresponding to timestamp being selected. Then, instead of calling 
doZoomXDates_(), reloads data set via start_() */ 
Dygraph.prototype.doZoomX_ = function(lowX, highX) {
  // Find the earliest and latest dates contained in this canvasx range. 
  // Convert the call to date ranges of the raw data. 

  //we must return min/max dates in GMT 
  tzOffset=-1*new Date().getTimezoneOffset()*60; 
  var minDate = Math.floor(this.toDataXCoord(lowX)/1000)+tzOffset; 
  var maxDate = Math.floor(this.toDataXCoord(highX)/1000)+tzOffset; 

  if ( (typeof this.file_ == 'string' && this.file_.indexOf('\n') < 
0) ) { 
    if (this.origFile_) 
        this.file_=this.origFile_; 

    var newUrl= [ 
      this.file_+( this.file_.indexOf('?')>=0 ? '' : '?' ), 
      'from='+minDate, 
      'to='+maxDate 
    ].join('&'); 

    this.origFile_=this.file_; 
    this.file_=newUrl; 
    this.start_(); 
  } else { 
    this.doZoomXDates_(minDate, maxDate); 
  } 
}; 

/*determines if 'url' is being used as a data-source and calls 
start_() with initial(unmodified) url to 
reload original data*/ 
Dygraph.prototype.doUnzoom_ = function() { 
  var dirty = false; 
  if (this.dateWindow_ != null) { 
    dirty = true; 
    this.dateWindow_ = null; 
  } 

  for (var i = 0; i < this.axes_.length; i++) { 
    if (this.axes_[i].valueWindow != null) { 
      dirty = true; 
      delete this.axes_[i].valueWindow; 
    } 
  } 

  // Clear any selection, since it's likely to be drawn in the wrong place. 
  this.clearSelection(); 

  if (dirty || this.origFile_) { 
    // Putting the drawing operation before the callback because it resets 
    // yAxisRange. 
    this.zoomed_x_ = false; 
    this.zoomed_y_ = false; 
    //if file is url - reload ajax query 
    if ( (typeof this.file_ == 'string' && this.file_.indexOf('\n') < 
0) ) { 
        this.file_=this.origFile_; 
        delete this.origFile_; 
        this.start_(); 
    } else { 
        this.drawGraph_(); 
    } 
    if (this.attr_("zoomCallback")) { 
      var minDate = this.rawData_[0][0]; 
      var maxDate = this.rawData_[this.rawData_.length - 1][0]; 
      this.attr_("zoomCallback")(minDate, maxDate, 
this.yAxisRanges()); 
    } 
  } 
}; 


    var plot = null;
    
    function set_graph_visibility(state)
    {
      if (state == true) {
        $('#graphdiv').css("visibility","visible");
        $('#dow_chart').css("visibility","visible");
        $('#data_info').css("visibility","visible");
        $('#export_table').css("visibility","visible");
        $('#graph_section').css("visibility","visible");
      }
      else {
        $('#graphdiv').css("visibility","hidden");
        $('#dow_chart').css("visibility","hidden");
        $('#data_info').css("visibility","hidden");
        $('#export_table').css("visibility","hidden");
        $('#graph_section').css("visibility","hidden");
      }
    }
 
    function drawPlot()
    {    
        var resolution = $('#resolution').val();
        
        set_graph_visibility(true);
        $("#graph_loading").show();
   
        if (plot) { 
            plot.destroy(); 
        }
        
        url = "/data/2010/01/01/2012/12/01";
          
        //$('#csv_data_url').attr('href', url);

        plot = new Dygraph(
              document.getElementById("graphdiv"),
              //data_temp,
              url,
              {
                includeZero: true,
                showRoller: false,
                strokeWidth: [3.0],
                colors: ['#d60c8c'],
                //legend: 'always',
                //hideOverlayOnMouseOut: true,
                labelsDivStyles: { 'textAlign': 'right' },
                drawCallback: function(graph) {
                  $('#graph_loading').hide();
                  $("#graphdiv").show();
                  //$('#graphdiv').css("visibility","visible");
                  //set_graph_visibility(true);
                }
              }
            );
    };

    function on_resolution_change() {
      
        //on_sensor_change($('#sensor_id').val(), false);
    };

    $(document).ready(function() {
      
        //set_graph_visibility(false);
        //on_site_change($('#site_id').val());
    
        drawPlot();
    
        $("#loading").hide();    
        $("#graph_loading").hide();
    });
    
  </script>
</head>
<body>

<div class="frame frame-center">

<h2>Ecoeye energy usage</h2>   

<form name="retrieve_data_form" method="post" action="/site_export">

<div class="dtable">

        <div class="drow">
              <div class="dcell">&nbsp;
        <span>
        
        Resolution:
        <select id="resolution" name="resolution" onchange='on_resolution_change();'>
          <option value="0">All</option>
          <option value="60">1 Minute</option>
          <option value="300">5 Minute</option>
          <option value="1200">20 Minute</option>
          <option value="3600">1 Hour</option>
          <option value="86400" selected>1 Day</option>
          <option value="604800">1 Week</option>
        </select>
        </p>
        </span>
            </div>
        <div class="dcell">&nbsp;</div>
        <div class="dcell pad">&nbsp;</div>
    </div>
</div>


<div id="graph_section" class="dtable">

    <div class="drow">
        <div id="graph_container" class="dcell" style="border: 0px solid green;">
            <div id="graphdiv" class="graph"></div>
            <div id="graph_loading"><img src="/static/ajax-loader.gif" /><span>Please Wait</span></div>
        </div>
        <div class="dcell">&nbsp;</div>
        <div class="dcell">
 
            <div id="data_info">
              <div>Sensor: <span id="sensor_name"></span></div>
              <div>Sensor Id: <span id="sensor_id_display"></span></div>
              <div>Total Values for sensor: <span id="sensor_num_values"></span></div>
              <div>Average for sensor: <span id="sensor_average"></span></div>
              <div><span id="ealiest_date"></span></div>
              <div><span id="last_date"></span></div>	
              <a id="csv_data_url">Raw csv data</a>
            </div>
        </div>
    </div>

</form>

</div>

</body>
</html>

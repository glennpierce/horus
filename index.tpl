<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <title>Ecoeye energy viewer</title>
  <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7; IE=EmulateIE9,chrome=1">
  <link href="/static/horus.css" media="screen" rel="stylesheet" type="text/css"> 
  <script type="text/javascript" src="/static/jquery-1.7.2.min.js"></script>
 
  <!--[if IE]><script src="/static/excanvas.js"></script><![endif]-->
  <script type="text/javascript" src="/static/dygraph-combined.js"></script>
  
  <script src="/static/data.js"></script>
  
  <script type="text/javascript">

    var url = "/data/0";
    var plot = null;
    
    function set_graph_visibility(state)
    {
      if (state == true) {
        $('#graphdiv').css("visibility","visible");
      }
      else {
        $('#graphdiv').css("visibility","hidden");
      }
    }
 
    function drawPlot()
    {    
        var resolution = $('#resolution').val();
        
        set_graph_visibility(false);

        $("#graph_loading").show();
   
        if (plot) { 
            plot.destroy(); 
        }

        plot = new Dygraph(
              document.getElementById("graphdiv"),
              //data_temp,
              url,
              {
                includeZero: true,
                showRoller: false,
                strokeWidth: [3.0],
                colors: ['#00D631'],
                //legend: 'always',
                //hideOverlayOnMouseOut: true,
                labelsDivStyles: { 'textAlign': 'right' },
                drawCallback: function(graph) {
                  $('#graph_loading').hide();
                  set_graph_visibility(true);
                },
              }
            );
    };

    function on_type_change() {
        url = '/data/' + $('#type_id').val();
        drawPlot();
    };

    $(document).ready(function() {
        drawPlot();

        $("#voltage").keyup(function(event){
            if(event.keyCode == 13){
                $.post("/setvoltage", { voltage: $(this).val()}, function() {
                })
                .fail(function() { 
                    alert("Failed to set volatge");
                })
            }
        });

        $("#pence_per_kwh").keyup(function(event){
            if(event.keyCode == 13){
                $.post("/set_pence_per_kwh", { pence_per_kwh: $(this).val()}, function() {
                })
                .fail(function() { 
                    alert("Failed to set pence per kwh");
                })
            }
        });
    });

  </script>
</head>
<body>

<div class="frame frame-center">

<h2>Ecoeye energy usage</h2>   

<form name="retrieve_data_form" method="post" action="/site_export">

<div class="dtable" style="border:0px solid red;">

        <div class="drow" style="border:0px solid purple;">
          <div class="dcell" style="border:0px solid blue;width:20%;">
            <label for="type_id" style="border:0px solid blue;display:inline;">Type:</label>
            <select id="type_id" style="border:0px solid red;display:inline;" onchange='on_type_change();'>
              <option value="0">Amps</option>
              <option value="1">Power</option>
              <option value="2">KWh</option>
              <option value="3">Cost</option>
            </select>
          </div>
          <div class="dcell" style="width:15%;">
          <label for="voltage" style="display:inline;">Voltage:</label>
          <input id="voltage" type="text" value="{{voltage}}" size="5" style="display:inline;" />
          </div>
          <div class="dcell" style="width:20%;">
          <label for="pence_per_kwh" style="display:inline;">Pence Per KWh:</label>
          <input id="pence_per_kwh" type="text" value="{{pence_per_kwh}}" size="5" style="display:inline;" />
          </div>
          <div class="dcell pad">&nbsp;</div>
    </div>
</div>


<div id="graph_section" class="dtable">

    <div class="drow">
        <div id="graph_container" class="dcell">
            <div id="graphdiv" class="graph"></div>
            <div id="graph_loading"><img src="/static/ajax-loader.gif" width="80" height="80" /><span>Please Wait</span></div>
        </div>
    </div>

</form>

</div>

</body>
</html>

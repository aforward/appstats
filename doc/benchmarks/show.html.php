<?php

  $allBenchmarks = $GLOBALS["current_benchmarks"];
  $b = $allBenchmarks[0];

  $xaxes = implode(array("Old","New"),"|");
  $yaxes = implode(array("Fast","Average","Slow"),"|");

  $allAxes = array();
  if ($b->getXaxesNames() != null)
  {
    $allAxes[] = "0:|". implode($b->getXaxesNames(),"|");  
  }
  if ($b->getYaxesNames() != null)
  {
    $allAxes[] = "2:|" . implode($b->getYaxesNames(),"|");  
  }
  $axes_param = implode($allAxes,'|');
  
  $graph_lines = implode($b->getGraphLines(),",");
  $allColours = Benchmark::nextColours(count($allBenchmarks));
  $colours_param = implode($allColours,",");
  
  $legends = implode(array_map(function($b) { return $b->getLegend(); }, $allBenchmarks),"|");
  $lineWidths = implode(array_map(function($b) { return $b->getLineWidth(); }, $allBenchmarks),"|");
  $points = implode(array_map(function($b) { return implode($b->getPoints(),","); }, $allBenchmarks),"|");
  $points_size = array_map(function($b) { return $b->numberOfPoints(); }, $allBenchmarks);
  
  $allMarkers = array();
  foreach ($allBenchmarks as $index => $bench)
  {
    $allMarkers[] = "o,{$allColours[$index]},$index,-1,{$bench->numberOfPoints()}";
  }
  $marker_param = implode($allMarkers,"|");
  $max = Benchmark::maxWithBuffer($allBenchmarks,0.1);
  
  $data = array(
      "chxl={$axes_param}"
    , "chxr=1,0,$max"
    , "chds=0,$max"
    , "chxt=x,y,y"
    , "chs={$b->getWidth()}x{$b->getHeight()}"
    , "cht=lc"
    , "chco={$colours_param}"
    , "chg={$graph_lines}"
    , "chd=t:{$points}"
    , "chdl={$legends}"
    , "chls={$lineWidths}"
    , "chm={$marker_param}"
    , "chtt={$b->getTitle()}"
  );
  
  $output = implode($data,"&");   
?>  
  <img class="graph" src="http://chart.apis.google.com/chart?<?php echo $output ?>" width="<?php echo $b->getWidth() ?>" height="<?php echo $b->getHeight() ?>" alt="<?php echo $b->getTitle() ?>" />

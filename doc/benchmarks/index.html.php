<?php
  if (count($GLOBALS["viewables"]["benchmark_groups"]) > 0) 
  {
    require_view('benchmarks/header');
    require_view('benchmarks/body');
  }
  else
  {
    print "No benchmarks";
  }

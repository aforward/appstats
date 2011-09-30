<?php

function getBenchmarkGroups()
{
  $redis = new Predis\Client();
  $allBenchmarkGroups = array();
  foreach($redis->smembers("benchmarks") as $title)
  {
    $allBenchmarks = array();
    foreach($redis->smembers("benchmarks:{$title}") as $legend)
    {
      $points = $redis->lrange("benchmarks:{$title}:{$legend}",0,-1);
      $allBenchmarks[] = new Benchmark($title,$legend,$points);
    }
    $allBenchmarkGroups[] = $allBenchmarks;
  }
  return $allBenchmarkGroups;
}

function require_view($viewName)
{
  require "../{$viewName}.html.php";  
}

function app_autoload($class_name)
{
  if (file_exists("{$class_name}.php"))
  {
    require_once "{$class_name}.php";
    return true;
  }
  return false;
}
spl_autoload_register('app_autoload');

require 'Predis/Autoloader.php';
Predis\Autoloader::register();


$GLOBALS["viewables"] = array();
$GLOBALS["viewables"]["benchmark_groups"] = getBenchmarkGroups();
require_view("benchmarks/index");
<?php
  foreach ($GLOBALS["viewables"]["benchmark_groups"] as $allBenchmarks)
  {
    Benchmark::resetColours();
    $GLOBALS["current_benchmarks"] = $allBenchmarks;
    require_view("benchmarks/show");
  }
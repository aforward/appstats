<?php
/*PLEASE DO NOT EDIT THIS CODE*/
/*This code was generated using the UMPLE 1.10.3.3108 modeling language!*/

class Benchmark
{

  //------------------------
  // MEMBER VARIABLES
  //------------------------

  //Benchmark Attributes
  private $title;
  private $legend;
  private $points;
  private $colour;
  private $hack;
  private $xaxesNames;
  private $xaxesNumbers;
  private $yaxesNames;
  private $yaxesNumbers;
  private $graphLines;
  private $width;
  private $height;
  private $lineWidth;

  //------------------------
  // CONSTRUCTOR
  //------------------------

  public function __construct($aTitle, $aLegend, $aPoints)
  {
    $this->title = $aTitle;
    $this->legend = $aLegend;
    $this->points = $aPoints;
    $this->colour = null;
    $this->hack = -1;
    $this->xaxesNames = array("Old","New");
    $this->xaxesNumbers = null;
    $this->yaxesNames = array("Fast","Average","Slow");
    $this->yaxesNumbers = null;
    $this->graphLines = array("25","50");
    $this->width = "425";
    $this->height = "200";
    $this->lineWidth = "1";
  }

  //------------------------
  // INTERFACE
  //------------------------

  public function setTitle($aTitle)
  {
    $wasSet = false;
    $this->title = $aTitle;
    $wasSet = true;
    return $wasSet;
  }

  public function setLegend($aLegend)
  {
    $wasSet = false;
    $this->legend = $aLegend;
    $wasSet = true;
    return $wasSet;
  }

  public function setPoints($aPoints)
  {
    $wasSet = false;
    $this->points = $aPoints;
    $wasSet = true;
    return $wasSet;
  }

  public function setColour($aColour)
  {
    $wasSet = false;
    $this->colour = $aColour;
    $wasSet = true;
    return $wasSet;
  }

  public function setHack($aHack)
  {
    $wasSet = false;
    $this->hack = $aHack;
    $wasSet = true;
    return $wasSet;
  }

  public function setXaxesNames($aXaxesNames)
  {
    $wasSet = false;
    $this->xaxesNames = $aXaxesNames;
    $wasSet = true;
    return $wasSet;
  }

  public function setXaxesNumbers($aXaxesNumbers)
  {
    $wasSet = false;
    $this->xaxesNumbers = $aXaxesNumbers;
    $wasSet = true;
    return $wasSet;
  }

  public function setYaxesNames($aYaxesNames)
  {
    $wasSet = false;
    $this->yaxesNames = $aYaxesNames;
    $wasSet = true;
    return $wasSet;
  }

  public function setYaxesNumbers($aYaxesNumbers)
  {
    $wasSet = false;
    $this->yaxesNumbers = $aYaxesNumbers;
    $wasSet = true;
    return $wasSet;
  }

  public function setGraphLines($aGraphLines)
  {
    $wasSet = false;
    $this->graphLines = $aGraphLines;
    $wasSet = true;
    return $wasSet;
  }

  public function setWidth($aWidth)
  {
    $wasSet = false;
    $this->width = $aWidth;
    $wasSet = true;
    return $wasSet;
  }

  public function setHeight($aHeight)
  {
    $wasSet = false;
    $this->height = $aHeight;
    $wasSet = true;
    return $wasSet;
  }

  public function setLineWidth($aLineWidth)
  {
    $wasSet = false;
    $this->lineWidth = $aLineWidth;
    $wasSet = true;
    return $wasSet;
  }

  public function getTitle()
  {
    return $this->title;
  }

  public function getLegend()
  {
    return $this->legend;
  }

  public function getPoints()
  {
    return $this->points;
  }

  public function getColour()
  {
    return $this->colour;
  }

  public function getHack()
  {
    return $this->hack;
  }

  public function getXaxesNames()
  {
    return $this->xaxesNames;
  }

  public function getXaxesNumbers()
  {
    return $this->xaxesNumbers;
  }

  public function getYaxesNames()
  {
    return $this->yaxesNames;
  }

  public function getYaxesNumbers()
  {
    return $this->yaxesNumbers;
  }

  public function getGraphLines()
  {
    return $this->graphLines;
  }

  public function getWidth()
  {
    return $this->width;
  }

  public function getHeight()
  {
    return $this->height;
  }

  public function getLineWidth()
  {
    return $this->lineWidth;
  }

  public function getMax()
  {
    return max($this->points);;
  }

  public function equals($compareTo)
  {
    return $this == $compareTo;
  }

  public function delete()
  {}

  //------------------------
  // DEVELOPER CODE - PROVIDED AS-IS
  //------------------------
  
  public static $nextColourIndex = 0;
  public static $availableColours = array(
    "008000",
    "009ddb",
    "0c60b7",
    "333333",
    "432e0f",
    "609c25",
    "640d0d",
    "68563d",
    "858585",
    "997f5b",
    "ba2a2a",
    "b591f8",
    "b66a27",
    "bc9248",
    "c5d3fa",
    "c5e8fa",
    "d9d9d9",
    "dcde32",
    "DD4B39",
    "e6a043",
    "ff8d20",
    "ffe6c8",
    "ffc26e",
    "ffffff");


  public static function resetColours()
  {
    Benchmark::$nextColourIndex = 0;
  }

  public static function nextColour()
  {
    if (Benchmark::$nextColourIndex > count(Benchmark::$availableColours) || Benchmark::$nextColourIndex < 0)
    {
      Benchmark::resetColours();
    }
    return Benchmark::$availableColours[Benchmark::$nextColourIndex++];
  }
  
  public static function nextColours($howMany)
  {
    $all = array();
    for($i=0; $i<$howMany; $i++)
    {
      $all[] = Benchmark::nextColour();
    }
    return $all;
  }
  
  public function numberOfPoints()
  {
    return count($this->points);
  }
  
  public function googleChartPoints() 
  {
    $allValues = $this->points;
    $maxValue = $this->getMax();
    
    $encodeMap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-.';
    $encodeMapLength = strlen($encodeMap);
    $chartData = '';

    foreach($allValues as $numericVal)
    {
      $scaledValue = floor($encodeMapLength * $encodeMapLength * $numericVal / $maxValue);
      if($scaledValue > ($encodeMapLength * $encodeMapLength) - 1) {
        $chartData .= "..";
      } else if ($scaledValue < 0) {
        $chartData .= '__';
      } else {

        $quotient = floor($scaledValue / $encodeMapLength);
        $remainder = $scaledValue - $encodeMapLength * $quotient;
        $chartData .= $encodeMap[$quotient] . $encodeMap[$remainder];
      }
    }
    return $chartData;
  }  

  public static function maxWithBuffer($allBenchmarks, $buffer = 0)
  {
    $max = max(array_map(function($b) { return $b->getMax(); },$allBenchmarks));
    return self::roundUp($max * (1 + $buffer));
  }
  
  public static function roundUp($value) 
  { 
    $precisionFactor = 1;
    return ceil( $value * $precisionFactor )/$precisionFactor; 
  }
  
}
?>
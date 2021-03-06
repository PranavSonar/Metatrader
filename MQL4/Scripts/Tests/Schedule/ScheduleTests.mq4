//+------------------------------------------------------------------+
//|                                               ScheduleTests.mq4  |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property description "Tests functionality of the Schedule class."
#property strict

#include <Schedule\Tests\ScheduleTests.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   ScheduleTests *tests=new ScheduleTests();
   tests.RunAllTests();
   tests.unitTest.printDetail();
   tests.unitTest.printSummary();
   delete tests;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                             ValidationResult.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ValidationResult
  {
public:
   bool              Result;
   string            Message;
   ValidationResult(){}
   ~ValidationResult(){}
  };
//+------------------------------------------------------------------+

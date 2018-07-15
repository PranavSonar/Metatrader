//+------------------------------------------------------------------+
//|                                                   BaseLogger.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BaseLogger
  {
public:
   virtual void      Log(string message);
   virtual void      Warn(string message);
   virtual void      Error(string message);
   virtual void      Comment(string message);
   virtual void      Print(string message);
   virtual void      Alert(string message);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Log(string message)
  {
   this.Print(StringConcatenate("LOG : ",message));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Warn(string message)
  {
   this.Print(StringConcatenate("WARN : ",message));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Error(string message)
  {
   this.Print(StringConcatenate("ERROR : ",message));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Comment(string message)
  {
   ::Comment(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Print(string message)
  {
   ::Print(message);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLogger::Alert(string message)
  {
   ::Alert(message);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                 ExtremeBreak.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ExtremeBreak
  {
public:
   int               Period;
   string            Symbol;
   ENUM_TIMEFRAMES   Timeframe;
   int               Shift;
   double            Low;
   double            High;
   double            Open;
   int               Signal;
                     ExtremeBreak(int period,string symbol,ENUM_TIMEFRAMES timeframe,int shift);
   int               Analyze();
   int               Analyze(int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ExtremeBreak::ExtremeBreak(int period,string symbol,ENUM_TIMEFRAMES timeframe,int shift=2)
  {
   this.Period=period;
   this.Symbol=symbol;
   this.Timeframe=timeframe;
   this.Shift=shift;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ExtremeBreak::Analyze()
  {
   this.Analyze(this.Shift);
   return this.Signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ExtremeBreak::Analyze(int shift)
  {
   this.Signal=0;
   this.Low  = iLow(this.Symbol, this.Timeframe, iLowest(this.Symbol,this.Timeframe,MODE_LOW,this.Period,shift));
   this.High = iHigh(this.Symbol, this.Timeframe, iHighest(this.Symbol,this.Timeframe,MODE_HIGH,this.Period,shift));
   this.Open = iOpen(this.Symbol, this.Timeframe, 0);
   if(this.Open<this.Low)
     {
      this.Signal=-1;
     }
   if(this.Open>this.High)
     {
      this.Signal=1;
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                    Stopwatch.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Stopwatch
  {
private:
   datetime          _startTime;
   datetime          _endTime;
   bool stopped;
public:
   void Stopwatch() {this._startTime=0; this._endTime=0;}
   int ElapsedSeconds()
     {
      int r=0;
      if(_endTime==0) 
        {
         r=((int)(TimeLocal()-_startTime));
         return r;
        }
      else 
        {
         r = ((int)((_endTime)-(_startTime)));
         if(r<0) return 0;
         return r;
        }
     };
   void Start() {this.Clear(); this._startTime=TimeLocal();}
   void Stop() {this._endTime=TimeLocal();}
   void Reset() {this._startTime=0; this._endTime=0; this.Start(); }
   void Clear() {this._startTime=0; this._endTime=0;}
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                             LastClosedToggle.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\LastClosedBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LastClosedToggle : public LastClosedBase
  {
public:
                     LastClosedToggle(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,double skew,AbstractSignal *aSubSignal=NULL);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LastClosedToggle::LastClosedToggle(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,double skew,AbstractSignal *aSubSignal=NULL):LastClosedBase(period,timeframe,0,minimumSpreadsTpSl,skew,aSubSignal)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *LastClosedToggle::Analyzer(string symbol,int shift)
  {
   // if there are no orders open...
   if(0>=OrderManager::PairOpenPositionCount(symbol,TimeCurrent()))
     {
      MqlTick tick;
      bool gotTick=SymbolInfoTick(symbol,tick);
      // and there's a fresh tick on the symbol's chart
      if(gotTick)
        {
         int ticket=this.GetLastClosedTicketNumber(symbol);
         // if there is no order history, so no ticket to find
         if(ticket<=0)
           {
            this.SetBuySignal(symbol,shift,tick);
           }
         // if there is a closed order in the history
         if(ticket>0)
           {
            // and the closed order can be selected
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)==true)
              {
               bool sellSignal=(OrderType()==OP_BUY);
               bool buySignal=(OrderType()==OP_SELL);
               // Sell when the last order was a buy
               if(sellSignal)
                 {
                  this.SetSellSignal(symbol,shift,tick);
                 }
               // Buy when the last order was a sell
               else if(buySignal)
                 {
                  this.SetBuySignal(symbol,shift,tick);
                 }
              }
           }
        }
     }

// signal confirmation
   if(!this.DoesSubsignalConfirm(symbol,shift))
     {
      this.Signal.Reset();
     }

   return this.Signal;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                        LastCloseFollowsPrice.mqh |
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
class LastCloseFollowsPrice : public LastClosedBase
  {
private:
   bool              _invertedSignal;
public:
                     LastCloseFollowsPrice(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,bool invertSignal,double skew,AbstractSignal *aSubSignal=NULL);
   SignalResult     *Analyzer(string symbol,int shift);
   void InvertedSignal(bool invertSignal) { this._invertedSignal=invertSignal; }
   bool InvertedSignal() { return this._invertedSignal; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LastCloseFollowsPrice::LastCloseFollowsPrice(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,bool invertSignal,double skew,AbstractSignal *aSubSignal=NULL):LastClosedBase(period,timeframe,0,minimumSpreadsTpSl,skew,aSubSignal)
  {
   this._invertedSignal=invertSignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *LastCloseFollowsPrice::Analyzer(string symbol,int shift)
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
            // signal confirmation
            if(!this.DoesSubsignalConfirm(symbol,shift))
              {
               this.SetSellSignal(symbol,shift,tick);
               // signal confirmation
               if(!this.DoesSubsignalConfirm(symbol,shift))
                 {
                  this.Signal.Reset();
                 }
              }
           }
         // if there is a closed order in the history
         if(ticket>0)
           {
            // and the closed order can be selected
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)==true)
              {
               bool sell=(OrderType()==OP_BUY && OrderProfit()<=0) || (OrderType()==OP_SELL && OrderProfit()>0);
               bool buy=(OrderType()==OP_SELL && OrderProfit()<=0) || (OrderType()==OP_BUY && OrderProfit()>0);
               bool sellSignal=(_compare.Ternary(this.InvertedSignal(),buy,sell));
               bool buySignal=(_compare.Ternary(this.InvertedSignal(),sell,buy));
               // Sell when the last order was a buy order that lost, or a sell order that won
               if(sellSignal)
                 {
                  this.SetSellSignal(symbol,shift,tick);
                 }
               // Buy when the last order was a sell order that lost, or a buy order that won
               else if(buySignal)
                 {
                  this.SetBuySignal(symbol,shift,tick);
                 }

               // signal confirmation
               if(!this.DoesSubsignalConfirm(symbol,shift))
                 {
                  this.Signal.Reset();
                 }
              }
           }
        }
     }

// if there is an order open...
   if(1<=OrderManager::PairOpenPositionCount(symbol,TimeCurrent()))
     {
      MqlTick tick;
      bool gotTick=SymbolInfoTick(symbol,tick);
      // and there's a fresh tick on the symbol's chart
      if(gotTick)
        {
         this.SetExits(symbol,shift,tick);
        }
     }

   return this.Signal;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                     AtrExits.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\AtrBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtrExits : public AtrBase
  {
public:
                     AtrExits(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrExits::AtrExits(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine):AtrBase(period,atrMultiplier,timeframe,shift,minimumSpreadsTpSl,indicatorColor)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AtrExits::Analyzer(string symbol,int shift)
  {
   OrderManager om;
   if(om.PairOpenPositionCount(symbol,TimeCurrent())<1)
     {
      return this.Signal;
     }
   double buyPrice=om.PairAveragePrice(symbol,OP_BUY);
   double sellPrice=om.PairAveragePrice(symbol,OP_SELL);
   if(_compare.Xnor((buyPrice>0),(sellPrice>0)))
     {
      return this.Signal;
     }

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      double mid=tick.ask;
      if(sellPrice>0)
        {
         mid=tick.bid;
        }

      PriceRange pr=this.CalculateRange(symbol,shift,mid);

      this.DrawIndicatorRectangle(symbol,shift,pr.high,pr.low);
      
      if(sellPrice>0)
        {
         this.Signal.isSet=true;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.time=tick.time;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=pr.high;
         this.Signal.takeProfit=pr.low;
        }
      if(buyPrice>0)
        {
         this.Signal.isSet=true;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_BUY;
         this.Signal.time=tick.time;
         this.Signal.price=tick.ask;
         this.Signal.stopLoss=pr.low;
         this.Signal.takeProfit=pr.high;
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+

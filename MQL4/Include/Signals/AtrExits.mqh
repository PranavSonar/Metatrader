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
                     AtrExits(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,double skew,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrExits::AtrExits(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,double skew,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine):AtrBase(period,atrMultiplier,timeframe,skew,shift,minimumSpreadsTpSl,indicatorColor)
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
      double ctr=tick.ask;
      if(sellPrice>0)
        {
         ctr=tick.bid;
        }

      PriceRange pr=this.CalculateRange(symbol,shift,ctr);

      double height=pr.high-pr.low;
      double top=pr.high;
      double bottom=pr.low;

      if(sellPrice>0)
        {
         ctr=ctr+((height)*this._skew);
         top=tick.ask+(pr.high-ctr);
         bottom=tick.ask-(ctr-pr.low);

         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=top;
         this.Signal.takeProfit=bottom;
         if(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=tick.ask+(MarketInfo(symbol,MODE_SPREAD)*this.MinimumSpreadsDistance()*MarketInfo(symbol,MODE_POINT));
            this.Signal.takeProfit=tick.ask-(MarketInfo(symbol,MODE_SPREAD)*this.MinimumSpreadsDistance()*MarketInfo(symbol,MODE_POINT));
           }
         while(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=this.Signal.stopLoss+(1*MarketInfo(symbol,MODE_POINT));
            this.Signal.takeProfit=this.Signal.takeProfit-(1*MarketInfo(symbol,MODE_POINT));
           }
        }
      if(buyPrice>0)
        {
         ctr=ctr-((height)*this._skew);
         top=tick.bid+(pr.high-ctr);
         bottom=tick.bid-(ctr-pr.low);

         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.stopLoss=bottom;
         this.Signal.takeProfit=top;
         if(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=tick.bid-(MarketInfo(symbol,MODE_SPREAD)*this.MinimumSpreadsDistance()*MarketInfo(symbol,MODE_POINT));
            this.Signal.takeProfit=tick.bid+(MarketInfo(symbol,MODE_SPREAD)*this.MinimumSpreadsDistance()*MarketInfo(symbol,MODE_POINT));
           }
         while(!this.DoesSignalMeetRequirements())
           {
            this.Signal.stopLoss=this.Signal.stopLoss-(1*MarketInfo(symbol,MODE_POINT));
            this.Signal.takeProfit=this.Signal.takeProfit+(1*MarketInfo(symbol,MODE_POINT));
           }
        }

      this.DrawIndicatorRectangle(symbol,shift,top,bottom);
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+

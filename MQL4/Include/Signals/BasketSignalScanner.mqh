//+------------------------------------------------------------------+
//|                                          BasketSignalScanner.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\BaseSymbolScanner.mqh>
#include <Common\OrderManager.mqh>
#include <Signals\SignalSet.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BasketSignalScanner : public BaseSymbolScanner
  {
private:
   OrderManager      orderManager;
   SignalSet        *signalSet;
   double            lotSize;
public:
   void              BasketSignalScanner(SymbolSet *aSymbolSet,SignalSet *aSignalSet,double lotSize);
   void              PerSymbolAction(string symbol);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasketSignalScanner::BasketSignalScanner(SymbolSet *aSymbolSet,SignalSet *aSignalSet,double aLotSize):BaseSymbolScanner(aSymbolSet)
  {
   this.signalSet=aSignalSet;
   this.lotSize=aLotSize;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BasketSignalScanner::PerSymbolAction(string symbol)
  {
   this.signalSet.Analyze(symbol);
   if(this.signalSet.Signal!=NULL)
     {
      SignalResult *r=this.signalSet.Signal;
      if(r.isSet==true)
        {
         if(r.stopLoss>0)
           {
            double w=MathAbs(r.takeProfit-r.stopLoss);
            // if stop loss and take profit are both zero,
            // then the trade won't be immediately stopped out.
            if(w>0)
              {
               double point=MarketInfo(symbol,MODE_POINT);
               double minW=MarketInfo(symbol,MODE_SPREAD)*3;
               if(w/point<minW)
                 {
                  // if the distance between the stop loss and 
                  // take profit are too narrow, then the trade
                  // will get stopped out almost immediately.
                  r.Reset();
                  return;
                 }
              }
           }
         if(this.orderManager.PairOpenPositionCount(r.symbol,TimeCurrent())<1)
           {
            this.orderManager.SendOrder(r,this.lotSize);
           }
         else
           {
            // modifies the sl and tp according to the signal given.
            this.orderManager.NormalizeExits(r.symbol,r.orderType,r.stopLoss,r.takeProfit);
           }
        }
     }
  }
//+------------------------------------------------------------------+

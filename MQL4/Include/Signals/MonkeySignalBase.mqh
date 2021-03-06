//+------------------------------------------------------------------+
//|                                             MonkeySignalBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\OrderManager.mqh>
#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
#include <Signals\Config\MonkeySignalConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MonkeySignalBase : public AbstractSignal
  {
protected:
   double            _atrExitsMultiplier;
   virtual PriceRange CalculateRange(string symbol,int shift,double midPrice);
   virtual void      SetBuySignal(string symbol,int shift,MqlTick &tick,bool setTp);
   virtual void      SetSellSignal(string symbol,int shift,MqlTick &tick,bool setTp);
   virtual void      SetSellExits(string symbol,int shift,MqlTick &tick);
   virtual void      SetBuyExits(string symbol,int shift,MqlTick &tick);
   virtual void      SetExits(string symbol,int shift,MqlTick &tick);

public:
                     MonkeySignalBase(MonkeySignalConfig &config,AbstractSignal *aSubSignal=NULL);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MonkeySignalBase::MonkeySignalBase(MonkeySignalConfig &config,AbstractSignal *aSubSignal=NULL):AbstractSignal(config,aSubSignal)
  {
   this._atrExitsMultiplier=config.AtrExitsMultiplier;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MonkeySignalBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);
   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MonkeySignalBase::DoesSignalMeetRequirements()
  {
   if(!(AbstractSignal::DoesSignalMeetRequirements()))
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange MonkeySignalBase::CalculateRange(string symbol,int shift,double midPrice)
  {
   PriceRange pr;
   pr.mid=midPrice;
   double atr=(this.GetAtr(symbol,shift)*this._atrExitsMultiplier);
   pr.low=(pr.mid-atr);
   pr.high=(pr.mid+atr);
   return pr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignalBase::SetBuySignal(string symbol,int shift,MqlTick &tick,bool setTp)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.ask);

   double tp=0;
   if(setTp)
     {
      tp=pr.high;
     }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_BUY;
   this.Signal.price=tick.ask;
   this.Signal.stopLoss=pr.low;
   this.Signal.takeProfit=tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignalBase::SetSellSignal(string symbol,int shift,MqlTick &tick,bool setTp)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.bid);

   double tp=0;
   if(setTp)
     {
      tp=pr.low;
     }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_SELL;
   this.Signal.price=tick.bid;
   this.Signal.stopLoss=pr.high;
   this.Signal.takeProfit=tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignalBase::SetBuyExits(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.bid);

   double ap=OrderManager::PairHighestPricePaid(symbol,OP_BUY);
   double sl=pr.low;
   double pad=this.GetAtr(symbol,shift,14);

   double tp=OrderManager::PairHighestTakeProfit(symbol,OP_BUY);

   if(tp>0)
     {
      sl=OrderManager::PairHighestStopLoss(symbol,OP_BUY);
     }
   else if(sl>0 && sl>ap+pad)
     {
      sl=sl-pad;
     }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_BUY;
   this.Signal.price=tick.ask;
   this.Signal.stopLoss=sl;
   this.Signal.takeProfit=tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignalBase::SetSellExits(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.ask);

   double ap=OrderManager::PairLowestPricePaid(symbol,OP_SELL);
   double sl=pr.high;
   double pad=this.GetAtr(symbol,shift,14);

   double tp=OrderManager::PairLowestTakeProfit(symbol,OP_SELL);

   if(tp>0)
     {
      sl=OrderManager::PairLowestStopLoss(symbol,OP_SELL);
     }
   else if(sl>0 && sl<ap-pad)
     {
      sl=sl+pad;
     }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_SELL;
   this.Signal.price=tick.bid;
   this.Signal.stopLoss=sl;
   this.Signal.takeProfit=tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignalBase::SetExits(string symbol,int shift,MqlTick &tick)
  {
   if(0<OrderManager::PairProfit(symbol))
     {
      if(0<OrderManager::PairOpenPositionCount(OP_BUY,symbol,TimeCurrent()))
        {
         if((!this.Signal.isSet) || (this.Signal.isSet && this.Signal.orderType==OP_BUY))
           {
            this.SetBuyExits(symbol,shift,tick);
           }
        }
      if(0<OrderManager::PairOpenPositionCount(OP_SELL,symbol,TimeCurrent()))
        {
         if((!this.Signal.isSet) || (this.Signal.isSet && this.Signal.orderType==OP_SELL))
           {
            this.SetSellExits(symbol,shift,tick);
           }
        }
     }
  }
//+------------------------------------------------------------------+

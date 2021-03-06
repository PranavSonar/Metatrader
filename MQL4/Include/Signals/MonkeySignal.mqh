//+------------------------------------------------------------------+
//|                                                 MonkeySignal.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\MonkeySignalBase.mqh>
#include <Signals\AdxSignal.mqh>
#include <Signals\RsiBands.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MonkeySignal : public MonkeySignalBase
  {
private:
   datetime          _lastTrigger;
   RsiBands         *_rsiBands;
   AdxSignal        *_adxSignal;
   MonkeySignalConfig _config;
public:
                     MonkeySignal(MonkeySignalConfig &config,AbstractSignal *aSubSignal=NULL);
                    ~MonkeySignal();
   SignalResult     *Analyzer(string symbol,int shift);
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignal::MonkeySignal(MonkeySignalConfig &config,AbstractSignal *aSubSignal=NULL):MonkeySignalBase(config,aSubSignal)
  {
   this._lastTrigger=TimeCurrent();
   this._config=config;
   this._rsiBands=new RsiBands(config.RsiBands);
   AdxSignalConfig adxConf;
   adxConf.Period=config.RsiBands.Period;
   adxConf.Timeframe=this.Timeframe();
   adxConf.Shift=this.Shift();
   adxConf.AppliedPrice=config.RsiBands.AppliedPrice;
   adxConf.Threshold=30;
   this._adxSignal=new AdxSignal(adxConf);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MonkeySignal::~MonkeySignal()
  {
   delete this._rsiBands;
   delete this._adxSignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MonkeySignal::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);
   this._rsiBands.Validate(v);
   this._adxSignal.Validate(v);

   if(!this._compare.IsGreaterThanOrEqualTo(this._config.TriggerLevel,0.0))
     {
      v.Result=false;
      v.AddMessage("Trigger level must be zero or greater.");
     }
   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *MonkeySignal::Analyzer(string symbol,int shift)
  {
   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   CandleMetrics *candle=this.GetCandleMetrics(symbol,shift);

   if(gotTick && candle.IsSet && candle.Time!=this._lastTrigger)
     {
      double atr=this.GetAtr(symbol,shift);
      double atrTriggerWidth=atr*this._config.TriggerLevel;

      int rangePeriod=((int)MathCeil(this.Period()*1.0));
      int rangeShift=shift+1;
      PriceRange rangeNullZone=this.CalculateRangeByPriceLowHigh(symbol,rangeShift,rangePeriod);
      double rangeNullZoneHalfSpread=(rangeNullZone.high-rangeNullZone.low)*0.125;
      rangeNullZone.low=rangeNullZone.mid-rangeNullZoneHalfSpread;
      rangeNullZone.high=rangeNullZone.mid+rangeNullZoneHalfSpread;

      int trendPeriod=((int)MathCeil(this.Period()*2.0));
      int trendShift=((int)MathCeil(this.Period()*0.1));
      PriceRange trendNullZone=this.CalculateRangeByPriceLowHigh(symbol,trendShift,trendPeriod);
      double trendNullZoneHalfSpread=(trendNullZone.high-trendNullZone.low)*0.625;
      trendNullZone.low=trendNullZone.mid-trendNullZoneHalfSpread;
      trendNullZone.high=trendNullZone.mid+trendNullZoneHalfSpread;

      PriceRange atrTrigger;
      atrTrigger.high=candle.Open+atrTriggerWidth;
      atrTrigger.low=candle.Open-atrTriggerWidth;

      this.DrawIndicatorRectangle(symbol,rangeShift,rangeNullZone.high,rangeNullZone.low,"_rangeNullZone",rangePeriod,clrRed);

      this.DrawIndicatorRectangle(symbol,trendShift,trendNullZone.high,trendNullZone.low,"_trendNullZone",trendPeriod,clrYellow);

      this.DrawIndicatorRectangle(symbol,shift,atrTrigger.high,atrTrigger.low,"_atrTrigger",1);

      if(this._compare.IsBetween(candle.Close,trendNullZone.low,trendNullZone.high))
        {
         this._atrExitsMultiplier=(this._config.AtrExitsMultiplier);
        }
      else
        {
         this._atrExitsMultiplier=(this._config.AtrExitsMultiplier);
        }

      bool sellSignal=false,buySignal=false,setTp=false
         ,crossingUp=false,crossingDown=false;

      crossingUp=this._adxSignal.IsBullishCrossover(symbol,shift);
      crossingDown=this._adxSignal.IsBearishCrossover(symbol,shift);

      if(candle.High>=atrTrigger.high || candle.Low<=atrTrigger.low)
        {
         bool trendingUp=false,trendingDown=false
            ,rsiSell=false,rsiBuy=false;

         trendingUp=this._adxSignal.IsBullish(symbol,shift) && this._compare.IsGreaterThan(candle.Close,trendNullZone.high);
         trendingDown=this._adxSignal.IsBearish(symbol,shift) && this._compare.IsLessThan(candle.Close,trendNullZone.low);
         rsiSell=this._rsiBands.IsSellSignal(symbol,shift);
         rsiBuy=this._rsiBands.IsBuySignal(symbol,shift);

         if(this._compare.IsNotBetween(candle.Close,rangeNullZone.low,rangeNullZone.high))
           {
            if(trendingDown || trendingUp)
              {
               if(this._compare.IsNotBetween(candle.Close,trendNullZone.low,trendNullZone.high))
                 {
                  // trend, no oscillator
                  if(trendingDown)
                    {
                     this.DrawIndicatorArrow(symbol,shift,trendNullZone.low,(char)218,5,"_trendingDown");
                    }
                  if(trendingUp)
                    {
                     this.DrawIndicatorArrow(symbol,shift,trendNullZone.low,(char)217,5,"_trendingUp");
                    }
                  sellSignal=crossingDown;
                  buySignal=crossingUp;
                  setTp=false;
                 }
              }
            else if(candle.High>=atrTrigger.high || candle.Low<=atrTrigger.low)
              {
               // no trend, use oscillator
               this.DrawIndicatorArrow(symbol,shift,trendNullZone.low,(char)216,5,"_ranging");
               sellSignal=rsiSell;
               buySignal=rsiBuy;
               if(rsiSell || rsiBuy)
                 {
                  setTp=this._rsiBands.IsInMidBand(symbol,shift);
                 }
              }
           }
        }

      if(_compare.Xor(sellSignal,buySignal))
        {
         if(sellSignal)
           {
            this.SetSellSignal(symbol,shift,tick,setTp);
           }

         if(buySignal)
           {
            this.SetBuySignal(symbol,shift,tick,setTp);
           }

         // signal confirmation
         if(!this.DoesSubsignalConfirm(symbol,shift))
           {
            this.Signal.Reset();
           }
         else
           {
            this._lastTrigger=candle.Time;
           }
        }
      else
        {
         this.Signal.Reset();
        }
     }

// if there is an order open...
   if(1<=OrderManager::PairOpenPositionCount(symbol,TimeCurrent()))
     {
      this.SetExits(symbol,shift,tick);
     }

   delete candle;
   return this.Signal;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                              AtrRange.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>
#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtrRange : public AbstractSignal
  {
private:
   Comparators       _compare;
   double            _low;
   double            _high;
   double            _atr;
   int               _atrPeriod;
   double            _atrMultiplier;
   color             _atrColor;
   int               _minimumPointsDistance;
   CChartObjectRectangle _atrIndicator;
public:
   void              DrawIndicator(string symbol,int shift);
                     AtrRange(int atrPeriod,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,int minimumPointsTpSl=50,color atrColor=clrAquamarine);
   bool              Validate(ValidationResult *v);
   SignalResult     *Analyze(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrRange::AtrRange(int atrPeriod,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,int minimumPointsTpSl=50,color atrColor=clrAquamarine)
  {
   this._atrPeriod=atrPeriod;
   this._atrMultiplier=atrMultiplier;
   this.Timeframe(timeframe);
   this._atrColor=atrColor;
   this.Shift(shift);
   this._minimumPointsDistance=minimumPointsTpSl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtrRange::Validate(ValidationResult *v)
  {
   v.Result=true;

   if(!this._compare.IsNotBelow(this._atrPeriod,1))
     {
      v.Result=false;
      v.AddMessage("Period must be 1 or greater.");
     }

   if(!this._compare.IsNotBelow(this.Shift(),0))
     {
      v.Result=false;
      v.AddMessage("Shift must be 0 or greater.");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AtrRange::DrawIndicator(string symbol,int shift)
  {
   if(!this.DoesChartHaveEnoughBars(symbol,(shift+this._atrPeriod)))
     {
      return;
     }

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe());

   if(this._atrIndicator.Attach(chartId,this.ID(),0,2))
     {
      this._atrIndicator.SetPoint(0,Time[shift+this._atrPeriod],this._high);
      this._atrIndicator.SetPoint(1,Time[shift],this._low);
     }
   else
     {
      this._atrIndicator.Create(chartId,this.ID(),0,Time[shift+this._atrPeriod],this._high,Time[shift],this._low);
      this._atrIndicator.Color(this._atrColor);
      this._atrIndicator.Background(false);
     }

   ChartRedraw(chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AtrRange::Analyze(string symbol,int shift)
  {
   this.Signal.Reset();

   if(!this.DoesHistoryGoBackFarEnough(symbol,(shift+this._atrPeriod)))
     {
      return this.Signal;
     }

   this._atr=iATR(symbol,this.Timeframe(),this._atrPeriod,shift);

   this._low  = iLow(symbol, this.Timeframe(), iLowest(symbol,this.Timeframe(),MODE_LOW,this._atrPeriod,shift));
   this._high = iHigh(symbol, this.Timeframe(), iHighest(symbol,this.Timeframe(),MODE_HIGH,this._atrPeriod,shift));

   double mid=((this._low+this._high)/2);

   this._low=mid -(this._atr*this._atrMultiplier);
   this._high=mid+(this._atr*this._atrMultiplier);

   this.DrawIndicator(symbol,shift);

   double point=MarketInfo(symbol,MODE_POINT);
   double minimumPoints=(double)this._minimumPointsDistance;

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(tick.bid>=mid)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=(tick.bid+MathAbs(this._high-tick.bid));
         this.Signal.takeProfit=this._low;
        }
      if(tick.ask<=mid)
        {
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=(tick.ask-MathAbs(tick.ask-this._low));
         this.Signal.takeProfit=this._high;
        }
      if(this.Signal.isSet)
        {
         if(MathAbs(this.Signal.price-this.Signal.takeProfit)/point<minimumPoints)
           {
            this.Signal.Reset();
           }
         if(MathAbs(this.Signal.price-this.Signal.stopLoss)/point<minimumPoints)
           {
            this.Signal.Reset();
           }
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+

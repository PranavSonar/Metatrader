//+------------------------------------------------------------------+
//|                                                              MPC |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Does Magic."
#property strict

#include <PLManager\PLManager.mqh>
#include <Signals\ExtremeBreak.mqh>

input int ExtremeBreakPeriod=24;
input int ExtremeBreakShift=2;
input double Lots=0.4;
input double ProfitTarget=60; // Profit target in account currency
input double MaxLoss=60; // Maximum allowed loss in account currency
input int Slippage=10; // Allowed slippage
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MPC
  {
public:
   OrderManager      orderManager;
   PLManager         plmanager;
   ExtremeBreak     *signalExtremeBreak;
   datetime          time;
                     MPC(int extremeBreakPeriod,int extremeBreakShift,double lots,
                                           double profitTarget,double maxLoss,int slippage,
                                           string symbol,ENUM_TIMEFRAMES timeframe);
                    ~MPC();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MPC::MPC(int extremeBreakPeriod,int extremeBreakShift,double lots,
         double profitTarget,double maxLoss,int slippage,
         string symbol,ENUM_TIMEFRAMES timeframe)
  {
   this.plmanager.WatchedPairs=symbol;
   this.plmanager.ProfitTarget=profitTarget;
   this.plmanager.MaxLoss=maxLoss;
   this.plmanager.Slippage=slippage;
   this.signalExtremeBreak=new ExtremeBreak(extremeBreakPeriod,symbol,timeframe,extremeBreakShift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MPC::~MPC()
  {
   delete this.signalExtremeBreak;
  }

MPC *mpc;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   delete mpc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   mpc=new MPC(ExtremeBreakPeriod,ExtremeBreakShift,Lots,ProfitTarget,MaxLoss,Slippage,Symbol(),(ENUM_TIMEFRAMES)Period());
   ValidationResult *validationResult=mpc.plmanager.Validate();
   bool out=validationResult.Result;
   string message=validationResult.Message;
   delete validationResult;
   if(out==false)
     {
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      Print("User Settings validation failed.");
      Print(message);
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      ExpertRemove();
     }
  }
//+------------------------------------------------------------------+
//|Rules to stop the bot from even trying to trade                   |
//+------------------------------------------------------------------+
bool CanTrade()
  {
   return mpc.plmanager.CanTrade();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!CanTrade())
     {
      return;
     }
   if(Time[0]!=mpc.time)
     {
      mpc.time=Time[0];
      mpc.signalExtremeBreak.Analyze();
      if(mpc.signalExtremeBreak.Signal<0)
        {
         if(false==OrderSend(mpc.signalExtremeBreak.Symbol,OP_SELL,Lots,Bid,mpc.plmanager.Slippage,0,0))
           {
            Print(GetLastError());
           }
        }
      if(mpc.signalExtremeBreak.Signal>0)
        {
         if(false==OrderSend(mpc.signalExtremeBreak.Symbol,OP_BUY,Lots,Ask,mpc.plmanager.Slippage,0,0))
           {
            Print(GetLastError());
           }
        }
     }
   mpc.plmanager.Execute();
  }
//+------------------------------------------------------------------+

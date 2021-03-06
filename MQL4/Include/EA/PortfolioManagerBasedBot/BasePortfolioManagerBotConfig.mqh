//+------------------------------------------------------------------+
//|                                BasePortfolioManagerBotConfig.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <EA\Common\EAConfig.mqh>
#include <BacktestOptimizations\BacktestOptimizationsConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct BasePortfolioManagerBotConfig : public EAConfig
  {
public:
   string            watchedSymbols;
   double            lots;
   double            profitTarget;
   double            profitTargetSymbol;
   double            profitTargetSymbolHedge;
   double            maxLoss;
   double            maxLossSymbol;
   double            maxLossSymbolHedge;
   int               slippage;
   ENUM_DAY_OF_WEEK  startDay;
   ENUM_DAY_OF_WEEK  endDay;
   string            startTime;
   string            endTime;
   bool              scheduleIsDaily;
   bool              tradeAtBarOpenOnly;
   bool              pinExits;
   bool              switchDirectionBySignal;
   int               maxOpenOrderCount; // Max Open Positions Per Symbol
   double            gridStepUpSizeInPricePercent; // Average up when price moves X percent
   double            gridStepDownSizeInPricePercent; // Average down when price moves X percent
   bool              averageUpStrategy; // Enable Average Up
   bool              averageDownStrategy; // Enable Average Down
   bool              allowHedging; // Enable Hedging (buy and sell on same symbol)
   BacktestOptimizationsConfig backtestConfig;
  };
//+------------------------------------------------------------------+

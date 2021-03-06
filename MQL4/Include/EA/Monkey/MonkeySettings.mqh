//+------------------------------------------------------------------+
//|                                               MonkeySettings.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

sinput string MonkeySettings1; // ####
sinput string MonkeySettings2; // #### Signal Settings
sinput string MonkeySettings3; // ####

input int BotPeriod=120; // Period for calculating trigger and exit.
input double BotTriggerLevel=1; // ATR Trigger Level.
input double BotAtrExitsMultiplier=0.5; // Exits Spread Multiplier.
input double BotMinimumTpSlDistance=3.0; // Tp/Sl minimum distance, in spreads.

input int BotRsiPeriod=14; // RSI Period.
input double BotRsiWidebandHigh=70.0; // RSI Overbought Level.
input double BotRsiWidebandLow=30.0; // RSI Oversold Level.
sinput string MonkeySettings4; // #### Trades opened when RSI is in the midband will have a TP set.
input double BotRsiMidbandHigh=65.0; // RSI Midband High.
input double BotRsiMidbandLow=35.0; // RSI Midband Low.
sinput string MonkeySettings5; // #### No trades are placed when RSI is between the Noise High and Low.
input double BotRsiNullbandHigh=55.0; // RSI Noise High.
input double BotRsiNullbandLow=45.0; // RSI Noise Low.

input color BotIndicatorColor=clrAqua; // Indicator Color.
      
#include <EA\PortfolioManagerBasedBot\BasicSettings.mqh>
//+------------------------------------------------------------------+

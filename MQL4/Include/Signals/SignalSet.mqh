//+------------------------------------------------------------------+
//|                                                    SignalSet.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property description "Signal collection."
#property strict

#include <Common\OrderManager.mqh>
#include <Generic\LinkedList.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalSet : public CLinkedList<AbstractSignal *>
  {
private:
   template<typename T>
   T                 TakeLowerOf(T a,T b);
   template<typename T>
   T                 TakeHigherOf(T a,T b);
   void              MergeBuyConcurrence(SignalResult *s);
   void              MergeSellConcurrence(SignalResult *s);
   bool              HasValidSignal(double minimumSpreadsDistance);
public:
   AbstractSignal   *ExitSignal;
   string            Name;
   SignalResult     *Signal;
   bool              DeleteSignalsOnClear;
   void              Clear(bool deleteSignals=true);
   bool              Validate(ValidationResult *v);
   void              Analyze(string symbol,bool closesOnOppositeSignal);
   void              AnalyzeConcurrence(string symbol);
   void              MergeConcurrence(SignalResult *s);
   void              SignalSet();
   void             ~SignalSet();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalSet::SignalSet():CLinkedList<AbstractSignal *>()
  {
   this.DeleteSignalsOnClear=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalSet::~SignalSet()
  {
   this.Clear(this.DeleteSignalsOnClear);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalSet::Clear(bool deleteSignals=true)
  {
   if(deleteSignals && this.Count()>0)
     {
      CLinkedListNode<AbstractSignal*>*node=this.First();

      delete node.Value();

      do
        {
         node=node.Next();
         delete node.Value();
        }
      while(this.Last()!=node);
     }

   CLinkedList<AbstractSignal *>::Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalSet::Validate(ValidationResult *v)
  {
   bool out=true;
   if(this.Count()>0)
     {
      CLinkedListNode<AbstractSignal *>*node=this.First();
      AbstractSignal *s=node.Value();
      out=out && s.Validate(v);

      while(this.Last()!=node)
        {
         node=node.Next();
         s=node.Value();
         out=out && s.Validate(v);
        }
     }
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalSet::Analyze(string symbol,bool closesOnOppositeSignal)
  {
   this.AnalyzeConcurrence(symbol);
   if(this.ExitSignal!=NULL)
     {
      this.ExitSignal.Analyze(symbol);
      if(this.ExitSignal.Signal!=NULL)
        {
         if(this.ExitSignal.DoesSignalMeetRequirements())
           {
            if(this.Signal==NULL)
              {
               this.Signal=this.ExitSignal.Signal;
              }
            else if(!this.Signal.isSet)
              {
               this.Signal=this.ExitSignal.Signal;
              }
            else if(this.Signal.orderType==this.ExitSignal.Signal.orderType)
              {
               this.MergeConcurrence(this.ExitSignal.Signal);
               if(!this.HasValidSignal(this.ExitSignal.MinimumSpreadsDistance()))
                 {
                  this.Signal=this.ExitSignal.Signal;
                 }
              }
            else if(closesOnOppositeSignal && (this.Signal.orderType==OP_BUY || this.Signal.orderType==OP_SELL))
              {
               this.ExitSignal.Signal.Reset();
              }
            else
              {
               this.Signal=this.ExitSignal.Signal;
              }
           }
        }
      if(this.Signal!=NULL)
        {
         if(!this.HasValidSignal(this.ExitSignal.MinimumSpreadsDistance()))
           {
            this.Signal=NULL;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
T SignalSet::TakeLowerOf(T a,T b)
  {
   if(a==0 && b!=0)
     {
      return b;
     }
   else if(b==0 && a!=0)
     {
      return a;
     }
   else if(a<b)
     {
      return a;
     }
   return b;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
T SignalSet::TakeHigherOf(T a,T b)
  {
   if(a>b)
     {
      return a;
     }
   return b;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalSet::MergeBuyConcurrence(SignalResult *s)
  {
   this.Signal.takeProfit=this.TakeLowerOf(this.Signal.takeProfit,s.takeProfit);
   this.Signal.stopLoss=this.TakeHigherOf(this.Signal.stopLoss,s.stopLoss);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalSet::MergeSellConcurrence(SignalResult *s)
  {
   this.Signal.takeProfit=this.TakeHigherOf(this.Signal.takeProfit,s.takeProfit);
   this.Signal.stopLoss=this.TakeLowerOf(this.Signal.stopLoss,s.stopLoss);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalSet::MergeConcurrence(SignalResult *s)
  {
   if(OrderManager::IsOrderTypeBuying(s.orderType))
     {
      this.MergeBuyConcurrence(s);
     }

   if(OrderManager::IsOrderTypeSelling(s.orderType))
     {
      this.MergeSellConcurrence(s);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalSet::AnalyzeConcurrence(string symbol)
  {
   bool concurrence=true;
   this.Signal=NULL;
   if(this.Count()>0)
     {
      CLinkedListNode<AbstractSignal *>*node=this.First();
      AbstractSignal *s=node.Value();
      s.Analyze(symbol);

      if(!s.Signal.isSet)
        {
         concurrence=false;
        }
      else
        {
         this.Signal=s.Signal;
        }

      while(this.Last()!=node)
        {
         node=node.Next();
         s=node.Value();
         s.Analyze(symbol);

         if(this.Signal==NULL)
           {
            concurrence=false;
           }
         else if(!s.Signal.isSet)
           {
            concurrence=false;
           }
         else if(((ENUM_ORDER_TYPE)s.Signal.orderType)!=((ENUM_ORDER_TYPE)this.Signal.orderType))
           {
            concurrence=false;
           }
         else if(concurrence)
           {
            this.MergeConcurrence(s.Signal);
           }
        }
     }
   if(!concurrence)
     {
      this.Signal=NULL;
     }
   if(this.Signal!=NULL)
     {
      if(!this.HasValidSignal(0))
        {
         this.Signal=NULL;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalSet::HasValidSignal(double minimumSpreadsDistance)
  {
   return OrderManager::ValidateStopLevels(this.Signal) && this.Signal.IsValid(minimumSpreadsDistance);
  }
//+------------------------------------------------------------------+

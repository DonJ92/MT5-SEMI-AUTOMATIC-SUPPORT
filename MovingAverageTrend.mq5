//+------------------------------------------------------------------+
//|                                           MovingAverageTrend.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "MovingAverageTrend"
#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 3

#property indicator_color1    Red
#property indicator_color2    Blue
#property indicator_color3    Green

#resource "trendup.bmp"
#resource "trenddn.bmp"

enum ENUM_ON_OFF
  {
   ON,
   OFF
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_ON_OFF    InpMAOnOff_1=ON;
input ENUM_MA_METHOD InpMAMethod_1=MODE_SMA;
input int            InpMAPeriod_1=10;
input ENUM_ON_OFF    InpMAOnOff_2=ON;
input ENUM_MA_METHOD InpMAMethod_2=MODE_SMA;
input int            InpMAPeriod_2=25;
input ENUM_ON_OFF    InpMAOnOff_3=OFF;
input ENUM_MA_METHOD InpMAMethod_3=MODE_SMA;
input int            InpMAPeriod_3=75;
input color          InpTrendUpColor=C'124,181,62';
input color          InpTrendDnColor=C'204,61,69';
input color          InpTrendUpFontColor=C'';
input color          InpTrendDnFontColor=C'106,106,106';
input ENUM_MA_METHOD InpDiaolog_MAMethod=MODE_SMA;
input int            InpDiaolog_MAPeriod=25;
input ENUM_MA_METHOD InpDiaolog_MADRMethod=MODE_SMA;
input int            InpDiaolog_MADRPeriod=25;
input bool           InpAlert_PSAR=true;
input bool           InpAlert_MACD=true;
input bool           InpAlert_DMI=true;
input bool           InpAlert_MADR=true;
input bool           InpAlert_Trend=true;
input bool           InpAlert_Ichimoku=true;
input bool           InpAlert_RSI=true;
input bool           InpAlert_Stoch=true;
input bool           InpAlert_MFI=true;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
color    mainPanel_BackgroundColor  = C'240,240,240';       // 内側の背景の色
color    mainPanel_BorderColor      = C'240,240,240';       // 内側の枠の色

string   common_Font                = "Yu Gothic Medium"; // 文字フォント
int      common_FontSize            = 10;
int      common_FontSize_XL         = 12;
color    common_FontColor           = clrBlack;
color    common_BackgroundColor     = C'216,216,216';
color    common_BorderColor         = clrGainsboro;         // 損切文字の下の水平線の色
color    common_SubPanel_BorderColor= clrDarkGray;          // 損切文字の下の水平線の色

string   percentBar_Font            = "Arial";            // 文字フォント
int      percentBar_FontSize        = 80;
color    percentBar_FontColor       = C'216,216,216';

color    button_active_ColorBackground = C'106,106,106';
//////////////////////////////////////////////////////////////////////////////////////////////////////
int      CAPTION_LEFT               = 0;
int      CAPTION_TOP                = 0;
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include <Controls\Dialog.mqh>
#include <Controls\Picture.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//---
#define DIALOG_WIDTH                        (250)
#define DIALOG_HEIGHT                       (425)
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_X_XL                   (10)      // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
#define CONTROLS_GAP_Y_XL                   (10)      // gap by X coordinate
//--- for buttons
#define BUTTON_WIDTH                        (70)      // size by X coordinate
#define BUTTON_WIDTH_XL                     (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (25)      // size by Y coordinate

#define BMPBUTTON_WIDTH                     (20)
#define BMPBUTTON_HEIGHT                    (30)
//--- for the indication area
#define EDMIT_HEIGHT                        (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate

#define PANEL_WIDTH                         (70)
#define PANEL_HEIGTH                        (65)
#define PANEL_HEIGTH_XL                     (150)

#define LABEL_WIDTH                         (35)
#define LABEL_WIDTH_XL                      (80)
#define LABEL_HEIGHT                        (20)
#define LABEL_HEIGHT_XS                     (10)
#define LABEL_HEIGHT_XL                     (20)

//---
#define GV_MAT_DIALOG_MA_VISIBLE       "gv.mat_dialog_ma_visible"
#define GV_MAT_DIALOG_HZLINE_VISIBLE   "gv.mat_dialog_hzline_visible"
#define GV_MAT_DIALOG_AXISX            "gv.mat_dialog_axisX"
#define GV_MAT_DIALOG_AXISY            "gv.mat_dialog_axisY"

#define TREND_UP     1
#define TREND_DN     -1
#define TREND_NONE   0

#define NAN          (int)-99999999999
//+------------------------------------------------------------------+
//| Class CMovingAverageTrend                                        |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CMovingAverageTrend : public CAppDialog
  {
private:
   CPanel            m_panel_border;
   CPanel            m_panel_back;
   CWndClient        m_window_client;
   CEdit             m_label_caption;
   CBmpButton        m_button_minmax;
   CBmpButton        m_button_close;

   //---
   CPanel            m_panel_Line;
   CPanel            m_panel_PSAR;
   CPanel            m_panel_MACD;
   CPanel            m_panel_DMI;
   CPanel            m_panel_MADR;
   CPanel            m_panel_ADX;
   CPanel            m_panel_Ichimoku;
   CPanel            m_panel_RSI;
   CPanel            m_panel_Stoch;
   CPanel            m_panel_MFI;

   CLabel            m_label_MA;
   CLabel            m_label_PSAR;
   CLabel            m_label_MACD;
   CLabel            m_label_DMI;
   CLabel            m_label_MADR;
   CLabel            m_label_ADX;
   CLabel            m_label_Ichimoku;
   CLabel            m_label_RSI;
   CLabel            m_label_Stoch;
   CLabel            m_label_MFI;

   CLabel            m_label_MA_trend_m1;
   CLabel            m_label_MA_trend_m5;
   CLabel            m_label_MA_trend_m15;
   CLabel            m_label_MA_trend_1h;
   CLabel            m_label_MA_trend_4h;
   CLabel            m_label_MA_trend_1d;
   CLabel            m_label_MA_m1;
   CLabel            m_label_MA_m5;
   CLabel            m_label_MA_m15;
   CLabel            m_label_MA_1h;
   CLabel            m_label_MA_4h;
   CLabel            m_label_MA_1d;
   
   CBmpButton        m_bmpbutton_PSAR_trend;
   CBmpButton        m_bmpbutton_MACD_trend;
   CBmpButton        m_bmpbutton_DI_trend;
   CBmpButton        m_bmpbutton_Ichimoku_trend_1;
   CBmpButton        m_bmpbutton_Ichimoku_trend_2;
   CBmpButton        m_bmpbutton_Ichimoku_trend_3;
      
   CLabel            m_label_MADR_trend;
   CLabel            m_label_ADX_trend;   
   CLabel            m_label_RSI_percent;
   CLabel            m_label_RSI_trends[10];
   CLabel            m_label_Stoch_percent;
   CLabel            m_label_Stoch_trends[10];
   CLabel            m_label_MFI_percent;
   CLabel            m_label_MFI_trends[10];

   CButton           m_button_Horizon;
   CButton           m_button_MA;

public:
                     CMovingAverageTrend(void);
                    ~CMovingAverageTrend(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   
   virtual void      Minimize(void) {};
   virtual void      Maximize(void) {};
   
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   virtual bool      Show(void);
   
   void              CalcInfo();
protected:
   //--- create dependent controls
   bool              CreateCLabel(CLabel &obj, string name, string text, string font, int font_size, color font_color, int w, int h, ENUM_ANCHOR_POINT align, int angle = 0);
   bool              CreateCButton(CButton &obj, string name, string text, string font, int font_size, color font_color, color bg_color, color border_color, int w, int h, ENUM_ALIGN_MODE align);
   bool              CreateCEdit(CEdit &obj, string name, string text, string font, int font_size, color font_color, color bg_color, int w, int h, ENUM_ALIGN_MODE align, bool read_only = false);
   bool              CreateCPanel(CPanel &obj, string name, color border_color, int w, int h);
   bool              CreateCBitmap(CBmpButton &obj, string name, int w, int h, ENUM_ANCHOR_POINT anchor, string onBmpName, string offBmpName);

   bool              InitObj(void);
   void              MoveObj(void);
   //--- handlers of the dependent controls events
   //virtual bool      OnDragProcess(const int x,const int y);
   //virtual bool      OnDialogDragStart() {return false;}
   virtual bool      OnDialogDragProcess();
   virtual bool      OnDialogDragEnd();
   void              OnClickPicture(void);
   void              OnClickButton_Horizon(void);
   void              OnClickButton_MA(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CMovingAverageTrend)
//ON_EVENT(ON_CLICK,m_picture,OnClickPicture)
ON_EVENT(ON_CLICK,m_button_Horizon,OnClickButton_Horizon)
ON_EVENT(ON_CLICK,m_button_MA,OnClickButton_MA)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMovingAverageTrend::CMovingAverageTrend(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMovingAverageTrend::~CMovingAverageTrend(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//---
   int controlsTotal = ExtDialog.ControlsTotal();
   for(int i=0; i<controlsTotal; i++)
     {
      CWnd*obj=ExtDialog.Control(i);
      string objName=obj.Name();

      if(StringFind(objName,"Client")>0)
        {
         CWndClient *obj2=(CWndClient*)obj;
         m_window_client = obj2;
        }
      else if(StringFind(objName,"Back")>0)
        {
         CPanel *obj2=(CPanel*)obj;
         m_panel_back = obj2;
        }
      else if(StringFind(objName,"Border")>0)
        {
         CPanel *obj2=(CPanel*)obj;
         m_panel_border = obj2;
        }
      else if(StringFind(objName,"Caption")>0)
        {
         CEdit *obj2=(CEdit*)obj;
         m_label_caption = obj2;
        }
      else if(StringFind(objName,"MinMax")>0)
        {
         CBmpButton *obj2=(CBmpButton*)obj;
         m_button_minmax = obj2;
        }
      else if(StringFind(objName,"Close")>0)
        {
         CBmpButton *obj2=(CBmpButton*)obj;
         m_button_close = obj2;
        }
     }

//--- create dependent controls
   if(!InitObj())
      return(false);

   MoveObj();
   /*if(!CreatePicture())
      return(false);*/
//--- succeed
   return(true);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::Show(void)
{
   CAppDialog::Show();
   
   m_button_minmax.Hide();
   m_button_close.Hide();
   
   for(int i=0;i<10;i++)
     {
      m_label_RSI_trends[i].Hide();
      m_label_Stoch_trends[i].Hide();
      m_label_MFI_trends[i].Hide();
     }
   
   return true;
}  

string GetTrendDescription(int trend)
  {
   string descrStr = "NONE";
   
   if(trend==TREND_UP)
      descrStr="ロング";   
   else if(trend==TREND_DN)
      descrStr="ショート";   
   
   return(descrStr);   
  }
  
string GetTrendDescription_EN(int trend)
  {
   string descrStr = "NONE";
   
   if(trend==TREND_UP)
      descrStr="ロング";   
   else if(trend==TREND_DN)
      descrStr="ショート";   
   
   return(descrStr);   
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMovingAverageTrend::CalcInfo(void)
  {
   m_label_MA_trend_m1.Color(CalcTrendColor_MA(_indHandle_MA_m1));
   m_label_MA_trend_m5.Color(CalcTrendColor_MA(_indHandle_MA_m5));
   m_label_MA_trend_m15.Color(CalcTrendColor_MA(_indHandle_MA_m15));
   m_label_MA_trend_1h.Color(CalcTrendColor_MA(_indHandle_MA_1h));
   m_label_MA_trend_4h.Color(CalcTrendColor_MA(_indHandle_MA_4h));
   m_label_MA_trend_1d.Color(CalcTrendColor_MA(_indHandle_MA_1d));
//---
   int trendPSAR=CalcTrend_PSAR(_indHandle_PSAR);   
   if(trendPSAR==TREND_NONE)
      m_bmpbutton_PSAR_trend.Hide();
   else   
      m_bmpbutton_PSAR_trend.Show();
   m_bmpbutton_PSAR_trend.Pressed(trendPSAR==TREND_UP);
   
   if(_lastTrend_PSAR!=trendPSAR)
     {
      if(InpAlert_PSAR && _lastTrend_PSAR!=NAN)
         Alert("【Parabolic SAR "+GetTrendDescription(trendPSAR)+"】");
        
      _lastTrend_PSAR=trendPSAR;   
     }
     
//---
   int trendMACD=CalcTrend_MACD(_indHandle_MACD);   
   if(trendMACD==TREND_NONE)
      m_bmpbutton_MACD_trend.Hide();
   else   
      m_bmpbutton_MACD_trend.Show();
   m_bmpbutton_MACD_trend.Pressed(trendMACD==TREND_UP);

   if(_lastTrend_MACD!=trendMACD)
     {
      if(InpAlert_MACD && _lastTrend_MACD!=NAN)
         Alert("【MACD "+GetTrendDescription(trendMACD)+"】");
        
      _lastTrend_MACD=trendMACD;   
     }
//---
   int trendDI=CalcTrend_DI(_indHandle_ADX);   
   if(trendDI==TREND_NONE)
      m_bmpbutton_DI_trend.Hide();
   else   
      m_bmpbutton_DI_trend.Show();
   m_bmpbutton_DI_trend.Pressed(trendDI==TREND_UP);   

   if(_lastTrend_DI!=trendDI)
     {
      if(InpAlert_DMI && _lastTrend_DI!=NAN)
         Alert("【DMI "+GetTrendDescription(trendDI)+"】");
        
      _lastTrend_DI=trendDI;   
     }
//---
   double madrVal=CalcIndVal_MADR(_indHandle_MADR);
   if(madrVal==NAN)
     {
      m_label_MADR_trend.Text("NaN");
      m_label_MADR_trend.Color(common_BackgroundColor);
     }
   else
     {
      m_label_MADR_trend.Text(DoubleToString(madrVal,2));
      m_label_MADR_trend.Color(madrVal>=0 ? InpTrendUpColor : InpTrendDnColor);
     }
   
   double reachedLevel=0;
   if((_lastValue_MADR<0.2 && madrVal>=0.2 && ((bool)(reachedLevel=0.2) || true)) ||
      (_lastValue_MADR<0.4 && madrVal>=0.4 && ((bool)(reachedLevel=0.4) || true)) ||
      (_lastValue_MADR<0.6 && madrVal>=0.6 &&  ((bool)(reachedLevel=0.6) || true)) ||
      (_lastValue_MADR>-0.2 && madrVal<=-0.2 && ((bool)(reachedLevel=-0.2) || true)) ||
      (_lastValue_MADR>-0.4 && madrVal<=-0.4 && ((bool)(reachedLevel=-0.4) || true)) ||
      (_lastValue_MADR>-0.6 && madrVal<=-0.6 && ((bool)(reachedLevel=-0.6) || true)))
     {
      if(InpAlert_MADR && _lastValue_MADR!=NAN)
         Alert("【移動平均線乖離率が"+DoubleToString(reachedLevel,1)+"に達しました】");
        
      _lastValue_MADR=madrVal;
     }  
//---
   int trendADX=CalcTrend_ADX(_indHandle_ADX);
   if(trendADX==TREND_UP)
     {
      m_label_ADX_trend.Text("HIGH");
      m_label_ADX_trend.Color(InpTrendUpFontColor);
     }
   else if(trendADX==TREND_DN)
     {
      m_label_ADX_trend.Text("LOW");
      m_label_ADX_trend.Color(InpTrendDnFontColor);
     }
   else
     {
      m_label_ADX_trend.Text("NETURAL");
      m_label_ADX_trend.Color(common_BackgroundColor);
     }
   
   if(_lastTrend_ADX!=trendADX)
     {
      if(InpAlert_Trend && _lastTrend_ADX!=NAN)
         Alert("【TREND - "+GetTrendDescription_EN(trendADX)+" -】");
         
      _lastTrend_ADX=trendADX;
     }
     
//---
   int trendIchimoku=CalcTrend_Ichimoku(_indHandle_Ichimoku);
   if(trendIchimoku==TREND_NONE)
     {
      m_bmpbutton_Ichimoku_trend_1.Hide();
      m_bmpbutton_Ichimoku_trend_2.Hide();
      m_bmpbutton_Ichimoku_trend_3.Hide();
     }
   else   
     {
      m_bmpbutton_Ichimoku_trend_1.Show();
      m_bmpbutton_Ichimoku_trend_2.Show();
      m_bmpbutton_Ichimoku_trend_3.Show();
     }
   m_bmpbutton_Ichimoku_trend_1.Pressed(trendIchimoku==TREND_UP);   
   m_bmpbutton_Ichimoku_trend_2.Pressed(trendIchimoku==TREND_UP);   
   m_bmpbutton_Ichimoku_trend_3.Pressed(trendIchimoku==TREND_UP);   
   
   if(_lastTrend_Ichimoku!=trendIchimoku)
     {
      if(InpAlert_Trend && _lastTrend_Ichimoku!=NAN)
        {
         if(trendIchimoku==TREND_UP)
            Alert("【三役好転が発生しました】");
         else if(trendIchimoku==TREND_DN)    
            Alert("【三役逆転が発生しました】");
        }
        
      _lastTrend_Ichimoku=trendIchimoku;
     }
     
//---
   double indVal=CalcIndVal_Oscillator(_indHandle_RSI);
   int meterLevel=(int)(indVal/10);
   m_label_RSI_percent.Text(DoubleToString(indVal,0));
   for(int i=0; i<10; i++)
     {
      if(i>meterLevel)
         m_label_RSI_trends[i].Hide();
      else
         m_label_RSI_trends[i].Show();
     }
   
   if((_lastValue_RSI<70 && indVal>=70 && ((bool)(reachedLevel=70) || true)) ||
      (_lastValue_RSI<80 && indVal>=80 && ((bool)(reachedLevel=80) || true)) ||
      (_lastValue_RSI>30 && indVal<=30 && ((bool)(reachedLevel=30) || true)) ||
      (_lastValue_RSI>20 && indVal<=20 && ((bool)(reachedLevel=20) || true)))
     {
      if(InpAlert_RSI && _lastValue_RSI!=NAN)
         Alert("【RSIが"+DoubleToString(reachedLevel,0)+"に達しました】");
         
      _lastValue_RSI=indVal;   
     }
//---
   indVal=CalcIndVal_Oscillator(_indHandle_Stoch);
   meterLevel=(int)(indVal/10);
   m_label_Stoch_percent.Text(DoubleToString(indVal,0));
   for(int i=0; i<10; i++)
     {
      if(i>meterLevel)
         m_label_Stoch_trends[i].Hide();
      else
         m_label_Stoch_trends[i].Show();
     }
   
   if((_lastValue_Stoch<70 && indVal>=70 && ((bool)(reachedLevel=70) || true)) ||
      (_lastValue_Stoch<80 && indVal>=80 && ((bool)(reachedLevel=80) || true)) ||
      (_lastValue_Stoch>30 && indVal<=30 && ((bool)(reachedLevel=30) || true)) ||
      (_lastValue_Stoch>20 && indVal<=20 && ((bool)(reachedLevel=20) || true)))
     {
      if(InpAlert_Stoch && _lastValue_Stoch!=NAN)
         Alert("【ストキャスティクスが"+DoubleToString(reachedLevel,0)+"に達しました】");
        
      _lastValue_Stoch=indVal;   
     }
//---
   indVal=CalcIndVal_Oscillator(_indHandle_MFI);
   meterLevel=(int)(indVal/10);
   m_label_MFI_percent.Text(DoubleToString(indVal,0));
   for(int i=0; i<10; i++)
     {
      if(i>meterLevel)
         m_label_MFI_trends[i].Hide();
      else
         m_label_MFI_trends[i].Show();
     }
     
   if((_lastValue_MFI<70 && indVal>=70 && ((bool)(reachedLevel=70) || true)) ||
      (_lastValue_MFI<80 && indVal>=80 && ((bool)(reachedLevel=80) || true)) ||
      (_lastValue_MFI>30 && indVal<=30 && ((bool)(reachedLevel=30) || true)) ||
      (_lastValue_MFI>20 && indVal<=20 && ((bool)(reachedLevel=20) || true)))
     {
      if(InpAlert_MFI && _lastValue_MFI!=NAN)
         Alert("【MFIが"+DoubleToString(reachedLevel,0)+"に達しました】");
        
      _lastValue_MFI=indVal;   
     }  

//---
   if(HRIZON_ONOFF)
      m_button_Horizon.ColorBackground(button_active_ColorBackground);
   else
      m_button_Horizon.ColorBackground(common_BackgroundColor);
      
   if(MA_ONOFF)
     {
      m_button_MA.ColorBackground(button_active_ColorBackground);
      
      if(InpMAOnOff_1==ON)
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
      else
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      if(InpMAOnOff_2==ON)   
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
      else
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);   
      if(InpMAOnOff_3==ON)   
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);  
      else
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
     }
   else
     {
      m_button_MA.ColorBackground(common_BackgroundColor);
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
     }   
//---
   MoveObj();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::CreateCButton(CButton &obj, string name, string text, string font, int font_size, color font_color, color bg_color, color border_color, int w, int h, ENUM_ALIGN_MODE align)
  {
   if(!obj.Create(0,name,0,
                  0,
                  0,
                  w,
                  h
                 ))
      return(false);
   obj.Text(text);
   obj.Font(font);
   obj.FontSize(font_size);
   obj.Color(font_color);
   if(bg_color != 0)
      obj.ColorBackground(bg_color);
   if(border_color != 0)
      obj.ColorBorder(border_color);
// obj.TextAlign(align);
   obj.Locking(false);
   obj.Pressed(false);
   obj.Hide();
// ObjectSetInteger(0,name,OBJPROP_ZORDER,9999999);
   obj.ZOrder(9999);
   if(!ExtDialog.Add(obj))
      return(false);

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::CreateCEdit(CEdit &obj, string name, string text, string font, int font_size, color font_color, color bg_color, int w, int h, ENUM_ALIGN_MODE align, bool read_only)
  {
   if(!obj.Create(0,name,0,
                  0,
                  0,
                  w,
                  h
                 ))
      return(false);
   obj.Text(text);
   obj.Font(font);
   obj.FontSize(font_size);
   obj.Color(font_color);
   if(bg_color != 0)
      obj.ColorBackground(bg_color);
   obj.TextAlign(align);
   obj.ReadOnly(read_only);
   obj.Hide();
   obj.ZOrder(9999);
   if(!ExtDialog.Add(obj))
      return(false);

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::CreateCPanel(CPanel &obj, string name, color border_color, int w, int h)
  {
   if(!obj.Create(0,name,0,
                  0,
                  0,
                  w,
                  h
                 ))
      return(false);
   obj.ColorBorder(border_color);
   obj.Hide();
   obj.ZOrder(9999);
   if(!ExtDialog.Add(obj))
      return(false);

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::CreateCBitmap(CBmpButton &obj,string name,int w,int h, ENUM_ANCHOR_POINT anchor, string onBmpName, string offBmpName)
  {
   if(!obj.Create(0,name,0,
                  0,
                  0,
                  w,
                  h
                 ))
      return(false);
   
   obj.Hide();
   
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   
   obj.BmpNames(offBmpName,onBmpName);
   
   if(!ExtDialog.Add(obj))
      return(false);

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::CreateCLabel(CLabel &obj, string name, string text, string font, int font_size, color font_color, int w, int h, ENUM_ANCHOR_POINT align, int angle)
  {
// Labelは影響を受けるので補正する
//--- 画面に1.5インチの幅のボタンを作成します
   double screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI); // ユーザーのモニターのDPIを取得します
   double base_width = 144;                                     // DPI=96の標準モニターの画面のドットの基本の幅

   if(!obj.Create(0,name,0,
                  0,
                  0,
                  w,
                  h
                 ))
      return(false);

   obj.Text(text);
   obj.Font(font);
   obj.FontSize(font_size);
   obj.Color(font_color);
   obj.ColorBorder(InpTrendDnColor);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,align);
//ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetDouble(0,name,OBJPROP_ANGLE,angle);
   obj.Hide();
   obj.ZOrder(9999);
   if(!ExtDialog.Add(obj))
      return(false);

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMovingAverageTrend::InitObj(void)
  {
//---
   CAPTION_LEFT = m_label_caption.Left()-Left();
   CAPTION_TOP = m_label_caption.Top()-Top();
   
//---
   m_window_client.ColorBackground(mainPanel_BackgroundColor);
   m_window_client.ColorBorder(mainPanel_BackgroundColor);
   m_panel_border.ColorBorder(mainPanel_BackgroundColor);
   m_panel_back.ColorBorder(mainPanel_BackgroundColor);

   m_button_minmax.Hide();
   m_button_close.Hide();

//--- initialize objects
   if(!CreateCPanel(m_panel_Line, "m_panel_Line", common_BorderColor, m_panel_border.Width(), 0))
      return false;
   if(!CreateCPanel(m_panel_PSAR, "m_panel_PSAR", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH))
      return false;
   if(!CreateCPanel(m_panel_MACD, "m_panel_MACD", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH))
      return false;
   if(!CreateCPanel(m_panel_DMI, "m_panel_DMI", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH))
      return false;
   if(!CreateCPanel(m_panel_MADR, "m_panel_MADR", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH))
      return false;
   if(!CreateCPanel(m_panel_ADX, "m_panel_ADX", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH))
      return false;
   if(!CreateCPanel(m_panel_Ichimoku, "m_panel_Ichimoku", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH))
      return false;
   if(!CreateCPanel(m_panel_RSI, "m_panel_RSI", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH_XL))
      return false;
   if(!CreateCPanel(m_panel_Stoch, "m_panel_Stoch", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH_XL))
      return false;
   if(!CreateCPanel(m_panel_MFI, "m_panel_MFI", common_SubPanel_BorderColor, PANEL_WIDTH, PANEL_HEIGTH_XL))
      return false;
   
   if(!CreateCBitmap(m_bmpbutton_PSAR_trend, "m_bmpbutton_PSAR_trend", BMPBUTTON_WIDTH, BMPBUTTON_HEIGHT, ANCHOR_CENTER, "::trendup.bmp", "::trenddn.bmp"))
      return false;
   if(!CreateCBitmap(m_bmpbutton_MACD_trend, "m_bmpbutton_MACD_trend", BMPBUTTON_WIDTH, BMPBUTTON_HEIGHT, ANCHOR_CENTER, "::trendup.bmp", "::trenddn.bmp"))
      return false;
   if(!CreateCBitmap(m_bmpbutton_DI_trend, "m_bmpbutton_DI_trend", BMPBUTTON_WIDTH, BMPBUTTON_HEIGHT, ANCHOR_CENTER, "::trendup.bmp", "::trenddn.bmp"))
      return false;
   if(!CreateCBitmap(m_bmpbutton_Ichimoku_trend_1, "m_bmpbutton_Ichimoku_trend_1", BMPBUTTON_WIDTH, BMPBUTTON_HEIGHT, ANCHOR_CENTER, "::trendup.bmp", "::trenddn.bmp"))
      return false;
   if(!CreateCBitmap(m_bmpbutton_Ichimoku_trend_2, "m_bmpbutton_Ichimoku_trend_2", BMPBUTTON_WIDTH, BMPBUTTON_HEIGHT, ANCHOR_CENTER, "::trendup.bmp", "::trenddn.bmp"))
      return false;
   if(!CreateCBitmap(m_bmpbutton_Ichimoku_trend_3, "m_bmpbutton_Ichimoku_trend_3", BMPBUTTON_WIDTH, BMPBUTTON_HEIGHT, ANCHOR_CENTER, "::trendup.bmp", "::trenddn.bmp"))
      return false;
                  
   if(!CreateCLabel(m_label_MA, "m_label_MA", "MOVING AVERAGE TREND", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_MA_trend_m1, "m_label_MA_trend_m1", "-", percentBar_Font, percentBar_FontSize, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT))
      return false;
   if(!CreateCLabel(m_label_MA_trend_m5, "m_label_MA_trend_m5", "-", percentBar_Font, percentBar_FontSize, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT))
      return false;
   if(!CreateCLabel(m_label_MA_trend_m15, "m_label_MA_trend_m15", "-", percentBar_Font, percentBar_FontSize, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT))
      return false;
   if(!CreateCLabel(m_label_MA_trend_1h, "m_label_MA_trend_1h", "-", percentBar_Font, percentBar_FontSize, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT))
      return false;
   if(!CreateCLabel(m_label_MA_trend_4h, "m_label_MA_trend_4h", "-", percentBar_Font, percentBar_FontSize, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT))
      return false;
   if(!CreateCLabel(m_label_MA_trend_1d, "m_label_MA_trend_1d", "-", percentBar_Font, percentBar_FontSize, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT))
      return false;
   if(!CreateCLabel(m_label_MA_m1, "m_label_MA_m1", "M1", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_MA_m5, "m_label_MA_m5", "M5", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_MA_m15, "m_label_MA_m15", "M15", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_MA_1h, "m_label_MA_1h", "1H", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_MA_4h, "m_label_MA_4h", "4H", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_MA_1d, "m_label_MA_1d", "1D", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_LEFT_UPPER))
      return false;
   if(!CreateCLabel(m_label_PSAR, "m_label_PSAR", "P_SAR", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;   
   if(!CreateCLabel(m_label_MACD, "m_label_MACD", "MACD", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_DMI, "m_label_DMI", "DMI", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;   
   if(!CreateCLabel(m_label_MADR, "m_label_MADR", "MADR", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_MADR_trend, "m_label_MADR_trend", "NaN", common_Font, common_FontSize_XL, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_ADX, "m_label_ADX", "TREND", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_ADX_trend, "m_label_ADX_trend", "NETURAL", common_Font, common_FontSize_XL, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_Ichimoku, "m_label_Ichimoku", "ICHI", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;   
   if(!CreateCLabel(m_label_RSI, "m_label_RSI", "RSI", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_RSI_percent, "m_label_RSI_percent", "NaN", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_CENTER))
      return false;
   for(int i = 0; i < 10; i++)
     {
      if(!CreateCLabel(m_label_RSI_trends[i], "m_label_RSI_trend_"+IntegerToString(i+1), "-", percentBar_Font, percentBar_FontSize, CalcMeterLevelColor(i), LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_LEFT))
         return false;
     }
   if(!CreateCLabel(m_label_Stoch, "m_label_Stoch", "STOCH", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_Stoch_percent, "m_label_Stoch_percent", "NaN", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_CENTER))
      return false;
   for(int i = 0; i < 10; i++)
     {
      if(!CreateCLabel(m_label_Stoch_trends[i], "m_label_Stoch_trend_"+IntegerToString(i+1), "-", percentBar_Font, percentBar_FontSize, CalcMeterLevelColor(i), LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_LEFT))
         return false;
     }
   if(!CreateCLabel(m_label_MFI, "m_label_MFI", "MFI", common_Font, common_FontSize_XL, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_MFI_percent, "m_label_MFI_percent", "NaN", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_CENTER))
      return false;
   for(int i = 0; i < 10; i++)
     {
      if(!CreateCLabel(m_label_MFI_trends[i], "m_label_MFI_trend_"+IntegerToString(i+1), "-", percentBar_Font, percentBar_FontSize, CalcMeterLevelColor(i), LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_LEFT))
         return false;
     }

   if(!CreateCButton(m_button_Horizon, "m_button_Horizon", "水平線", common_Font, common_FontSize, common_FontColor, common_BackgroundColor, C'178,195,207', BUTTON_WIDTH, BUTTON_HEIGHT, ALIGN_CENTER))
      return false;
   if(!CreateCButton(m_button_MA, "m_button_MA", "移動平均線", common_Font, common_FontSize, common_FontColor, common_BackgroundColor, C'178,195,207', BUTTON_WIDTH_XL, BUTTON_HEIGHT, ALIGN_CENTER))
      return false;
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMovingAverageTrend::MoveObj(void)
  {
   int x=Left()+INDENT_LEFT;
   int y=Top()+CONTROLS_GAP_Y;
   m_label_MA.Move(x, y);
   m_label_MA.Show();

   x-=5;
   y+=LABEL_HEIGHT;
   m_label_MA_trend_m1.Move(x, y);
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_trend_m5.Move(x, y);
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_trend_m15.Move(x, y);
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_trend_1h.Move(x, y);
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_trend_4h.Move(x, y);
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_trend_1d.Move(x, y);

   m_label_MA_trend_m1.Show();
   m_label_MA_trend_m5.Show();
   m_label_MA_trend_m15.Show();
   m_label_MA_trend_1h.Show();
   m_label_MA_trend_4h.Show();
   m_label_MA_trend_1d.Show();

   x=m_label_MA.Left()+3;
   y+=LABEL_HEIGHT;
   m_label_MA_m1.Move(x, y);
   m_label_MA_m1.Show();
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_m5.Move(x, y);
   m_label_MA_m5.Show();
   x+=LABEL_WIDTH+CONTROLS_GAP_X-3;
   m_label_MA_m15.Move(x, y);
   m_label_MA_m15.Show();
   x+=LABEL_WIDTH+CONTROLS_GAP_X+3;
   m_label_MA_1h.Move(x, y);
   m_label_MA_1h.Show();
   x+=LABEL_WIDTH+CONTROLS_GAP_X+1;
   m_label_MA_4h.Move(x, y);
   m_label_MA_4h.Show();
   x+=LABEL_WIDTH+CONTROLS_GAP_X;
   m_label_MA_1d.Move(x, y);
   m_label_MA_1d.Show();

//--- line
   x=Left();
   y=m_label_MA_m1.Top()+LABEL_HEIGHT+CONTROLS_GAP_Y;
   m_panel_Line.Move(Left(), y);
   m_panel_Line.Show();

//--- first row
   x=Left()+INDENT_LEFT;
   y=m_panel_Line.Top()+CONTROLS_GAP_Y_XL;
   m_panel_PSAR.Move(x, y);
   m_panel_PSAR.Show();
   m_bmpbutton_PSAR_trend.Move(m_panel_PSAR.Left()+PANEL_WIDTH/2, m_panel_PSAR.Top()+PANEL_HEIGTH/3);
   //m_bmpbutton_PSAR_trend.Show();
   m_label_PSAR.Move(x+PANEL_WIDTH/2, y+CONTROLS_GAP_Y+PANEL_HEIGTH*3/4);
   m_label_PSAR.Show();

   x+=PANEL_WIDTH+CONTROLS_GAP_X_XL;
   m_panel_MACD.Move(x,y);
   m_panel_MACD.Show();
   m_bmpbutton_MACD_trend.Move(m_panel_MACD.Left()+PANEL_WIDTH/2, m_panel_MACD.Top()+PANEL_HEIGTH/3);
   //m_bmpbutton_MACD_trend.Show();
   m_label_MACD.Move(x+PANEL_WIDTH/2, y+CONTROLS_GAP_Y+PANEL_HEIGTH*3/4);
   m_label_MACD.Show();

   x+=PANEL_WIDTH+CONTROLS_GAP_X_XL;
   m_panel_DMI.Move(x,y);
   m_panel_DMI.Show();
   m_bmpbutton_DI_trend.Move(m_panel_DMI.Left()+PANEL_WIDTH/2, m_panel_DMI.Top()+PANEL_HEIGTH/3);
   //m_bmpbutton_DI_trend.Show();
   m_label_DMI.Move(x+PANEL_WIDTH/2, y+CONTROLS_GAP_Y+PANEL_HEIGTH*3/4);
   m_label_DMI.Show();

//---  second row
   x=Left()+INDENT_LEFT;
   y=m_panel_PSAR.Top()+PANEL_HEIGTH+CONTROLS_GAP_Y_XL;
   m_panel_MADR.Move(x, y);
   m_panel_MADR.Show();
   m_label_MADR_trend.Move(m_panel_MADR.Left()+PANEL_WIDTH/2, m_panel_MADR.Top()+PANEL_HEIGTH/3);
   m_label_MADR_trend.Show();
   m_label_MADR.Move(x+PANEL_WIDTH/2, y+CONTROLS_GAP_Y+PANEL_HEIGTH*3/4);
   m_label_MADR.Show();

   x+=PANEL_WIDTH+CONTROLS_GAP_X_XL;
   m_panel_ADX.Move(x,y);
   m_panel_ADX.Show();
   m_label_ADX_trend.Move(m_panel_ADX.Left()+PANEL_WIDTH/2, m_panel_ADX.Top()+PANEL_HEIGTH/3);
   m_label_ADX_trend.Show();
   m_label_ADX.Move(x+PANEL_WIDTH/2, y+CONTROLS_GAP_Y+PANEL_HEIGTH*3/4);
   m_label_ADX.Show();

   x+=PANEL_WIDTH+CONTROLS_GAP_X_XL;
   m_panel_Ichimoku.Move(x,y);
   m_panel_Ichimoku.Show();
   m_bmpbutton_Ichimoku_trend_1.Move(m_panel_Ichimoku.Left()+PANEL_WIDTH/2-21, m_panel_Ichimoku.Top()+PANEL_HEIGTH/3);
   m_bmpbutton_Ichimoku_trend_2.Move(m_panel_Ichimoku.Left()+PANEL_WIDTH/2-5+CONTROLS_GAP_X, m_panel_Ichimoku.Top()+PANEL_HEIGTH/3);
   m_bmpbutton_Ichimoku_trend_3.Move(m_panel_Ichimoku.Left()+PANEL_WIDTH/2+11+CONTROLS_GAP_X*2, m_panel_Ichimoku.Top()+PANEL_HEIGTH/3);
   m_label_Ichimoku.Move(x+PANEL_WIDTH/2, y+CONTROLS_GAP_Y+PANEL_HEIGTH*3/4);
   m_label_Ichimoku.Show();

//--- third row
   x=Left()+INDENT_LEFT;
   y=m_panel_MADR.Top()+PANEL_HEIGTH+CONTROLS_GAP_Y_XL;
   m_panel_RSI.Move(x, y);
   m_panel_RSI.Show();
   x=m_panel_RSI.Left()+PANEL_WIDTH/2-17;
   y=m_panel_RSI.Top();
   for(int i=9; i>=0; i--)
     {
      m_label_RSI_trends[i].Move(x, y);
      //m_label_RSI_trends[i].Show();
      y+=LABEL_HEIGHT_XS+1;
     }
   x=m_panel_RSI.Left();
   y=m_panel_RSI.Top();
   m_label_RSI_percent.Move(x+PANEL_WIDTH/2, y+PANEL_HEIGTH_XL*10/12-3);
   m_label_RSI_percent.Show();
   m_label_RSI.Move(x+PANEL_WIDTH/2, y+PANEL_HEIGTH_XL*11/12);
   m_label_RSI.Show();

   x=Left()+INDENT_LEFT;
   y=m_panel_MADR.Top()+PANEL_HEIGTH+CONTROLS_GAP_Y_XL;
   x+=PANEL_WIDTH+CONTROLS_GAP_X_XL;
   m_panel_Stoch.Move(x,y);
   m_panel_Stoch.Show();
   x=m_panel_Stoch.Left()+PANEL_WIDTH/2-17;
   y=m_panel_Stoch.Top();
   for(int i=9; i>=0; i--)
     {
      m_label_Stoch_trends[i].Move(x, y);
      //m_label_Stoch_trends[i].Show();
      y+=LABEL_HEIGHT_XS+1;
     }
   x=m_panel_Stoch.Left();
   y=m_panel_Stoch.Top();
   m_label_Stoch_percent.Move(x+PANEL_WIDTH/2, y+PANEL_HEIGTH_XL*10/12-3);
   m_label_Stoch_percent.Show();
   m_label_Stoch.Move(x+PANEL_WIDTH/2, y+PANEL_HEIGTH_XL*11/12);
   m_label_Stoch.Show();

   x=Left()+INDENT_LEFT;
   y=m_panel_MADR.Top()+PANEL_HEIGTH+CONTROLS_GAP_Y_XL;
   x+=2*(PANEL_WIDTH+CONTROLS_GAP_X_XL);
   m_panel_MFI.Move(x,y);
   m_panel_MFI.Show();
   x=m_panel_MFI.Left()+PANEL_WIDTH/2-17;
   y=m_panel_MFI.Top();
   for(int i=9; i>=0; i--)
     {
      m_label_MFI_trends[i].Move(x, y);
      //m_label_MFI_trends[i].Show();
      y+=LABEL_HEIGHT_XS+1;
     }
   x=m_panel_MFI.Left();
   y=m_panel_MFI.Top();
   m_label_MFI_percent.Move(x+PANEL_WIDTH/2, y+PANEL_HEIGTH_XL*10/12-3);
   m_label_MFI_percent.Show();
   m_label_MFI.Move(x+PANEL_WIDTH/2, y+PANEL_HEIGTH_XL*11/12);
   m_label_MFI.Show();

//--- fourth row
   x=Right()-INDENT_RIGHT-BUTTON_WIDTH_XL;
   y=m_panel_RSI.Top()+PANEL_HEIGTH_XL+CONTROLS_GAP_Y*2;
   m_button_MA.Move(x, y);
   m_button_MA.Show();
   x-=BUTTON_WIDTH+CONTROLS_GAP_X;
   m_button_Horizon.Move(x, y);
   m_button_Horizon.Show();
   
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Handler of control dragging process                              |
//+------------------------------------------------------------------+
/*bool CMovingAverageTrend::OnDragProcess(const int x,const int y)
  {
   int dx=x-m_mouse_x;
   int dy=y-m_mouse_y;
//--- check shift
   if(Right()+dx>m_limit_right)
      dx=m_limit_right-Right();
   if(Left()+dx<m_limit_left)
      dx=m_limit_left-Left();
   if(Bottom()+dy>m_limit_bottom)
      dy=m_limit_bottom-Bottom();
   if(Top()+dy<m_limit_top)
      dy=m_limit_top-Top();
//--- shift
   Shift(dx,dy);
//--- save
   m_mouse_x=x;
   m_mouse_y=y;
//--- generate event
   EventChartCustom(CONTROLS_SELF_MESSAGE,ON_DRAG_PROCESS,m_id,0.0,m_name);
//--- handled
   return(true);
  }*/
bool CMovingAverageTrend::OnDialogDragProcess(void)
  {
   CAppDialog::OnDialogDragProcess();
   
   m_label_caption.Move(Left()+CAPTION_LEFT,Top()+CAPTION_TOP);

//--- succeed   
   return(true);
  }
  
bool CMovingAverageTrend::OnDialogDragEnd(void)
  {
   CAppDialog::OnDialogDragEnd();
   
   m_label_caption.Move(Left()+CAPTION_LEFT,Top()+CAPTION_TOP);
   
   if(GlobalVariableSet(GV_MAT_DIALOG_AXISX,Left())==0 ||
      GlobalVariableSet(GV_MAT_DIALOG_AXISY,Top())==0)
     {
      Print("ERROR: GlobalVariableSet failed! DIALOG_AXES");
     }   

//--- succeed
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CMovingAverageTrend::OnClickPicture(void)
  {
   Comment(__FUNCTION__);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMovingAverageTrend::OnClickButton_Horizon(void)
  {
   HRIZON_ONOFF=HRIZON_ONOFF?false:true;
   hrzResetFlg=true;
   
   if(GlobalVariableSet(GV_MAT_DIALOG_HZLINE_VISIBLE, HRIZON_ONOFF)==0)
     {
      Print("ERROR: GlobalVariableSet failed! HRIZON_ONOFF");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMovingAverageTrend::OnClickButton_MA(void)
  {
   MA_ONOFF=MA_ONOFF?false:true;
   
   if(GlobalVariableSet(GV_MAT_DIALOG_MA_VISIBLE, MA_ONOFF)==0)
     {
      Print("ERROR: GlobalVariableSet failed! MA_ONOFF");
     }
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////

CMovingAverageTrend ExtDialog;

int _indHandle_MA_m1;
int _indHandle_MA_m5;
int _indHandle_MA_m15;
int _indHandle_MA_1h;
int _indHandle_MA_4h;
int _indHandle_MA_1d;

int _indHandle_PSAR;
int _indHandle_MACD;
int _indHandle_ADX;
int _indHandle_MADR;
int _indHandle_Ichimoku;
int _indHandle_RSI;
int _indHandle_Stoch;
int _indHandle_MFI;

int      _lastTrend_PSAR=NAN;
int      _lastTrend_MACD=NAN;
int      _lastTrend_ADX=NAN;
int      _lastTrend_DI=NAN;
int      _lastTrend_Ichimoku=NAN;

double   _lastValue_MADR=NAN;
double   _lastValue_RSI=NAN;
double   _lastValue_Stoch=NAN;
double   _lastValue_MFI=NAN;

//---
color    Horizon_LONG_COLOR         = C'124,181,62';
color    Horizon_SHORT_COLOR        = C'204,61,69';

bool     Hrizon_Back                = false;
bool     HRIZON_ONOFF               = false;

bool     hrzResetFlg                = false;  

int HrizonPHBuffer[], HrizonPLBuffer[], HrizonQPHBuffer[], HrizonQPLBuffer[];

bool     MA_ONOFF                   = false;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

int   _indHandle_IndMA_1;
int   _indHandle_IndMA_2;
int   _indHandle_IndMA_3;

int    _bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- assignment of array to indicator buffer 
   SetIndexBuffer(0,ExtMapBuffer1); 
   SetIndexBuffer(1,ExtMapBuffer2); 
   SetIndexBuffer(2,ExtMapBuffer3); 
   
   if(GlobalVariableCheck(GV_MAT_DIALOG_MA_VISIBLE))
      MA_ONOFF=GlobalVariableGet(GV_MAT_DIALOG_MA_VISIBLE);
   if(GlobalVariableCheck(GV_MAT_DIALOG_HZLINE_VISIBLE))
     {
      HRIZON_ONOFF=GlobalVariableGet(GV_MAT_DIALOG_HZLINE_VISIBLE);
      hrzResetFlg=true;
     }
         
   if(MA_ONOFF)
     {
      if(InpMAOnOff_1==ON)
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
      else
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      if(InpMAOnOff_2==ON)   
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
      else
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);   
      if(InpMAOnOff_3==ON)   
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);  
      else
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);   
     }
   else
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
     }  
   
   _indHandle_IndMA_1=iMA(NULL,0,InpMAPeriod_1,0,InpMAMethod_1,PRICE_CLOSE);
   _indHandle_IndMA_2=iMA(NULL,0,InpMAPeriod_2,0,InpMAMethod_2,PRICE_CLOSE);
   _indHandle_IndMA_3=iMA(NULL,0,InpMAPeriod_3,0,InpMAMethod_3,PRICE_CLOSE);
   
   if(_indHandle_IndMA_1==INVALID_HANDLE ||
      _indHandle_IndMA_2==INVALID_HANDLE ||
      _indHandle_IndMA_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the indicator for the symbol %s, error code %d",
                  Symbol(),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//--- create indicator handle
   _indHandle_MA_m1=iMA(NULL,PERIOD_M1,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   _indHandle_MA_m5=iMA(NULL,PERIOD_M5,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   _indHandle_MA_m15=iMA(NULL,PERIOD_M15,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   _indHandle_MA_1h=iMA(NULL,PERIOD_H1,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   _indHandle_MA_4h=iMA(NULL,PERIOD_H4,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   _indHandle_MA_1d=iMA(NULL,PERIOD_D1,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   
   _indHandle_PSAR=iSAR(NULL,0,0.02,0.2);
   _indHandle_MACD=iMACD(NULL,0,12,26,9,PRICE_CLOSE);
   _indHandle_ADX=iADX(NULL,0,14);
   _indHandle_MADR=iMA(NULL,0,InpDiaolog_MADRPeriod,InpDiaolog_MADRMethod,MODE_SMA,PRICE_CLOSE);
   _indHandle_Ichimoku=iIchimoku(NULL,0,9,26,52);
   _indHandle_RSI=iRSI(NULL,0,14,PRICE_CLOSE);
   _indHandle_Stoch=iStochastic(NULL,0,5,3,3,MODE_SMA,STO_LOWHIGH);
   _indHandle_MFI=iMFI(NULL,0,14,VOLUME_TICK);

   if(_indHandle_MA_m1==INVALID_HANDLE || _indHandle_MA_m5==INVALID_HANDLE || _indHandle_MA_m15==INVALID_HANDLE ||
      _indHandle_MA_1h==INVALID_HANDLE || _indHandle_MA_4h==INVALID_HANDLE || _indHandle_MA_1d==INVALID_HANDLE ||
      _indHandle_MADR==INVALID_HANDLE ||
      _indHandle_PSAR==INVALID_HANDLE ||
      _indHandle_MACD==INVALID_HANDLE ||
      _indHandle_ADX==INVALID_HANDLE ||
      _indHandle_Ichimoku==INVALID_HANDLE ||
      _indHandle_RSI==INVALID_HANDLE ||
      _indHandle_Stoch==INVALID_HANDLE ||
      _indHandle_MFI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the indicator for the symbol %s, error code %d",
                  Symbol(),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
        
//--- create application dialog
   int dialogAxisX=-1, dialogAxisY=-1;
   if(GlobalVariableCheck(GV_MAT_DIALOG_AXISX) &&
      GlobalVariableCheck(GV_MAT_DIALOG_AXISY))
     {
      dialogAxisX=(int)GlobalVariableGet(GV_MAT_DIALOG_AXISX);
      dialogAxisY=(int)GlobalVariableGet(GV_MAT_DIALOG_AXISY);
     }
   
   int chartWidth = (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   int axisX = (dialogAxisX == -1 || dialogAxisX+DIALOG_WIDTH>chartWidth) ? 0 : dialogAxisX;
   int axisY = (dialogAxisY == -1 || dialogAxisY+DIALOG_HEIGHT>chartHeight) ? MathMax(0,chartHeight-DIALOG_HEIGHT) : dialogAxisY;
   
   if(!ExtDialog.Create(0,"",0,axisX,axisY,axisX+DIALOG_WIDTH,axisY+DIALOG_HEIGHT))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();

//---
   EventSetMillisecondTimer(50);

//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy dialog
   ExtDialog.Destroy(reason);   
   
   if(reason!=REASON_CHARTCHANGE)
     {
      GlobalVariableDel(GV_MAT_DIALOG_AXISX);
      GlobalVariableDel(GV_MAT_DIALOG_AXISY);
      GlobalVariableDel(GV_MAT_DIALOG_MA_VISIBLE);
      GlobalVariableDel(GV_MAT_DIALOG_HZLINE_VISIBLE);
     }
//---
   IndicatorRelease(_indHandle_IndMA_1);  
   IndicatorRelease(_indHandle_IndMA_2);
   IndicatorRelease(_indHandle_IndMA_3);
//---
   IndicatorRelease(_indHandle_MA_m1);
   IndicatorRelease(_indHandle_MA_m5);
   IndicatorRelease(_indHandle_MA_m15);
   IndicatorRelease(_indHandle_MA_1h);
   IndicatorRelease(_indHandle_MA_4h);
   IndicatorRelease(_indHandle_MA_1d);
   IndicatorRelease(_indHandle_MADR);
   IndicatorRelease(_indHandle_PSAR);
   IndicatorRelease(_indHandle_MACD);
   IndicatorRelease(_indHandle_ADX);
   IndicatorRelease(_indHandle_Ichimoku);
   IndicatorRelease(_indHandle_RSI);
   IndicatorRelease(_indHandle_Stoch);
   IndicatorRelease(_indHandle_MFI);
//--- clear comments
   ObjectsDeleteAll(0,"SHiNiNG_Horizon");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- number of values copied from the iMA indicator 
   int values_to_copy; 
//--- determine the number of values calculated in the indicator 
   int calculated=MathMin(BarsCalculated(_indHandle_IndMA_1), MathMin(BarsCalculated(_indHandle_IndMA_2), BarsCalculated(_indHandle_IndMA_3))); 
   if(calculated<=0) 
     { 
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError()); 
      return(0); 
     } 
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=_bars_calculated || rates_total>prev_calculated+1) 
     { 
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total) values_to_copy=rates_total; 
      else                       values_to_copy=calculated; 
     } 
   else 
     { 
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1; 
     } 
//--- fill the iMABuffer array with values of the Moving Average indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(ExtMapBuffer1,0,_indHandle_IndMA_1,values_to_copy)) return(0);    
   if(!FillArrayFromBuffer(ExtMapBuffer2,0,_indHandle_IndMA_2,values_to_copy)) return(0);
   if(!FillArrayFromBuffer(ExtMapBuffer3,0,_indHandle_IndMA_3,values_to_copy)) return(0);
   
   _bars_calculated=calculated;
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the MA indicator                  | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values 
                         int shift,          // shift 
                         int ind_handle,     // handle of the iMA indicator 
                         int amount          // number of copied values 
                         ) 
  { 
//--- reset error code 
   ResetLastError(); 
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
//--- everything is fine 
   return(true); 
  } 
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   //---
   InitHorizonLine();
   CalcHorizon();   
   ChkHLineLabel();
   
   //---
   ExtDialog.CalcInfo();
  }
//+------------------------------------------------------------------+
//| Custom indicator chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   if(id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, "m_label") != -1)
     {
      //if (!dialogMminimized)
        {
         ExtDialog.Hide();         
         ExtDialog.Show();
        }
     }
   
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color CalcTrendColor_MA(int indHandle_MA)
  {
   color clr = common_BackgroundColor;

   double curPrice=iClose(NULL,0,0);
   double indVal[1];
   
   ResetLastError();
   if(CopyBuffer(indHandle_MA,0,0,1,indVal)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(clr);
     }
   
   if(curPrice>indVal[0])
     {
      clr=InpTrendUpColor;
     }
   else if(curPrice<indVal[0])
     {
      clr=InpTrendDnColor;
     }
   return(clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalcTrend_PSAR(int indHandle_PSAR)
  {
   double indVal[1];

   ResetLastError();
   if(CopyBuffer(indHandle_PSAR,0,0,1,indVal)!=1)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }
   
   double curPrice=iClose(_Symbol,0,0);
   int trend=TREND_NONE;
   
   if(curPrice>indVal[0])
     {
      trend=TREND_UP;
     }
   else if(curPrice<indVal[0])
     {
      trend=TREND_DN;
     }
     
   return(trend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalcTrend_MACD(int indHandle_MACD)
  {
   double macd[1], signal[1];

   ResetLastError();
   if(CopyBuffer(indHandle_MACD,0,0,1,macd)<0 ||
      CopyBuffer(indHandle_MACD,1,0,1,signal)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }

   int trend=TREND_NONE;
   if(macd[0]>signal[0])
     {
      trend=TREND_UP;
     }
   else if(macd[0]<signal[0])
     {
      trend=TREND_DN;
     } 
     
   return(trend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalcTrend_DI(int indHandle_ADX)
  {
   double plusDMI[1], minusDMI[1];

   ResetLastError();
   if(CopyBuffer(indHandle_ADX,1,0,1,plusDMI)<0 ||
      CopyBuffer(indHandle_ADX,2,0,1,minusDMI)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }

   int trend=TREND_NONE;
   if(plusDMI[0]>minusDMI[0])
     {
      trend=TREND_UP;
     }
   else if(plusDMI[0]<minusDMI[0])
     {
      trend=TREND_DN;
     }
   
   return(trend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalcTrend_ADX(int indHandle_ADX)
  {
   double adx[1];

   ResetLastError();
   if(CopyBuffer(indHandle_ADX,0,0,1,adx)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }

   int trend=TREND_NONE;

   if(adx[0]>25)
     {
      trend=TREND_UP;
     }
   else if(adx[0]<25)
     {
      trend=TREND_DN;
     }
     
   return(trend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalcTrend_Ichimoku(int indHandle_Ichimoku)
  {
   double spanA[1], spanB[1];
   
   ResetLastError();
   if(CopyBuffer(indHandle_Ichimoku,2,0,1,spanA)<0 ||
      CopyBuffer(indHandle_Ichimoku,3,0,1,spanB)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iIchimoku indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }
   
   int trend=TREND_NONE;
   if(iLow(NULL,0,0)>spanA[0] && spanA[0]>spanB[0])
     {
      trend=TREND_UP;
     }
   else if(iHigh(NULL,0,0)<spanA[0] && spanA[0]<spanB[0])
     {
      trend=TREND_DN;
     }
   else
     {
      trend=TREND_NONE;
     }  
     
   return(trend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcIndVal_MADR(int indHandle_MA)
  {
   double curPrice=iClose(NULL,0,0);
   double indVal[1];

   ResetLastError();
   if(CopyBuffer(indHandle_MA,0,0,1,indVal)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(NAN);
     }

   if(curPrice==0)
      return(NAN);
   
   return((curPrice-indVal[0])/curPrice*100);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcIndVal_Oscillator(int indHandle)
  {
   double indVal[1];

   ResetLastError();
   if(CopyBuffer(indHandle,0,0,1,indVal)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iInd indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(0);
     }

   return(indVal[0]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color CalcMeterLevelColor(int level)
  {
   color clr=common_BackgroundColor;

   switch(level)
     {
      case 0:
         clr=clrRed;
         break;
      case 1:
         clr=clrOrangeRed;
         break;
      case 2:
         clr=clrDarkOrange;
         break;
      case 3:
         clr=clrOrange;
         break;
      case 4:
         clr=clrGold;
         break;
      case 5:
         clr=clrYellow;
         break;
      case 6:
         clr=clrGreenYellow;
         break;
      case 7:
         clr=clrLawnGreen;
         break;
      case 8:
         clr=clrLime;
         break;
      case 9:
         clr=clrLime;
         break;
      default:
         break;
     }

   return(clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetHLineLabel(string name)
  {
   color clr;
   double price;
   int x, y;
   if(ObjectFind(0, name)>=0)
     {
      if(ObjectGetInteger(0, name, OBJPROP_TIMEFRAMES, 0)==OBJ_NO_PERIODS)
        {
         return(true);
        }
      price = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
      clr = (color)ObjectGetInteger(0, name, OBJPROP_COLOR, 0);
      ChartTimePriceToXY(
         0,    // チャート識別子
         0,   // サブウィンドウ番号
         TimeCurrent(),         // チャートの時間
         price,       // チャートの価格
         x,           // X 座標は時間
         y           // Y 座標は価格
      );
      int w=60, h=18;
      x=w;
      y-=h;
      if(ObjectFind(0, name+"_label")<0)
        {
         // 水平線ラベルがなければ作成する
         if(!CreateBUttonLabelHrizon(name+"_label", clr, price, x, y, w, h))
           {
            return(false);
           }
        }
      // 水平線ラベルの価格を変更する
      ObjectSetInteger(0, name+"_label",   OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0, name+"_label",   OBJPROP_YDISTANCE,y);
      ObjectSetString(0, name+"_label",   OBJPROP_TEXT, DoubleToString(price, _Digits));
      // 水平線ラベルの表示状態に変更する
      ObjectSetInteger(0, name+"_label",     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
      ObjectSetInteger(0, name+"_label",     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
      //--- 背景色を設定する
      ObjectSetInteger(0,name+"_label",OBJPROP_BGCOLOR,clr);
      //--- 境界線の色を設定する
      ObjectSetInteger(0,name+"_label",OBJPROP_BORDER_COLOR,clr);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChkHLineLabel()
  {
   int QPH_cnt=0, QPL_cnt=0, PH_cnt=0, PL_cnt=0;
   string name;
   if(Hrizon_Back)
     {
      for(int i=QPH_cnt; i<=0; i++)
        {
         name = "SHiNiNG_Horizon_QPH_"+IntegerToString(i);
         SetHLineLabel(name);
        }
      for(int i=QPL_cnt; i<=0; i++)
        {
         name = "SHiNiNG_Horizon_QPL_"+IntegerToString(i);
         SetHLineLabel(name);
        }
      for(int i=PH_cnt; i<=2; i++)
        {
         name = "SHiNiNG_Horizon_PH_"+IntegerToString(i);
         SetHLineLabel(name);
        }
      for(int i=PL_cnt; i<=2; i++)
        {
         name = "SHiNiNG_Horizon_PL_"+IntegerToString(i);
         SetHLineLabel(name);
        }
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateHLine(string name, color clr, double price, datetime time)
  {
// Print("CreateHLine: ", name, " ", clr, " ", price);
// 水平線が既に存在するか確認
   if(ObjectFind(0, name)<0)
     {
      // 水平線がなければ作成する
      if(!ObjectCreate(0,name,OBJ_HLINE,0,0,price))
        {
         return(false);
        }
      ObjectSetInteger(0, name,   OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0, name,   OBJPROP_WIDTH,1);
      ObjectSetInteger(0, name,   OBJPROP_BACK,Hrizon_Back);
      ObjectSetInteger(0, name,   OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, name,   OBJPROP_SELECTED,false);
      ObjectSetInteger(0, name,   OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0, name,   OBJPROP_COLOR,clr);
// 水平線の価格を変更する
   ObjectSetDouble(0, name,   OBJPROP_PRICE,price);
// 水平線の表示状態に変更する
   ObjectSetInteger(0, name,     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, name,     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);

   if(Hrizon_Back)
     {
      int x, y;
      ChartTimePriceToXY(
         0,    // チャート識別子
         0,   // サブウィンドウ番号
         time,         // チャートの時間
         price,       // チャートの価格
         x,           // X 座標は時間
         y           // Y 座標は価格
      );
      int w=60, h=18;
      x=w;
      y-=h;
      if(ObjectFind(0, name+"_label")<0)
        {
         // 水平線ラベルがなければ作成する
         if(!CreateBUttonLabelHrizon(name+"_label", clr, price, x, y, w, h))
           {
            return(false);
           }
        }
      // 水平線ラベルの価格を変更する
      ObjectSetInteger(0, name+"_label",   OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0, name+"_label",   OBJPROP_YDISTANCE,y);
      ObjectSetString(0, name+"_label",   OBJPROP_TEXT, DoubleToString(price, _Digits));
      // 水平線ラベルの表示状態に変更する
      ObjectSetInteger(0, name+"_label",     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
      ObjectSetInteger(0, name+"_label",     OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
      //--- 背景色を設定する
      ObjectSetInteger(0,name+"_label",OBJPROP_BGCOLOR,clr);
      //--- 境界線の色を設定する
      ObjectSetInteger(0,name+"_label",OBJPROP_BORDER_COLOR,clr);
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DisableHLine(string name)
  {
// Print("DisableHLine: ", name);
// 水平線が既に存在するか確認
   if(ObjectFind(0, name)>=0)
     {
      // 水平線を非表示にする
      // ObjectSetInteger(0, name,     OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      // ObjectSetInteger(0, name,     OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      ObjectSetDouble(0, name,   OBJPROP_PRICE,0);
     }
   if(ObjectFind(0, name+"_label")>=0)
     {
      // 水平線を非表示にする
      // ObjectSetInteger(0, name+"_label",     OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      // ObjectSetInteger(0, name+"_label",     OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      int x, y;
      ChartTimePriceToXY(
         0,    // チャート識別子
         0,   // サブウィンドウ番号
         TimeCurrent(),         // チャートの時間
         0,       // チャートの価格
         x,           // X 座標は時間
         y           // Y 座標は価格
      );
      int w=60, h=18;
      x=w;
      y-=h;
      ObjectSetInteger(0, name+"_label",   OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0, name+"_label",   OBJPROP_YDISTANCE,y);
      ObjectSetString(0, name+"_label",   OBJPROP_TEXT, DoubleToString(0, _Digits));
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateBUttonLabelHrizon(string name, color clr, double price, int x, int y, int w, int h)
  {
// Print("CreateBUttonLabel: ", name, " ", clr, " ", text, " ", x, " ", y);
//--- 画面に1.5インチの幅のボタンを作成します
   double screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI); // ユーザーのモニターのDPIを取得します
   double base_width = 144;                                     // DPI=96の標準モニターの画面のドットの基本の幅
   double oringin_ratio      = 96 / screen_dpi;         // ユーザーモニター（DPIを含む）のボタンの幅を計算します
// 水平線が既に存在するか確認
   if(ObjectFind(0, name)<0)
     {
      // 水平線がなければ作成する
      if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
        {
         return(false);
        }
      //--- ボタン座標を設定する
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      //--- ボタンサイズを設定する
      ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      //--- ポイント座標が相対的に定義されているチャートのコーナーを設定
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      //--- テキストを設定する
      ObjectSetString(0,name,OBJPROP_TEXT,DoubleToString(price, _Digits));
      // //--- テキストフォントを設定する
      // ObjectSetString(0,name,OBJPROP_FONT,TC_MAP_FONT);
      //--- フォントサイズを設定する
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)(11*oringin_ratio));
      //--- テキストの色を設定する
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
      //--- 背景色を設定する
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clr);
      //--- 境界線の色を設定する
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clr);
      //--- 前景（false）または背景（true）に表示
      ObjectSetInteger(0,name,OBJPROP_BACK,Hrizon_Back);
      //--- ボタンの状態を設定する
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
      //--- マウスでのボタンを移動させるモードを有効（true）か無効（false）にする
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      //--- オブジェクトリストのグラフィックオブジェクトを非表示（true）か表示（false）にする
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitHorizonLine()
  {
   //--- 水平線を作成して隠しておく
   if(HRIZON_ONOFF)
     {
      double price=iClose(_Symbol, _Period, 0);
      datetime time=TimeCurrent();
      for(int i=0; i<=0; i++)
        {
         CreateHLine("SHiNiNG_Horizon_QPH_"+IntegerToString(i), Horizon_LONG_COLOR, price, time);
         DisableHLine("SHiNiNG_Horizon_QPH_"+IntegerToString(i));
        }
      for(int i=0; i<=0; i++)
        {
         CreateHLine("SHiNiNG_Horizon_QPL_"+IntegerToString(i), Horizon_LONG_COLOR, price, time);
         DisableHLine("SHiNiNG_Horizon_QPL_"+IntegerToString(i));
        }
      for(int i=0; i<=2; i++)
        {
         CreateHLine("SHiNiNG_Horizon_PH_"+IntegerToString(i), Horizon_LONG_COLOR, price, time);
         DisableHLine("SHiNiNG_Horizon_PH_"+IntegerToString(i));
        }
      for(int i=0; i<=2; i++)
        {
         CreateHLine("SHiNiNG_Horizon_PL_"+IntegerToString(i), Horizon_LONG_COLOR, price, time);
         DisableHLine("SHiNiNG_Horizon_PL_"+IntegerToString(i));
        }
     }
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalcHorizon()
  {
   // 水平線
   int QPH_cnt=0, QPL_cnt=0, PH_cnt=0, PL_cnt=0;
   if(HRIZON_ONOFF)
     {
      int rates_total=Bars(NULL,0);
      int prev_calculated=_bars_calculated;
      
      double close[];         
      datetime time[];      
      if(CopyClose(NULL,0,0,rates_total,close)!=rates_total ||
         CopyTime(NULL,0,0,rates_total,time)!=rates_total)
        {
         return;
        }
        
      int start=1;
   
      // 無駄な再計算を行わない
      if(prev_calculated>0) start = prev_calculated-1;
      if(hrzResetFlg)
        {
         start=1;
         hrzResetFlg=false;
        }
        
        
      // Print(close[0], close[rates_total-1]);
      // 初回の計算
      int left = 50;
      int right = 25;
      int speedright = 5;
      int h,l;
      int shift;

      ArrayResize(HrizonQPHBuffer,rates_total);
      ArrayResize(HrizonQPLBuffer,rates_total);
      ArrayResize(HrizonPHBuffer,rates_total);
      ArrayResize(HrizonPLBuffer,rates_total);
      for(int i=start; i<ArraySize(HrizonQPHBuffer); i++)
        {
         HrizonQPHBuffer[i] = NULL;
         HrizonQPLBuffer[i] = NULL;
         HrizonPHBuffer[i] = NULL;
         HrizonPLBuffer[i] = NULL;
        }

      // Print("test01: ", start, " ", prev_calculated, " ", rates_total);

      for(int i=start; i<rates_total && !IsStopped(); i++)
        {
         if(i-left-right<0)
           {
            HrizonQPHBuffer[i] = NULL;
            HrizonQPLBuffer[i] = NULL;
            HrizonPHBuffer[i] = NULL;
            HrizonPLBuffer[i] = NULL;
            continue;
           }
         shift = rates_total-1-i;
         // speed判定
         h = iHighest(_Symbol, _Period, MODE_CLOSE, speedright+left, shift);
         l = iLowest(_Symbol, _Period, MODE_CLOSE, speedright+left, shift);
         // if(shift < 100)
         //   Print("test02: ", shift, " ", speedright+left, " ", h, " ", l);
         if(h==-1 || l==-1)
           {
            HrizonQPHBuffer[i] = NULL;
            HrizonQPLBuffer[i] = NULL;
            continue;
           }
         if(h==shift+speedright)
           {
            HrizonQPHBuffer[i] = rates_total-1-h;
           }
         if(l==shift+speedright)
           {
            HrizonQPLBuffer[i] = rates_total-1-l;
           }

         // 通常判定
         h = iHighest(_Symbol, _Period, MODE_CLOSE, right+left, shift);
         l = iLowest(_Symbol, _Period, MODE_CLOSE, right+left, shift);
         if(h==-1 || l==-1)
           {
            HrizonPHBuffer[i] = NULL;
            HrizonPLBuffer[i] = NULL;
            continue;
           }
         if(h==shift+right)
           {
            HrizonPHBuffer[i] = rates_total-1-h;
           }
         if(l==shift+right)
           {
            HrizonPLBuffer[i] = rates_total-1-l;
           }
        }

      // 水平線の作成
      for(int i=rates_total-1; i>=0; i--)
        {
         if(QPH_cnt==0)
           {
            if(HrizonQPHBuffer[i] != NULL)
              {
               double price = close[HrizonQPHBuffer[i]];
               color clr = Horizon_LONG_COLOR;
               if(price > close[rates_total-1])
                  clr = Horizon_SHORT_COLOR;
               CreateHLine("SHiNiNG_Horizon_QPH_"+IntegerToString(QPH_cnt), clr, price, time[rates_total-1]);
               // Print("CreateHLine: ", "Horizon_QPH_"+IntegerToString(QPH_cnt), " ", clr, " ", price, " ", HrizonQPHBuffer[i]);
               QPH_cnt++;
              }
           }
         if(QPL_cnt==0)
           {
            if(HrizonQPLBuffer[i] != NULL)
              {
               double price = close[HrizonQPLBuffer[i]];
               color clr = Horizon_LONG_COLOR;
               if(price > close[rates_total-1])
                  clr = Horizon_SHORT_COLOR;
               CreateHLine("SHiNiNG_Horizon_QPL_"+IntegerToString(QPL_cnt), clr, price, time[rates_total-1]);
               // Print("CreateHLine: ", "Horizon_QPL_"+IntegerToString(QPH_cnt), " ", clr, " ", price, " ", HrizonQPLBuffer[i]);
               QPL_cnt++;
              }
           }
         if(PH_cnt<=2)
           {
            if(HrizonPHBuffer[i] != NULL)
              {
               double price = close[HrizonPHBuffer[i]];
               color clr = Horizon_LONG_COLOR;
               if(price > close[rates_total-1])
                  clr = Horizon_SHORT_COLOR;
               CreateHLine("SHiNiNG_Horizon_PH_"+IntegerToString(PH_cnt), clr, price, time[rates_total-1]);
               // Print("CreateHLine: ", "Horizon_PH_"+IntegerToString(QPH_cnt), " ", clr, " ", price, " ", HrizonPHBuffer[i]);
               PH_cnt++;
              }
           }
         if(PL_cnt<=2)
           {
            if(HrizonPLBuffer[i] != NULL)
              {
               double price = close[HrizonPLBuffer[i]];
               color clr = Horizon_LONG_COLOR;
               if(price > close[rates_total-1])
                  clr = Horizon_SHORT_COLOR;
               CreateHLine("SHiNiNG_Horizon_PL_"+IntegerToString(PL_cnt), clr, price, time[rates_total-1]);
               // Print("CreateHLine: ", "Horizon_PL_"+IntegerToString(QPH_cnt), " ", clr, " ", price, " ", HrizonPLBuffer[i]);
               PL_cnt++;
              }
           }
         if(
            QPH_cnt>0
            && QPL_cnt>0
            && PH_cnt>2
            && PL_cnt>2
         )
           {
            break;
           }
        }

      // 水平線の削除
      for(int i=QPH_cnt; i<=0; i++)
        {
         DisableHLine("SHiNiNG_Horizon_QPH_"+IntegerToString(i));
        }
      for(int i=QPL_cnt; i<=0; i++)
        {
         DisableHLine("SHiNiNG_Horizon_QPL_"+IntegerToString(i));
        }
      for(int i=PH_cnt; i<=2; i++)
        {
         DisableHLine("SHiNiNG_Horizon_PH_"+IntegerToString(i));
        }
      for(int i=PL_cnt; i<=2; i++)
        {
         DisableHLine("SHiNiNG_Horizon_PL_"+IntegerToString(i));
        }
     }
   else
     {
      // 水平線の削除
      for(int i=QPH_cnt; i<=0; i++)
        {
         ObjectDelete(0, "SHiNiNG_Horizon_QPH_"+IntegerToString(i));
        }
      for(int i=QPL_cnt; i<=0; i++)
        {
         ObjectDelete(0, "SHiNiNG_Horizon_QPL_"+IntegerToString(i));
        }
      for(int i=PH_cnt; i<=2; i++)
        {
         ObjectDelete(0, "SHiNiNG_Horizon_PH_"+IntegerToString(i));
        }
      for(int i=PL_cnt; i<=2; i++)
        {
         ObjectDelete(0, "SHiNiNG_Horizon_PL_"+IntegerToString(i));
        }
     }

  }

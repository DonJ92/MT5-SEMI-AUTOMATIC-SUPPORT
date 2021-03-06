//+------------------------------------------------------------------+
//|                                       SEMI AUTOMATIC SUPPORT.mq5 |
//|                                           Copyright 2020, SAT's  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020"
#property version   "1.00"
#property description ""
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
input ENUM_MA_METHOD InpDiaolog_MAMethod=MODE_EMA; //MOVING AVERAGE TREND 移動平均線の種類
input int            InpDiaolog_MAPeriod=50; //MOVING AVERAGE TREND 移動平均線の期間
input ENUM_ON_OFF    InpMAOnOff_1=ON; // 移動平均線1を有効にする
input ENUM_MA_METHOD InpMAMethod_1=MODE_EMA; // 移動平均線1の種類
input int            InpMAPeriod_1=50; // 移動平均線1の期間
input ENUM_ON_OFF    InpMAOnOff_2=ON;// 移動平均線2を有効にする
input ENUM_MA_METHOD InpMAMethod_2=MODE_EMA; // 移動平均線2の種類
input int            InpMAPeriod_2=100; // 移動平均線2の期間
input ENUM_ON_OFF    InpMAOnOff_3=ON;// 移動平均線3を有効にする
input ENUM_MA_METHOD InpMAMethod_3=MODE_EMA; // 移動平均線3の種類
input int            InpMAPeriod_3=200; // 移動平均線3の期間
color          InpTrendUpColor=C'124,181,62';
color          InpTrendDnColor=C'204,61,69';
color          InpTrendUpFontColor=C'';
color          InpTrendDnFontColor=C'106,106,106';
input color          InpCorrelativeSymbolColor=clrWhite; // 相関文字色
input color          InpDecorrelativeSymbolColor=clrWhite; // 逆相関文字色
input ENUM_MA_METHOD InpDiaolog_MADRMethod=MODE_SMA; //移動平均線乖離率　移動平均線の種類
input int            InpDiaolog_MADRPeriod=25; //移動平均線乖離率　移動平均線の期間
input bool           InpAlert_PSAR=true; //パラボリックSAR アラート(LONG,SHORT)
input bool           InpAlert_MACD=true; //MACD アラート(LONG,SHORT)
input bool           InpAlert_DMI=true; //DMI アラート(LONG,SHORT)
input bool           InpAlert_MADR=true; //移動平均線乖離率 アラート(0.2,0.4,0.6 / -0.2,-0.4,-0.6)
input bool           InpAlert_Trend=true; //トレンドパワー アラート(HIGH,LOW)
input bool           InpAlert_Ichimoku=true; //一目均衡表 アラート(三役好転,三役逆転)
input bool           InpAlert_RSI=true; //RSI アラート(70,80 / 30,20)
input bool           InpAlert_Stoch=true; //ストキャスティクス アラート(70,80 / 30,20)
input bool           InpAlert_MFI=true; //MFI アラート(70,80 / 30,20)
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
color    mainPanel_BackgroundColor  = C'240,240,240';       // 内側の背景の色
color    mainPanel_BorderColor      = C'240,240,240';       // 内側の枠の色

string   common_Font                = "Yu Gothic Medium"; // 文字フォント
int      common_FontSize            = 10;
int      common_FontSize_XL1        = 11;
int      common_FontSize_XL2        = 12;
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
#define LABEL_WIDTH_XL1                     (35)
#define LABEL_WIDTH_XL                      (80)
#define LABEL_HEIGHT                        (20)
#define LABEL_HEIGHT_XS                     (10)
#define LABEL_HEIGHT_XL                     (20)

//---
#define GV_MAT_DIALOG_MA_VISIBLE       "gv.mat_dialog_ma_visible"
#define GV_MAT_DIALOG_HZLINE_VISIBLE   "gv.mat_dialog_hzline_visible"
#define GV_MAT_DIALOG_AXISX            "gv.mat_dialog_axisX"
#define GV_MAT_DIALOG_AXISY            "gv.mat_dialog_axisY"

#define OBJ_NAME_PREFIX                "mat_"
#define OBJ_NAME_CORRELATIVE_SYMBOL    "mat_correlative_symbol"
#define OBJ_NAME_DECORRELATIVE_SYMBOL  "mat_decorrelative_symbol"

#define TREND_UP     1
#define TREND_DN     -1
#define TREND_NONE   0

#define NAN          (int)-99999999999

// 許可口座一覧
bool accountControlEnable = false;
int accountList[] = {
79793,
26778375,
   9108484,
   70000876,
   70001166,
   70005950,
   70103222,
   70073745,
   70001644,
   70000930,
   70000976,
   70000854,
   70001052,
   70085204,
   70103534,
   70011430,
   70032653,
   70022887,
   70022848,
   70031562,
   70011723,
   70103187,
   70073741,
   70103718,
   70103917,
   70103918,
   70103898,
   70103919,
   70103913,
   70103939,
   70103936,
   70103741,
   70104028,
   70104010,
   70104339,
   70000839,
   70104619,
   943000719,
   70104944,
   70105185,
   59046627,
   70106957,
   70031562,
   70009088,
   70011360,
   70110307,
   70111837,
   70011569,
   70111837,
   48206,
   70121911,
   70115784,
   70128682,
70128714,
70128676,
70128730,
70128722,
70128647,
70128674,
70128644,
70103918,
70128660,
70128699,
70128684,
70128697,
70128707,
70128634,
70128806,
70005950,
70128687,
70128649,
70128696,
70128738,
70128643,
70128646,
70128784,
70128880,
70128646,
70128675,
70128891,
70128928,
70128837,
70128809,
70128942,
70128673,
70128838,
70128665,
70129020,
70128909,
70128812,
70128976,
70128986,
70128709,
70129032,
70128712,
70128758,
70129052,
70128992,
70128635,
70128752,
70128648,
70128958,
70104028,
70128636,
70129154,
70128669,
70128785,
70129037,
70128821,
70128741,
70128694,
70128814,
70128962,
70128642,
70129036,
70129186,
70128890,
70129282,
70128686,
70128721,
70128962,
70128698,
70128742,
70129406,
70129386,
70129475,
70128984,
70032653,
70128866,
70129409,
70128903,
70128863,
70129770,
70129564,
70128683,
70128657,
70129108,
70128774,
70129753,
70129831,
70129077,
70128999,
70129884,
70129187,
70129996,
70129488,
70130056,
70129187,
70129062,
70128641, 
70130179,
70128840,
70128652,
70130371,
70128777,
70130191,
70130153,
70130457,
70129870,
70129116,
70128677,
70130567,
70129988,
70130331,
70130416,
70129118,
70130849,
70130957,
70128906,
70128749,
70128848,
70130986,
70131188,
70131169,
70130818,
70130567,
70131334,
70128816,
70130773,
70130412,
70130437, 
70131466,
70104619,
70131213,
70131111, 
70128841,
70131562,
70130975,
70128829,
70131062,
70129217,
70131661,
70131169,
70128816,
70130818,
70131213,
70131466,
70129217,
70104619,
70130567,
70130975,
70131562,
70131334,
70128841,
70130437,
70129049,
70128829,
70130412, 
70128708,
70131318,
70131043,
70130325,
70130168,
70131563,
70130583,
70131041,
70129034,
70128764,
70129096, 
70128790,
70130825,
70130182,
70129341,
70132344,
70132147,
70129042,
70132525,
70132989,
70132048,
70133151,
70128726,
70132950,
70128869,
70132987,
70131111,
70133952,
70133663,
70128917,
70133913,
70130198,
70133952,
70133520,
70133931, 
70134434,
70134343,
70131738,
70134929,  
70128767,
70132339,
70134814,
70135761,
70135437,
70136363,
70134385,
70134875,
70136574,
70131562,
70011430,
70131308,
70131188,
70129488,
70136796,
70136879,
70133998,
70135993,
70135991,
70128660,
70133998,
70134131,
70128992,
70130056,
70129131,
70128657,
70136879,
70135350,
70129032,
70137539,
70137204,
70137626,
70130371,
70137333,
70137307,
70128890,
70130412,
70103741,
70136522,
70137715, 
70137769,
70129488,
70134343,
70137431,
70137300,
70128785,
70128722,
70137486,
70129565,
70137924,
70128777,
70129156,
70131269,
70138253,
70138149,
70138366,
70138336,
70138501,
70138274,
70129251,
70022887,
70130849,
70138404,
70129688,
70129895,
70121911,
70131268,
70139120,
70128766,
70128648,
70128714,
70137688,
70130168,
70133939,
70139559,
70139868,
70139798,
603068,
70129341,
70139930,
70139022,
70139948,
70140277,
70129221,
70140367,
70129067,
70140311,
70137204,
70138130,
70140936,
70141017,
70140906,
70141108,
70139913,
70140580,
70128913,
70141195,
70141360,
70131129,
70129205,
70142327,
70129089,
70140051,
70142704,
70141659,
70142462,
70128669,
70140982,
70141901,
70140441,
70143881,
70143143,
70131306,
70143830,
70140580,
70143412,
70131305,
70144354,
70144432,
70144173,
70144510,
70128740,
70143147,
70132888,
70144085,
70144934,
70128973,
70139744,
70143830,
70145978,
70140297,	
70129394,	
70145714,
70129131,
70141858,
70128696,
70146063,
70144141,
70146290,
70146800,
70130416,
70147904,
70147949,
70145588,
70145718,
70148344,
70148018,
70148890,
70149014,
70146331,
70149313,
70128648,
70147154,
70149347,
70149655,
70133520,
70149811,
70149051,
70150289,
70147265,
70150443,
70150484,
70130567,
70150779,
70150802,
70149266,
70151047,
70150280,
70134589,
70119658,
70131797,
70144364,
70130567,
70145588,
70152085,
70152360,
70151839,
70128914,
70149693,
70129032,
70153077,
70128752,
70153568,
70128647,
70150341,
70128746,
70154541,
70154712,
70154010,
70132147,
70154519,
70154998,
70154882,
70155271,
70155684,
70155661,
70155842,
70150931,
70131523,
70155761,
70155792,
70150848,
70155809,
70156065,
70155867,
70155708,
70156109,
70156253,
70156396,
70153024,
70156529,
70156651,
70128647,
70130431,
70153850,
70155539,
70138336,
70156706,
70157266,
70155867,
70157701,
70157545,
70157568,
70158186,
70157239,
70158514,
70158601,
70158928,
70159027,
70129345,
70158655,
70160698,
70128716,
70158655,
70151014,
70161092,
70128714,
70157600,
70162008,
70160870,
70163029,
70163303,
70133757,
70163525,
70163580,
70163672,
70161961,
70164291,
70163066,
70164667,
70166061,
70165840,
70166362,
70166340,
70166966,
70166837,
70166792,
70136230,
70166458,
70166484,
70167698,
70167796,
70167978,
70156045,
70169004,
70168924,
70170154,
70170612,
70161961,
70171182,
70169147,
70171808,
70167852,
70171889,
70136177,
70154686,
70172773,
70170852,
70155290,
70141858,
70173740,
47643963,
70174477,
70174290,
70174739,
70175064,
70155572,
70157302,
70175662,
70175128,
70176020,
70176346,
70176425,
70176447,
70177044,
70175282,
70176754,
70166484,
70177356,
70146291,
70175282,
70176539,
70178277,
70178363,
70178482,
70140136,
70178562,
70177847,
70156310,
70146290,
70129475,
5608940,
194782,
9112296,
70178737,
70180668,
70180668,
70180748,
70181222,
70177702,
70178978,
70180880,
70184115,
70183950,
70180582,
70185158,
70185128,
70148676,
70186016,
70185985,
70154890,
70186366,
70184319,
70186849,
70186179,
70187077,
70187194,
70187250,
70187362,
70187532,
70187374,
70187599,
70188186,
70128714,
70188532,
70187908,
70186984,
70188756,
70189327,
70186523,
70189614,
70188440,
70189765,
70186523,
70189521,
70195094,
70189941,
70189906,
70132950,
70190606,
70190740,
70190914,
70191303,
70136539,
70191794,
70191890,
70190261,
70129006,
70117420,
70192306,
70192969,
70193402,
70192950,
70193075,
70193207,
70192203,
70187189,
70193057,
70193902,
70194065,
70195274,
70195524,
70184294,
70195676,
70195728,
70192068,
70195678,
70196077,
70195551,
70195878,
26834050,
70196265,
70197294,
70128752,
70192373,
70196823,
70196283,
70198642,
70199268,
70198539,
70192088,
70200202,
70200336,
70200570,
70201131,
70201202,
70201848,
70202207,
70201683,
70202779,
70203355,
70203703,
70203743,
70202836,
70201829,
70204039,
70201721,
70204723,
70204778,
26842637,
70196077,
70205995,
70206295,
70206487,
70196265,
70106957,
70205963,
70207837,
59003913,
70208579,
70208124,
70128790,
70209376,
70209585,
70209245,
70209611,
70186016,
70198974,
70193451,
70210585,
70132950,
26854280,
5006683,
242633,
242694,
242736,
242757,
242768,
242652,
242735,
242852,
242681,
242715,
26854280,
242933,
242911,
70211882,
70212345,
242923,
242830,
70209405,
70211637,
243170,
243176,
243366,
80537694,
243077,
244376,
243764,
70213601,
70187189,
70214023,
244298,
242716,
70202836,
70214685,
70195678,
70136773,
242886,
245478,
70215290,
70162470,
248445,
247718,
70216886,
70216480,
70217515,
70217661,
70146290,
247718,
70219539,
251518,
70219781,
70220302,
252364,
70211013,
70220391,
70219539,
70220967,
255869,
255661,
255772,
255611,
70221734,
70222285,
70222608,
70154276,
70222727,
257493,
244975,
70222969,
70222708,
258406,
258161,
70223279,
70224536,
70223995,
70224975,
70138501,
70225335,
261531,
70226258,
70226380,
261876,
70221923,
70226857,
261913,
70128648,
70128661,
70228235,
70227054,
70227245,
70228207,
70129342,
264888,
70228411,
70230130,
70073800,
70230308,
253698,
70230582,
263589,
70231038,
265998,
266750,
70231500,
267022,
70231983,
70232268,
70161961,
70232990,
267334,
70233191,
70232610,
70233135,
269916,
70233956,
269944,
70235782,
70235938,
70226639,
70235896,
269448,
70236233,
70236825,
270259,
70231978,
70128963,
70128774,
70235614,
273773,
70227245,
70238448,
70236530,
70232594,
70233838,
70238202,
273959,
275382,
70239181,
70204723,
70239993,
70238892,
276347,
70239938,
70239985,
70240750,
70238909,
70219031,
278009,
70240985,
278201,
70129205,
70241830,
279252,
70240571,
70243010,
274872,
280111,
280980,
279252,
70244686,
281444,
70244519,
70244125,
70245159,
70245319,
279911,
70247247,
70246446,
70247842,
279252,
70236176,
70151476,
70129205,
70249071,
70149769,
70249514,
70247938,
};
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
   
   virtual void      Minimize(void) { CAppDialog::Minimize(); m_label_caption.Show(); };
   virtual void      Maximize(void) { CAppDialog::Maximize(); m_label_caption.Hide(); };
   
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
//bool CMovingAverageTrend::Hide(void)
//{
//   CAppDialog::Hide();
//   
//   m_label_caption.Show();
//   
//   return(true);
//}

bool CMovingAverageTrend::Show(void)
{
   CAppDialog::Show();
   
   //m_button_minmax.Hide();
   //m_button_close.Hide();   
   m_label_caption.Hide();
   
   for(int i=0;i<10;i++)
     {
      m_label_RSI_trends[i].Hide();
      m_label_Stoch_trends[i].Hide();
      m_label_MFI_trends[i].Hide();
     }
   
   return(true);
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
//---
   int trendMA_m1=CalcTrend_MA(_Symbol,_indHandle_MA_m1);
   int trendMA_m5=CalcTrend_MA(_Symbol,_indHandle_MA_m5);
   int trendMA_m15=CalcTrend_MA(_Symbol,_indHandle_MA_m15);
   int trendMA_1h=CalcTrend_MA(_Symbol,_indHandle_MA_1h);
   int trendMA_4h=CalcTrend_MA(_Symbol,_indHandle_MA_4h);
   int trendMA_1d=CalcTrend_MA(_Symbol,_indHandle_MA_1d);   
   
//---
   int trendPSAR=CalcTrend_PSAR(_Symbol,_indHandle_PSAR);
   if(_lastTrend_PSAR!=trendPSAR)
     {
      if(InpAlert_PSAR && _lastTrend_PSAR!=NAN)
         Alert("【Parabolic SAR "+GetTrendDescription(trendPSAR)+"】");
        
      _lastTrend_PSAR=trendPSAR;   
     }
   
//---
   int trendMACD=CalcTrend_MACD(_indHandle_MACD);
   if(_lastTrend_MACD!=trendMACD)
     {
      if(InpAlert_MACD && _lastTrend_MACD!=NAN)
         Alert("【MACD "+GetTrendDescription(trendMACD)+"】");
        
      _lastTrend_MACD=trendMACD;   
     }
   
//---
   int trendDI=CalcTrend_DI(_indHandle_ADX);   
   
   if(_lastTrend_DI!=trendDI)
     {
      if(InpAlert_DMI && _lastTrend_DI!=NAN)
         Alert("【DMI "+GetTrendDescription(trendDI)+"】");
        
      _lastTrend_DI=trendDI;   
     }
   
//---
   double madrVal=CalcIndVal_MADR(_Symbol,_indHandle_MADR);   
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
   if(_lastTrend_ADX!=trendADX)
     {
      if(InpAlert_Trend && _lastTrend_ADX!=NAN)
         Alert("【TREND - "+GetTrendDescription_EN(trendADX)+" -】");
         
      _lastTrend_ADX=trendADX;
     }
     
//---
   int trendIchimoku=CalcTrend_Ichimoku(_indHandle_Ichimoku);
   
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
   double rsi_indVal=CalcIndVal_Oscillator(_indHandle_RSI);
   if((_lastValue_RSI<70 && rsi_indVal>=70 && ((bool)(reachedLevel=70) || true)) ||
      (_lastValue_RSI<80 && rsi_indVal>=80 && ((bool)(reachedLevel=80) || true)) ||
      (_lastValue_RSI>30 && rsi_indVal<=30 && ((bool)(reachedLevel=30) || true)) ||
      (_lastValue_RSI>20 && rsi_indVal<=20 && ((bool)(reachedLevel=20) || true)))
     {
      if(InpAlert_RSI && _lastValue_RSI!=NAN)
         Alert("【RSIが"+DoubleToString(reachedLevel,0)+"に達しました】");
         
      _lastValue_RSI=rsi_indVal;   
     }
   
//---
   double stoch_indVal=CalcIndVal_Oscillator(_indHandle_Stoch);   
   if((_lastValue_Stoch<70 && stoch_indVal>=70 && ((bool)(reachedLevel=70) || true)) ||
      (_lastValue_Stoch<80 && stoch_indVal>=80 && ((bool)(reachedLevel=80) || true)) ||
      (_lastValue_Stoch>30 && stoch_indVal<=30 && ((bool)(reachedLevel=30) || true)) ||
      (_lastValue_Stoch>20 && stoch_indVal<=20 && ((bool)(reachedLevel=20) || true)))
     {
      if(InpAlert_Stoch && _lastValue_Stoch!=NAN)
         Alert("【ストキャスティクスが"+DoubleToString(reachedLevel,0)+"に達しました】");
        
      _lastValue_Stoch=stoch_indVal;   
     }

//---
   double mfi_indVal=CalcIndVal_Oscillator(_indHandle_MFI);     
   if((_lastValue_MFI<70 && mfi_indVal>=70 && ((bool)(reachedLevel=70) || true)) ||
      (_lastValue_MFI<80 && mfi_indVal>=80 && ((bool)(reachedLevel=80) || true)) ||
      (_lastValue_MFI>30 && mfi_indVal<=30 && ((bool)(reachedLevel=30) || true)) ||
      (_lastValue_MFI>20 && mfi_indVal<=20 && ((bool)(reachedLevel=20) || true)))
     {
      if(InpAlert_MFI && _lastValue_MFI!=NAN)
         Alert("【MFIが"+DoubleToString(reachedLevel,0)+"に達しました】");
        
      _lastValue_MFI=mfi_indVal;   
     }  
           
   //---
   for(int i=0;i<_symbolTrendMetersTotal;i++)
     {
      _symbolTrendMeters[i].diffCount=0;
      
      int trendMA_m1_other=CalcTrend_MA(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MA_m1);
      int trendMA_m5_other=CalcTrend_MA(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MA_m5);
      int trendMA_m15_other=CalcTrend_MA(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MA_m15);
      int trendMA_1h_other=CalcTrend_MA(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MA_1h);
      int trendMA_4h_other=CalcTrend_MA(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MA_4h);
      int trendMA_1d_other=CalcTrend_MA(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MA_1d);   
      int trendPSAR_other=CalcTrend_PSAR(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_PSAR);
      int trendMACD_other=CalcTrend_MACD(_symbolTrendMeters[i].indHandle_MACD);
      int trendDI_other=CalcTrend_DI(_symbolTrendMeters[i].indHandle_ADX);
      double madrVal_other=CalcIndVal_MADR(_symbolTrendMeters[i].symbolName,_symbolTrendMeters[i].indHandle_MADR);
      int trendADX_other=CalcTrend_ADX(_symbolTrendMeters[i].indHandle_ADX);
      int trendIchimoku_other=CalcTrend_Ichimoku(_symbolTrendMeters[i].indHandle_Ichimoku);
      double rsi_indVal_other=CalcIndVal_Oscillator(_symbolTrendMeters[i].indHandle_RSI);
      double stoch_indVal_other=CalcIndVal_Oscillator(_symbolTrendMeters[i].indHandle_Stoch);
      double mfi_indVal_other=CalcIndVal_Oscillator(_symbolTrendMeters[i].indHandle_MFI);
      
      if(trendMA_m1!=trendMA_m1_other && trendMA_m1_other!=TREND_NONE)     _symbolTrendMeters[i].diffCount++;
      if(trendMA_m5!=trendMA_m5_other && trendMA_m5_other!=TREND_NONE)     _symbolTrendMeters[i].diffCount++;
      if(trendMA_m15!=trendMA_m15_other && trendMA_m15_other!=TREND_NONE)  _symbolTrendMeters[i].diffCount++;
      if(trendMA_1h!=trendMA_1h_other && trendMA_1h_other!=TREND_NONE)     _symbolTrendMeters[i].diffCount++;
      if(trendMA_4h!=trendMA_4h_other && trendMA_4h_other!=TREND_NONE)     _symbolTrendMeters[i].diffCount++;
      if(trendMA_1d!=trendMA_1d_other && trendMA_1d_other!=TREND_NONE)     _symbolTrendMeters[i].diffCount++;
      if(trendPSAR!=trendPSAR_other && trendPSAR_other!=TREND_NONE)        _symbolTrendMeters[i].diffCount++;
      if(trendMACD!=trendMACD_other && trendMACD_other!=TREND_NONE)        _symbolTrendMeters[i].diffCount++;
      if(trendDI!=trendDI_other && trendDI_other!=TREND_NONE)              _symbolTrendMeters[i].diffCount++;
      if(madrVal*madrVal_other>0 && madrVal_other!=NAN)                    _symbolTrendMeters[i].diffCount++;
      if(trendADX!=trendADX_other && trendADX_other!=TREND_NONE)           _symbolTrendMeters[i].diffCount++;
      if(trendIchimoku!=trendIchimoku_other && trendIchimoku_other!=TREND_NONE) _symbolTrendMeters[i].diffCount++;
      
      if(((rsi_indVal>70 && rsi_indVal_other>70) || (rsi_indVal<30 && rsi_indVal_other<30)) && rsi_indVal_other!=NAN)    _symbolTrendMeters[i].diffCount++;
      if(((stoch_indVal>70 && stoch_indVal_other>70) || (stoch_indVal<30 && stoch_indVal_other<30)) && stoch_indVal_other!=NAN)    _symbolTrendMeters[i].diffCount++;
      if(((mfi_indVal>70 && mfi_indVal_other>70) || (mfi_indVal<30 && mfi_indVal_other<30)) && mfi_indVal_other!=NAN)    _symbolTrendMeters[i].diffCount++;
     }
   
   string correlativeSymbol="",
          decorrelativeSymbol="";
   int maxDiffCount=-999, minDiffCount=999;
   for(int i=0;i<_symbolTrendMetersTotal;i++)
     {
      if(_symbolTrendMeters[i].diffCount>maxDiffCount)
        {
         maxDiffCount=_symbolTrendMeters[i].diffCount;
         decorrelativeSymbol=_symbolTrendMeters[i].symbolName;
        }
      
      if(_symbolTrendMeters[i].diffCount<minDiffCount)
        {
         minDiffCount=_symbolTrendMeters[i].diffCount;
         correlativeSymbol=_symbolTrendMeters[i].symbolName;
        }  
     }
   if(ObjectFind(0,OBJ_NAME_CORRELATIVE_SYMBOL)<0)
      ObjectCreate(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJPROP_COLOR,InpCorrelativeSymbolColor);
   ObjectSetString(0,OBJ_NAME_CORRELATIVE_SYMBOL,OBJPROP_TEXT,"相関通貨: "+correlativeSymbol);
   
   if(ObjectFind(0,OBJ_NAME_DECORRELATIVE_SYMBOL)<0)
      ObjectCreate(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJPROP_COLOR,InpDecorrelativeSymbolColor);
   ObjectSetString(0,OBJ_NAME_DECORRELATIVE_SYMBOL,OBJPROP_TEXT,"逆相関通貨: "+decorrelativeSymbol);
          
   if(!m_minimized)
     {
      if(trendMA_m1==TREND_NONE)
         m_label_MA_trend_m1.Color(common_BackgroundColor);
      else
         m_label_MA_trend_m1.Color(trendMA_m1==TREND_UP ? InpTrendUpColor : InpTrendDnColor);  
      
      if(trendMA_m5==TREND_NONE)
         m_label_MA_trend_m5.Color(common_BackgroundColor);
      else   
         m_label_MA_trend_m5.Color(trendMA_m5==TREND_UP ? InpTrendUpColor : InpTrendDnColor);   
         
      if(trendMA_m15==TREND_NONE)
         m_label_MA_trend_m15.Color(common_BackgroundColor);
      else   
         m_label_MA_trend_m15.Color(trendMA_m15==TREND_UP ? InpTrendUpColor : InpTrendDnColor);      
         
      if(trendMA_1h==TREND_NONE)
         m_label_MA_trend_1h.Color(common_BackgroundColor);
      else   
         m_label_MA_trend_1h.Color(trendMA_1h==TREND_UP ? InpTrendUpColor : InpTrendDnColor);
         
      if(trendMA_4h==TREND_NONE)
         m_label_MA_trend_4h.Color(common_BackgroundColor);
      else   
         m_label_MA_trend_4h.Color(trendMA_4h==TREND_UP ? InpTrendUpColor : InpTrendDnColor);
      
      if(trendMA_1d==TREND_NONE)
         m_label_MA_trend_1d.Color(common_BackgroundColor);
      else   
         m_label_MA_trend_1d.Color(trendMA_1d==TREND_UP ? InpTrendUpColor : InpTrendDnColor);
      
      //---
      if(trendPSAR==TREND_NONE)
         m_bmpbutton_PSAR_trend.Hide();
      else   
        {
         m_bmpbutton_PSAR_trend.Show();
         m_bmpbutton_PSAR_trend.Pressed(trendPSAR==TREND_UP);   
        }
      
      //---   
      if(trendMACD==TREND_NONE)
         m_bmpbutton_MACD_trend.Hide();
      else   
        {
         m_bmpbutton_MACD_trend.Show();
         m_bmpbutton_MACD_trend.Pressed(trendMACD==TREND_UP);  
        }
      
      //---
      if(trendDI==TREND_NONE)
         m_bmpbutton_DI_trend.Hide();
      else   
        {
         m_bmpbutton_DI_trend.Show();
         m_bmpbutton_DI_trend.Pressed(trendDI==TREND_UP);   
        }
      
      //---
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
   
      //---
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
      
      //---
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
         
         m_bmpbutton_Ichimoku_trend_1.Pressed(trendIchimoku==TREND_UP);   
         m_bmpbutton_Ichimoku_trend_2.Pressed(trendIchimoku==TREND_UP);   
         m_bmpbutton_Ichimoku_trend_3.Pressed(trendIchimoku==TREND_UP);
        }  
        
      //---
      int meterLevel=(int)(rsi_indVal/10);
      m_label_RSI_percent.Text(DoubleToString(rsi_indVal,0));
      for(int i=0; i<10; i++)
        {
         if(i>meterLevel)
            m_label_RSI_trends[i].Hide();
         else
            m_label_RSI_trends[i].Show();
        }  
      
      //---
      meterLevel=(int)(stoch_indVal/10);
      m_label_Stoch_percent.Text(DoubleToString(stoch_indVal,0));
      for(int i=0; i<10; i++)
        {
         if(i>meterLevel)
            m_label_Stoch_trends[i].Hide();
         else
            m_label_Stoch_trends[i].Show();
        }
      
      //---
      meterLevel=(int)(mfi_indVal/10);
      m_label_MFI_percent.Text(DoubleToString(mfi_indVal,0));
      for(int i=0; i<10; i++)
        {
         if(i>meterLevel)
            m_label_MFI_trends[i].Hide();
         else
            m_label_MFI_trends[i].Show();
        }
      
      //---
      MoveObj();
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

   //m_button_minmax.Hide();
   //m_button_close.Hide();
   m_label_caption.Hide();

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
                  
   if(!CreateCLabel(m_label_MA, "m_label_MA", "MOVING AVERAGE TREND", common_Font, common_FontSize_XL1, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_LEFT_UPPER))
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
   if(!CreateCLabel(m_label_PSAR, "m_label_PSAR", "P_SAR", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;   
   if(!CreateCLabel(m_label_MACD, "m_label_MACD", "MACD", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_DMI, "m_label_DMI", "DMI", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;   
   if(!CreateCLabel(m_label_MADR, "m_label_MADR", "MADR", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_MADR_trend, "m_label_MADR_trend", "NaN", common_Font, common_FontSize_XL2, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_ADX, "m_label_ADX", "TREND", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_ADX_trend, "m_label_ADX_trend", "NETURAL", common_Font, common_FontSize_XL2, percentBar_FontColor, LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_Ichimoku, "m_label_Ichimoku", "ICHI", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;   
   if(!CreateCLabel(m_label_RSI, "m_label_RSI", "RSI", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_RSI_percent, "m_label_RSI_percent", "NaN", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_CENTER))
      return false;
   for(int i = 0; i < 10; i++)
     {
      if(!CreateCLabel(m_label_RSI_trends[i], "m_label_RSI_trend_"+IntegerToString(i+1), "-", percentBar_Font, percentBar_FontSize, CalcMeterLevelColor(i), LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_LEFT))
         return false;
     }
   if(!CreateCLabel(m_label_Stoch, "m_label_Stoch", "STOCH", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
      return false;
   if(!CreateCLabel(m_label_Stoch_percent, "m_label_Stoch_percent", "NaN", common_Font, common_FontSize, common_FontColor, LABEL_WIDTH, LABEL_HEIGHT, ANCHOR_CENTER))
      return false;
   for(int i = 0; i < 10; i++)
     {
      if(!CreateCLabel(m_label_Stoch_trends[i], "m_label_Stoch_trend_"+IntegerToString(i+1), "-", percentBar_Font, percentBar_FontSize, CalcMeterLevelColor(i), LABEL_WIDTH, LABEL_HEIGHT_XS, ANCHOR_LEFT))
         return false;
     }
   if(!CreateCLabel(m_label_MFI, "m_label_MFI", "MFI", common_Font, common_FontSize_XL2, common_FontColor, LABEL_WIDTH_XL, LABEL_HEIGHT_XL, ANCHOR_CENTER))
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
     
//---
   m_button_minmax.Hide();
   m_button_minmax.Show();
   
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

struct SymbolTrendMeters
  {
   string symbolName;
   
   int indHandle_MA_m1;
   int indHandle_MA_m5;
   int indHandle_MA_m15;
   int indHandle_MA_1h;
   int indHandle_MA_4h;
   int indHandle_MA_1d;
   
   int indHandle_PSAR;
   int indHandle_MACD;
   int indHandle_ADX;
   int indHandle_MADR;
   int indHandle_Ichimoku;
   int indHandle_RSI;
   int indHandle_Stoch;
   int indHandle_MFI;  
   
   int diffCount;
   
public:
   bool CreateIndicators();
   void ReleaseIndicators();
   
   int GetTrendStrength();
  };

bool SymbolTrendMeters::CreateIndicators(void)
  {
   indHandle_MA_m1=iMA(symbolName,PERIOD_M1,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   indHandle_MA_m5=iMA(symbolName,PERIOD_M5,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   indHandle_MA_m15=iMA(symbolName,PERIOD_M15,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   indHandle_MA_1h=iMA(symbolName,PERIOD_H1,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   indHandle_MA_4h=iMA(symbolName,PERIOD_H4,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);
   indHandle_MA_1d=iMA(symbolName,PERIOD_D1,InpDiaolog_MAPeriod,0,InpDiaolog_MAMethod,PRICE_CLOSE);   
   indHandle_PSAR=iSAR(symbolName,0,0.02,0.2);
   indHandle_MACD=iMACD(symbolName,0,12,26,9,PRICE_CLOSE);
   indHandle_ADX=iADX(symbolName,0,14);
   indHandle_MADR=iMA(symbolName,0,InpDiaolog_MADRPeriod,InpDiaolog_MADRMethod,MODE_SMA,PRICE_CLOSE);
   indHandle_Ichimoku=iIchimoku(symbolName,0,9,26,52);
   indHandle_RSI=iRSI(symbolName,0,14,PRICE_CLOSE);
   indHandle_Stoch=iStochastic(symbolName,0,5,3,3,MODE_SMA,STO_LOWHIGH);
   indHandle_MFI=iMFI(symbolName,0,14,VOLUME_TICK);

   if(indHandle_MA_m1==INVALID_HANDLE || indHandle_MA_m5==INVALID_HANDLE || indHandle_MA_m15==INVALID_HANDLE ||
      indHandle_MA_1h==INVALID_HANDLE || indHandle_MA_4h==INVALID_HANDLE || indHandle_MA_1d==INVALID_HANDLE ||
      indHandle_MADR==INVALID_HANDLE ||
      indHandle_PSAR==INVALID_HANDLE ||
      indHandle_MACD==INVALID_HANDLE ||
      indHandle_ADX==INVALID_HANDLE ||
      indHandle_Ichimoku==INVALID_HANDLE ||
      indHandle_RSI==INVALID_HANDLE ||
      indHandle_Stoch==INVALID_HANDLE ||
      indHandle_MFI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the indicator for the symbol %s, error code %d",
                  Symbol(),
                  GetLastError());
      //--- the indicator is stopped early
      return(false);
     }
   
   return(true);  
  }
  
void SymbolTrendMeters::ReleaseIndicators(void)
  {
//---
   IndicatorRelease(indHandle_MA_m1);
   IndicatorRelease(indHandle_MA_m5);
   IndicatorRelease(indHandle_MA_m15);
   IndicatorRelease(indHandle_MA_1h);
   IndicatorRelease(indHandle_MA_4h);
   IndicatorRelease(indHandle_MA_1d);
   IndicatorRelease(indHandle_MADR);
   IndicatorRelease(indHandle_PSAR);
   IndicatorRelease(indHandle_MACD);
   IndicatorRelease(indHandle_ADX);
   IndicatorRelease(indHandle_Ichimoku);
   IndicatorRelease(indHandle_RSI);
   IndicatorRelease(indHandle_Stoch);
   IndicatorRelease(indHandle_MFI);
  }  

int               _symbolTrendMetersTotal=0;
SymbolTrendMeters _symbolTrendMeters[];
  
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
  
         // 許可している口座か
  if(!chkTradeAccount())
  {
    printf("Error Account Error");
    return(INIT_FAILED);
   }
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
   
   _symbolTrendMetersTotal=0;
   for(int i=0;i<SymbolsTotal(true);i++)
     {
      if(SymbolName(i,true)==_Symbol || SymbolInfoInteger(SymbolName(i,true),SYMBOL_SECTOR)!=SECTOR_CURRENCY)
         continue;
      
      _symbolTrendMetersTotal++;
      if(ArraySize(_symbolTrendMeters)<_symbolTrendMetersTotal)
         ArrayResize(_symbolTrendMeters,_symbolTrendMetersTotal,100);
         
      _symbolTrendMeters[_symbolTrendMetersTotal-1].symbolName=SymbolName(i,true);
      if(!_symbolTrendMeters[_symbolTrendMetersTotal-1].CreateIndicators())
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
   
   if(!ExtDialog.Create(0,"MOVING AVERAGE TREND",0,axisX,axisY,axisX+DIALOG_WIDTH,axisY+DIALOG_HEIGHT))
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

//---
   for(int i=0;i<_symbolTrendMetersTotal;i++)
     {
      _symbolTrendMeters[i].ReleaseIndicators();
     }
      
//--- clear comments
   ObjectsDeleteAll(0,"SHiNiNG_Horizon");
   ObjectsDeleteAll(0,OBJ_NAME_PREFIX);
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
   if(id == CHARTEVENT_OBJECT_CLICK && 
      StringFind(sparam, "m_label_MA") != -1 &&
      StringFind(sparam, "m_label_MA_trend_1d") == -1)
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
int CalcTrend_MA(string symbol, int indHandle_MA)
  {
   double curPrice=iClose(symbol,0,0);
   double indVal[1];
   
   ResetLastError();
   if(CopyBuffer(indHandle_MA,0,0,1,indVal)!=1)
     {
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iMA indicator, error code %d, %d",indHandle_MA,GetLastError());  
        }
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }
      
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
int CalcTrend_PSAR(string symbol, int indHandle_PSAR)
  {
   double indVal[1];

   ResetLastError();
   if(CopyBuffer(indHandle_PSAR,0,0,1,indVal)!=1)
     {
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
        }
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }
   
   double curPrice=iClose(symbol,0,0);
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
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
        }
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
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
        }
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
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
        }
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
   double spanA[], spanB[];
   ArraySetAsSeries(spanA,true);
   ArraySetAsSeries(spanB,true);
   
   ResetLastError();
   if(CopyBuffer(indHandle_Ichimoku,2,-26,27,spanA)<0 ||
      CopyBuffer(indHandle_Ichimoku,3,-26,27,spanB)<0)
     {
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iIchimoku indicator, error code %d",GetLastError());
        }
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(TREND_NONE);
     }
   
   int trend=TREND_NONE;
   if(iLow(NULL,0,0)>MathMax(spanA[26],spanB[26]) && spanA[0]>spanB[0])
     {
      trend=TREND_UP;
     }
   else if(iHigh(NULL,0,0)<MathMin(spanA[26],spanA[26]) && spanA[0]<spanB[0])
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
double CalcIndVal_MADR(string symbol, int indHandle_MA)
  {
   double curPrice=iClose(symbol,0,0);
   double indVal[1];

   ResetLastError();
   if(CopyBuffer(indHandle_MA,0,0,1,indVal)<0)
     {
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iMADR indicator, error code %d",GetLastError());
        }
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
      if(_LastError!=ERR_INDICATOR_DATA_NOT_FOUND)
        {
         //--- if the copying fails, tell the error code
         PrintFormat("Failed to copy data from the iOscillator indicator, error code %d",GetLastError());
        }
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

bool chkTradeAccount()
{
   if(!accountControlEnable)
   {
      return true;
   }

   int account_no = AccountInfoInteger(ACCOUNT_LOGIN);

   int Size=ArraySize(accountList);
   for(int i=0;i<Size;i++){
      if(accountList[i]==account_no)
         return true;
   }

   return false;
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

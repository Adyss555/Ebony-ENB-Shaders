//----------------------------------------------------------------------------------------------//
//								    SHADER WEATHER INDEX FILE									//
//----------------------------------------------------------------------------------------------//
//								==================================								//
//								//		Silent Horizons ENB     //								//
//								//								//								//
//								//		 by LonelyKitsuune      //								//
//								==================================								//
//----------------------------------------------------------------------------------------------//
//Weather index ranges from weatherlist.ini - required for weather specific shader effects


//Vanilla
#define ENABLE_WEATHERFX_SHADERS
#define ENABLE_SUNRAY_WEATHERSEPARATION
//#define DISABLE_AURORA_WEATHERSEPARATION


//----------------------------------------- WEATHER FX -----------------------------------------//

#define WFX_RAINY_WEATHERS_START 38
#define WFX_RAINSTORMS_START     48
#define WFX_RAINY_WEATHERS_END   49
#define WFX_SNOWY_WEATHERS_START 50
#define WFX_SNOWSTORM            51
#define WFX_SNOWY_WEATHERS_END   51

#define WFX_ASH_STORMSTART  	 73
#define WFX_ASH_STORMEND   		 75

//------------------------------------------ SUN RAYS ------------------------------------------//

#define SR_CLEAR_WEATHERS_START    1
#define SR_CLEAR_A_WEATHERS_START  10
#define SR_CLOUDY_WEATHERS_START   19
#define SR_CLOUDY_A_WEATHERS_START 28
#define SR_RAINY_WEATHERS_START    38
#define SR_SNOWY_WEATHERS_START    50
#define SR_FOGGY_WEATHERS_START    52
#define SR_ASH_WEATHERS_START      67
#define	SR_Special_WEATHERS_START  77
#define SR_WEATHERS_END            85

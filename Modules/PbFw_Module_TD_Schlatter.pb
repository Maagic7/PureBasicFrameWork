; ===========================================================================
;  FILE: PbFw_Module_SchlatterAndBaker_Meteorology.pb
;  NAME: Module Thermo Dynamic SnB:: 
;  DESC: A professional Thermo dynamic library for use in
;  DESC: Meteorology, Air Conditioning, Vacuum Technology
;  DESC: Based on Schlatter and Baker Meteorology Algorithms Comparisons 1991
;  DESC: The Module is a fork of td_lib.pb from Bernd Kuemmel
;  DESC: 
;  SOURCES: td_lib from Bernd Kuemmel
;           https://www.ninelizards.com/purebasic/purebasic%2029.htm#top    "! search for TD_lib !"
;           direct download: https://www.ninelizards.com/purebasic/tdlib.zip
;           Based on: "Algorithms, Comparisons and Source References by Schlatter and Baker"
;                      https://wahiduddin.net/calc/density_algorithms.htm
;
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/08/12
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  It's all well known teaching knwolege and you can find ist on the web!
;             So it's free stuff for everyone!
; ===========================================================================
;{ ChangeLog: 
;   2023/08/12 S. Maag 
;         Reworked td_lib.pb completely as a Module
;       - Reorderd all the original Functions. So now all is the same order 
;         Documentiation, Declaration and Implementation.
;       - Added A) B) C) D) Function description as CodeSeparator for IDE
;         as it is in the documentation.
;       - Standardized calling convention of Schalter and Baker Functions
;         Now the Paramets are alway in the same order (bevor it was confused)
;         somitimes was (T,P), somtimes (P,T). 
;         Now always (T, P, other); (T,P,rH) (T,P,TD), 
;       - Some code optimations for PureBasic 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

; ---------------------------------------------------------------------------
; Notes by Bernd Kuemmel
; ---------------------------------------------------------------------------
;{  
  ; *** PUREBASIC IMPLEMENTATION
  ;
  ; I've only done the dry to wet bulb conversion, so who's interested could have a go at the remaining functions :-)
  ;
  ;
  ; *** ORIGINAL TEXT
  ;
  ;
  ; From: BEK@MMF.ruc.dk (Bernd Kuemmel)
  ; Newsgroups: sci.geo.meteorology
  ; Subject: Temp, Humidity & Dew Point ONA
  ; Date: 12 Jun 1997 15:45:34 GMT
  ; Message-ID: <5np5iu$ivj$1@news.uni-c.dk>
  ; Reply-To: Bernd Kuemmel <BEK@mmf.ruc.dk>
  ;
  ; Archive-name: meteorology/temp-dewpoint
  ; Posting-Frequency: About monthly.
  ; Version: 008
  ; Date: May 27, 1997
  ; Updated: When necessary
  ; Lines: about 680
  ;
  ;   The _Temp, Humidity & Dew Point_  ONA (Often Needed Answers)
  ;
  ;
  ; Table-of-contents:
  ; 1)  Introduction.
  ; 2)  Formulae.
  ; 3)  Examples.
  ; 4)  Literature.
  ; 5)  Committment.
  ; 6)  Outlook.
  ; 7)  Signature.
  ;
  ;
  ; A plain text version of this text can also be found on:
  ; http://mmf.ruc.dk/~bek/relhum.htm
  ;
  ;
  ; 1) Introduction:
  ;
  ; From the discussions on the newsgroup sci.geo.meteorology this is a
  ; collection of some formulae and texts that reflect on connections
  ; of temperature, humidity and dew point temperature (BeK):
  ;
  ; Air will normally contain a certain amount of water vapour. The
  ; maximum amount of water vapour, that air can contain, depends on
  ; the temperature and, for certain temperature ranges, also on whether
  ; the air is near to a water or ice surface. If you have a closed con-
  ; tainer with water and air (like a beaker) then there an equilibrium
  ; will develop, where the air will contain as much vapour as it can.
  ; The air will then be saturated with respect to water vapour.
  ; The real world outside is not closed, so that the air normally will
  ; contain less vapour as it could. Sources of vapour are evaporation
  ; processes from water and ice surfaces and transpiration from plants
  ; and respiration from animals. The expression "evapotranspiration"
  ; takes into consideration plants' large share of evaporation over
  ; land areas.
  ; Sinks of water vapour are clouds or condensation on surfaces.
  ; Dew is created when a surface temperature has such a low temperature
  ; that the air chills to the dew point and the water vapour condenses.
  ; Physically at the dew point temperature the vapour loses the energy
  ; that it gained at evaporation, the latent energy, again.
  ;
  ; The precipitable water (total column water vapor) is strongly
  ; correlated (r > 0.9) with the surface dew point on most days.
  ; Exceptions to the rule include days when a cold front has passed
  ; and during other transient events. (Kerry Andersen)
  ;
  ;
  ; NET readings :
  ; http://covis2.atmos.uiuc.edu/guide/wmaps/general/rhdef.html
  ; http://njnie.dl.stevens-tech.edu/curriculum/oceans/rel.html
  ; http://www.mtc.com.my/fpub/lib/drying/ch11.htm
  ;
  ;
  ;
  ; 2) Formulae:
  ;
  ; Enough for dry physical theories; here comes the practice.
  ;
  ; For some people skipping this and going directly to the examples
  ; would be the most rewarding. Especially as they treat the conversion
  ; of relative humidity and psychrometer temperatures. (BeK)
  ;
  ; Vapor pressure (e) is the fraction of the ambient pressure that is
  ; due to the fraction of water vapor in the air.
  ; Saturation vapor pressure (ES) is the maximum vapor pressure that the
  ; air can support (non supersaturated) at a given temperature.
  ;
  ; e  can vary from 0 (verrry dry) to the maximum, ES.
  ; ES is a function of temperature ES(T).
  ;
  ;
  ; Relative humidity (RH) is 100% times the ratio of the environmental
  ; vapour pressure, e(T), to the saturation vapour pressure ES(T).
  ;
  ;         RH = 100% * e(T)/ES(T)
  ;
  ;
  ; The environmental vapour pressure is the saturation vapour pressure
  ; at the dew point or
  ;
  ;         e(T) = ES(Td)
  ;
  ; so RH becomes
  ;
  ;         RH = 100% * ES(Td)/ES(T)
  ;
  ; In other words: if you have a parcel of air and cool it until the
  ; water vapor in it condenses then you have reached the saturation point.
  ; At this point you will measure the same vapour pressure as in your
  ; original air probe.
  ;
  ;
  ;
  ; Some more elaborate expressions follow here:
  ;
  ; es0 = reference saturation vapor pressure (ES at a certain temp, usually 0 deg C)
  ;     = 6.11 hPa
  ;
  ; T0  = reference temperature (273.15 Kelvin,  Kelvin = degree C + 273.15)
  ;
  ; Td  = dew point temperature (Kelvin)
  ;
  ; T   = temperature (Kelvin)
  ;
  ; lv  = latent heat of vaporization of water (2.5 * 10^6 joules per kilogram)
  ;
  ; Rv  = gas constant for water vapor (461.5 joules* Kelvin / kilogram)
  ;
  ; e  = es0 * exp( lv/Rv * (1/T0 - 1/Td))
  ; ES = es0 * exp( lv/Rv * (1/T0 - 1/T))
  ;
  ; RH= e/ES * (100%) = relative humidity !!!!
  ;
  ; So just above is the answer to many questions in the direction of
  ; how to calculate the relative humidity if you have the dew point
  ; and air temperature.
  ;
  ;
  ;
  ; There are some simple and more complicated formulas for the
  ; saturation vapour pressure at a given temperature.
  ;
  ; A simple first guess (assuming the latent heat of vaporization is
  ; constant with temperature) would be:
  ;
  ;         log10(ES) = 9.4041 - 2354/T
  ; or
  ;         ln(ES) = 21.564 - 5420/T
  ;
  ; where T is in Kelvin (i.e., 273.15+T(C)). {After inverting the
  ; logarithms ES in given in hPa.}
  ;
  ; Another approximation (Magnus' formula) would be
  ;
  ;         log10(ES) = -2937.4/T - 4.9283*log10(T) + 23.5470
  ;
  ;
  ;
  ; In the following the input gets a little more complicated. Here we
  ; also shall distinguish between the saturation vapour pressure over
  ; ice or water. Both are different, as the molecular forces bind much
  ; more in an ice crystal than in a water bobble. So the saturation
  ; pressure esW will be larger than esI (W for water, I for ice).
  ;
  ;  1.  Vapor pressure (e):
  ;
  ;                              dew point temperature in degrees C.
  ;                             /
  ;      e  = 6.1078 * 10 ** ((TD * A)/(TD + B)) in hPa
  ;
  ;
  ;  2.  Saturated vapor pressure (ES):
  ;
  ;
  ;      ES = 6.1078 * 10 ** ((T * A)/(T + B))
  ;                             \
  ;                              temperature in C
  ;
  ;                    A =   7.5 } for use in vapor pressure
  ;                    B = 237.3 } with respect to WATER
  ;
  ;                  * A =   9.5 } for use in vapor pressure
  ;                    B = 265.5 } with respect to ICE
  ;
  ;
  ;
  ;  3.  Absolute virtual temperature (TV):
  ;
  ;                                  vapor pressure
  ;                                 /
  ;      TV = (T + 273.15)/(1-0.379*e/Press)
  ;                                     \
  ;                                      total pressure
  ;
  ;      TV does take into consideration that you could try to condense
  ;      all the water vapour in your air parcel and use the condensation
  ;      heat to warm up the air. This is a first way to distinguish
  ;      different air parcels that may have the same temperature but
  ;      have different relative humidity.
  ;
  ;
  ;
  ;  4.  Mixing ratio (W):
  ;                                  vapor pressure
  ;                                 /
  ;                         .62197 e                      grams water
  ;                     W = --------                      -------------
  ;                            P - e                      grams dry air
  ;                             \                              |
  ;                              total pressure                |
  ;                                                    Thus 12 g/Kg comes out as .012
  ;
  ;
  ;  5.  Wet Bulb
  ;      Vapor Pressure
  ;      Dew Point               (P365, Smithsonian for first part)
  ;
  ;      Ew - e
  ;      ------       = .000660 (1 + .00115 T )
  ;      Press (T-Tw)                        w
  ;
  ;  Therefore:
  ;
  ;             e = Ew - Press (T-T ) (.000660) (1 + .00115 T )
  ;                                w                         w
  ;            Tw = Wet bulb temperature (degrees C.)
  ;            Ew = Saturated vapor pressure at temperature Tw
  ;             e = Vapor pressure in air
  ;         Press = Total barometric pressure (units same as Ew, e)
  ;             T = Air temperature (degrees C.)
  ;
  ;  e is the vapor pressure in the air, which is the vapor pressure at
  ;  the dew point temperature.  To solve for the dew point temperature,
  ;  use the formula:
  ;
  ;             e = 6.1078 * 10 ** ((Td * A)/(Td + B)) in hPa
  ;
  ;                  let C = log   (e/6.1078)
  ;                             10
  ;
  ;  Then:
  ;
  ;             C T  + C B = A T
  ;                d            d
  ;
  ;                     B*C
  ;                T =  ---     Dew point in degrees C
  ;                 d   A-C
  ;                                            where A =   7.5
  ;                                                  B = 237.3
  ;
  ;
  ;
  ;
  ; All the above saturation pressure temperature relationships are
  ; relatively uncomplicated. Here one that is more mindboggling:
  ;
  ; A saturation-pressure-curve which is valid for a total pressure of
  ; 1000 hPa. "This curve was computed by approximating the standard
  ; steam table for pure water using the least square method by a
  ; Bulgarian colleague. I experienced it to be quite exact, but I'd
  ; be glad to be corrected." (Dr Haessler)
  ;
  ; Psat  = 610.710701 + 44.4293573*t + 1.41696846*t^2 +
  ;         0.0274759545*t^3 + 2.61145937E-4*t^4 + 2.85993708E-6*t^5
  ;
  ; The pressure is in Pa, the temperature in degrees Celsius (C).
  ;
  ;
  ; Relative Humidity then is:
  ;
  ; Phi = Psteam/Psat = (Ptot/Psat)*x / ((Rair/Rsteam)+x),
  ;
  ; where x is the absolute humidity in kilogramm water per kilogramm
  ; of dry air, Rair and Rsteam are the specific gas constants for air and steam,
  ; where Rair/Rsteam has a value of 0.622.
  ;
  ; For the handling:
  ;
  ; 1. Calculate the saturation pressure at Your dew point, giving your steam pressure.
  ; 2. Calculate the saturation pressure at Your temperature.
  ; 3. Divide'em (see above) to get Your relative humidity.
  ; 4. Calculate Your absolute humidity, if desired.
  ; 5. Mail me for further informations, if necessary.
  ; 6. The reverse way is possible.
  ;
  ; For the pressure dependence of relative humidity:
  ; If air and steam behave as ideal gases, there is no pressure dependence.
  ; This is so around 1000 hPa (+-100hPa, approx.).
  ;
  ;
  ; NET reading :
  ; http://www.mindspring.com/~pjm/pmtherm.html (free psychrometer program)
  ; http://nwselp.epcc.edu/elp/wxcalcsc.html (Perl-scripts)
  ;
  ;
  ; CAUTIONS:
  ;
  ; Good psychrometers
  ;
  ; a) Air velocity
  ;
  ; k (and A) don't really become (sorta) independent of the air velocity
  ; past your wet bulb until velocities above 3 meters/ second.
  ; Velocities greater than 1 m/s are sufficient at temperatures of 60 C
  ; or more.
  ; The worse your arrangement, (less adiabatic, i.e. the more extraneous
  ; energy radiates/conducts into the water) the steeper k over velocity
  ; becomes for lower velocities. So you can compensate poor design to
  ; some extent by cranking up that fan.
  ;
  ; k and A are really device-dependent. This k (and A, of course)
  ; strictly refers to the "Assmann psychrometer" only - two radiation
  ; shields, thermal insulation, fan downstream from the thermometers. k
  ; should be similar for any well-made psychrometer.
  ;
  ; b) Adiabatic wet bulb
  ;
  ; Shield it from radiative & conductive errors, i.e. all energy to
  ; vaporize the water must come from the air and thus be reflected in
  ; thetaf.
  ;
  ; In wetting the wet bulb, use distilled water. Salty scale on your
  ; "sock" can change the vapor pressure, and will really mess
  ; measurements near zero. Use enough water to hit steady-state
  ; conditions well before you start to dry out.
  ;
  ; If you use a wick for continuous wetting, make it long enough so that
  ; conductive errors are minimized, and it is cooled to the wet bulb
  ; temperature by the time it gets near the thermometer. Make sure enough
  ; water can reach the wet bulb, so don't overdo the "long enough" part.
  ;
  ; Don't get anything but the wet bulb wet. Getting the radiation shield
  ; or the thermal insulation wet will introduce errors.
  ;
  ; Keep direct sunlight off. A great way to pump heat into your
  ; "adiabatic" system. Don't ever paint the outside black. Many
  ; commercial humidity meters are a pretty black finish. They will be
  ; sensitive to indirect sunlight (and other radiative sources). Humidity
  ; measurements are VERY sensitive to temperature!
  ;
  ; c) Supercooled water and ice below freezing
  ;
  ; Your measurement will become screwy below freezing, as you cannot
  ; really distinguish between supercooled water (evaporation) and ice
  ; (sublimation) in your wet bulb, and the vapor pressures differ. And
  ; Lueck says supercooled water can be present as low as -12 C. It
  ; suggests manually scraping the wet bulb to ensure that supercooled
  ; water turns to ice.
  ;
  ; And note that humidity measurements never are terribly accurate, 2%
  ; error in absolute hum. are pretty good, depending on where you are in
  ; terms of temp and water content. Anything that reads "relative
  ; humidity=52.783 %" is guessing (if you paid less than 100k$...:-)
  ;
  ; Thomas Prufer
  ;
  ;
  ; Wet bulb temperature is really defined by the psychrometer and is not
  ; an atmospheric water vapor property (compared with Td which has a firm
  ; definition)!!!!   The above computations assume the standard
  ; psychrometer equation, but the psychrometer constant (0.00066*P in
  ; kPa/C) is a theoretical value that is not always matched even by very
  ; good psycrchrometers.  PLEASE note this psychrometer constant depends
  ; directly on atmospheric pressure so it's value is not a "universal"
  ; constant!
  ;
  ; Terry Howell
  ;
  ;
  ; NET readings:
  ; http://www.uswcl.ars.ag.gov/exper/relhumeq.htm
  ; http://nwselp.epcc.edu/elp/rhsc.html
  ; http://storm.atmos.uiuc.edu/covis2/visualizer/help/general/rh.dwp.html
  ;
  ;
  ;
  ; 3) Examples
  ;
  ; 1. EXAMPLE      X M P L    X M P L    X M P L    X M P L    X M P L
  ;
  ; >My problem is the following. I want to calculate wetbulb temperature
  ; >(Tw) where my input is drybulb temperature (T) and relative humidity
  ; >(rH). (Pieter Haasbroek)
  ;
  ; Pieter:
  ;
  ; Your problem can be solved explicitly using the methods from Jensen et
  ; al. (1990) ASCE Manual No. 70 (see pages 176 & 177) using the
  ; following steps and equations:
  ;
  ; 1)  compute e as [ES(T)*rH/100]
  ;     where ES(T) = 0.611*EXP(17.27*T/(T+237.3)) in kPa
  ;     T is drybulb temp in C
  ;
  ;     e = (rH/100)* 0.611*EXP(17.27*T/(T+237.3))
  ;     where e is ambient vapor pressure in kPa
  ;
  ; 2)  compute dewpoint temperature (Td)
  ;     Td = [116.9+237.3ln(e)]/[16.78-ln(e)] in C
  ;
  ; 3)  compute wet bulb temperature (Tw)
  ;     Tw = [(GAMMA*T)+(DELTA*Td)]/(GAMMA+DELTA)
  ;     GAMMA = 0.00066*P where P is ambient barometric pressure in kPa
  ;     DELTA = 4098*e/(Td+237.3)^2
  ;
  ; This method should be close, especially when Tw is close to Td (DELTA
  ; should be evaluated at (Tw+Td)/2.
  ;
  ; For example:
  ;
  ;  T = 25C
  ; rH = 50%
  ; assume elev is sea level and P = 100 kPa.
  ;
  ; 1)  ES(25) = 0.611*EXP(17.27*25/(25+237.3)) = 3.17 kPa
  ;     e = (50/100)* ES(25) = 1.58 kPa
  ;
  ; 2)  Td = [116.9+237.3*ln(1.30)]/[16.78-ln(1.30)] = 13.85 C
  ;
  ; 3)  GAMMA = 0.00066*100 = 0.066 kPa/C
  ;     DELTA = 4098*(1.58)/(13.85+237.3)^2 = 0.103 kPa/C
  ;     Tw = [(0.066*25)+(0.103*13.85)]/(0.066+0.103) = 18.21 C
  ;
  ; CHECK ANSWER:
  ;
  ;     EW(Tw) = 0.611*EXP(17.27*18.21/(18.21+237.3)) = 2.09 kPa
  ;     e  = EW(Tw) - GAMMA*(T-Tw)
  ;     e  = 1.58 - 0.066*(25-18.21) = 1.64 kPa
  ;
  ; The exact answer for Tw is about 17.95C
  ;     EW(18.0) = 2.07 kPa;  e = 1.60 kPa
  ;     EW(17.9) = 2.05 kPa;  e = 1.58 kPa
  ;     EW(17.95) = 2.06 kPa; e = 1.59 kPa
  ;
  ; Thus,
  ;     ERROR  e = [(1.64 - 1.58)/1.58]*100 = 3.1%
  ;     ERROR Tw = [(18.2-17.95)/17.95]*100 = 1.4%
  ;
  ;
  ;
  ; 2. EXAMPLE      X M P L    X M P L    X M P L    X M P L
  ;
  ; >Hello:-
  ; >I am looking for the algorithm to convert wet/dry bulb temperatures to /
  ; >from rH (and moisture content as well, for that matter).
  ; >I know the Psychometric charts, but they are difficult to use accurately
  ; >in software. Anyone have a pointer to appropriate equations?
  ; >Thanks in advance! (Spehro Pefhany)
  ;
  ; Answer
  ; (I shall find a formula in SI units, please be patient, BeK)
  ;
  ; pw = psf  - p * A * (theta - thetaf)
  ;
  ; theta: dry bulb temp., Kelvin or Celsius
  ; thetaf: wet bulb temp.,   "
  ; psf: Saturation pressure at temp thetaf, see 1.), in Torr (mm Hg)
  ; pw: Vapor pressure of ambient air, in Torr (mm Hg)
  ; p: pressure of ambient air, in Torr
  ; A: optimally (see below) 0.66 * 10e-3 * (1/C)
  ;
  ; 3.) The short way round:
  ;
  ; We're in your backyard: p = 755 Torr, 0 C < theta < 50 C.
  ;
  ; pw = psf - k (theta - thetaf)
  ;
  ; phi = pw/psf
  ;
  ; phi: relative humidity.
  ; k= p*A = 0.5 Torr/degree
  ;
  ; Higher temperatures:
  ;    thetaf about 60 C: k is about 0.52
  ;    thetaf about 80 C: k is about 0.53
  ;
  ;
  ; (Formula suggested by A. Sprung, 1888)
  ;
  ;
  ;
  ; 3. EXAMPLE      X M P L    X M P L    X M P L    X M P L
  ;
  ; This question is _often_ asked:
  ; >I have the air pressure (p), the temperature (T) and the
  ; >relative humidity (rH) and want to calculate the specific humidity
  ; >(i.e. the mass of water vapour to the humid air)?
  ;
  ; First: This air pressure that you have, is actually the total pressure,
  ; i.e. it is the sum of the pressure of the dry air (pair) PLUS the share
  ; from the water vapour (pw).
  ;
  ; Then calculate the saturation pressure (ES) from one of the formulas given
  ; above.
  ;
  ; Then multiply by the relative humidity (rH). This gives you the ambient
  ; water vapour pressure, (e).
  ;
  ; Then the specific humidity is given by the following formula:
  ;
  ;         R
  ;          L        e
  ; rho =  --- -----------------
  ;         R   p + e(R / R - 1)
  ;          W         L   W
  ;
  ;
  ; WHERE:
  ;         R / R  = 0.62197   (see the example for the mixing ratio)
  ;          L   W
  ;
  ;
  ;
  ; 4. EXAMPLE      X M P L    X M P L    X M P L    X M P L
  ;
  ; > Could somebody send or post the method, or fomula, used to calculate
  ; > dewpoints.  I have hunted the local library but am unable to find it.
  ;
  ; Here it is:
  ;
  ; Td = B / ln(A * 0.622 / w p)
  ;
  ; where:
  ;
  ; B = 5420 K
  ; A = 2.53 E8 kPa
  ;
  ; w = water vapor mixig ratio
  ; p = local pressure
  ;
  ;
  ;
  ; 5. EXAMPLE      X M P L    X M P L    X M P L    X M P L
  ;
  ; >I'm wondering if anyone could please give me the formula for the
  ; >calculation of dewpoint temperature given relative humidity, current
  ; >temperature, and station pressure
  ;
  ; First calculate the saturation vap. pres. ES (Pa) at temperature T
  ; (oC):
  ;
  ; ES = 610.78 * exp {A T / (T + B) }
  ;
  ; where ES in Pa, A = 17.2694 and B = 237.3 for T>0 otherwise 265.5.
  ; Then calculate the actual vapour pressure e (Pa) using
  ;
  ; e = rH / 100 * ES
  ;
  ; where rH is the rel.hum in %. Finally invert the equation for ES since
  ; e = ES(Td). The dewpoint temperature Td (oC) is then obtained from
  ;
  ; Td = B  f / { 1 - f  }
  ;
  ; where
  ;
  ; f = ln ( e / 610.78 ) / A
  ;
  ; (Based on Monteith and Unsworth, 1990, Principles of Environmental
  ; Physics, sec.ed., Arnold, London, 291pp.  ISBN 0-7131-2931-X.
  ; Note however that their equation 2.25 for Td is wrong)
  ; N.J. Bink
  ;
  ;
  ;
  ; 6. EXAMPLE      X M P L    X M P L    X M P L    X M P L
  ;
  ; I need some help with calculating RH. Our control system allows us to read
  ; > dry bulb temp and enter the specific humidity (g/kg of dry air). We are
  ; > looking for a formula to calculate a RH setpoint to use for control. As
  ; > the dry bulb temp changes the system would calculate the new RH setpoint
  ; > to maintain the same specific humidity.
  ;
  ; I propose and easy solution.
  ; We start with the formula for the mixing ratio:
  ;
  ;         0.622 * e
  ;    w = -----------
  ;          p - e
  ;
  ;
  ; and transform it with the formulas for the Saturation vapor pressure (ES),
  ; resulting in:
  ;
  ;            w0 * p
  ;   rH = ----------------
  ;         ES(T)*(1 + w0)
  ;
  ; where:
  ; p is the total measured pressure and
  ; w0 is the specific humidity (w) at the start of the run, which is
  ; supposed to stay constant.
  ; To give an example with the same starting conditions as in the example
  ; above, see the following table:
  ;
  ; rel.
  ; err.      w'         rH'      ES(T)       T
  ; 1.1%      0.016      60%      2.645      22
  ; 1.3%      0.016      56%      2.810      23
  ; 1.4%      0.016      53%      2.985      24
  ; 1.6%      0.016      50%      3.169      25
  ; 1.8%      0.016      47%      3.363      26
  ; 2.1%      0.016      44%      3.567      27
  ; 2.3%      0.016      42%      3.781      28
  ;
  ; As you can see w' equals w0, but the relative humidity changes of course.
  ;
  ;
  ;
  ;
  ; NB
  ; By now you should be able to solve your undergraduate humidity calculations
  ; really by yourselves. But, looking at the text for the mixing ration, given
  ; above, most of you could have gained knowledge of this formula by
  ; yourselves, I guess.
  ;
  ;
  ;
  ; 4) Literature hints:
  ;
  ; For the book and paper aficionados of the readers check out this:
  ;
  ; 'If your really interested in this stuff, I (Kerry Anderson) suggest
  ; the book "Atmospheric Thermodynamics" by Irabarne and Godson."'
  ; But unfortunately I learned this book is out of stock
  ; (amazon.com). Instead I could recommend:
  ; "Fundamentals of Atmospheric Dynamics and Thermodynamics"
  ; Paperback, Amazon.com Price: $29.00; Published by
  ; World Scientific Pub Co. Publication date: May 1992
  ; ISBN: 9971978873
  ;
  ; "Most introductory texts on meteorology will have one
  ;  or two paragraphs on the matter." (K Anderson)
  ;
  ; "(Based on Monteith and Unsworth, 1990, Principles of Environmental
  ; Physics, sec.ed., Arnold, London, 291pp.  ISBN 0-7131-2931-X.
  ; Note however that their equation 2.25 for Td is wrong)."
  ; N.J. Bink
  ;
  ; "My sources (other than experience) are all German books
  ; (Thomas Prufer):"
  ; (ue equals u&uml;, BeK)
  ; Lueck, Winfired: Feuchtigkeit - Grundlagen, Messen, Regeln.
  ; Muenchen: R. Oldenbourg, 1964. Good basics.
  ;
  ; Sonntag, D.: Hygrometrie: Ein Handbuch der Feuchtigkeitsmessung in
  ; Luft und anderen Gasen. (6 vols.) Berlin: Akademie, 1966 - 1968
  ; Also contains a very detailed description of nearly everything on the
  ; market in 1966-68.
  ;
  ; Heinze, D.: Einheitliche, methodische Beschreibung von
  ; Gasfeuchte-Messverfahren. Dissertation an der Technischen Hochschule
  ; Ilmenau, 1980
  ; Comprehensive block and signal diagrams with the Laplace functions (!)
  ; of nearly all humidity measurement methods. Nearly unobtainable,
  ; unfortunately.
  ; (Thomas Prufer)
  ;
  ;
  ;
  ;
  ; 5) Committment:
  ;
  ; This ONA was collected and provided to you by Bernd Kuemmel
  ; (bek@mmf.ruc.dk).
  ;
  ; I admit to have used especially the willing help and the contributions
  ; of the of the following people:
  ;
  ; Pierre-Alain Dorange, Forrest M. Mims III, Kerry Anderson, Len Padilla,
  ; Ralf Haessler, Pieter Haasbroek, Terry Howell, David F Palmer, Thomas
  ; Prufer, N.J. Bink, Richard Harvey, Spehro Pefhany, and of course -
  ; Ilana Stern
  ;
  ; during the ongoing improvement of the ONA.
  ;
  ;
  ;                          Yours sincerely
  ;
  ;                           Bernd Kuemmel
  ;
  ;
  ;
  ; 6) Outlook:
  ;
  ; I have put other peoples warnings on psychrometers now before the
  ; examples, I have also included some NET readings peeking to other sites with
  ; information on the subject, BeK.
  ;
  ;
  ; 7) Signature:
  ;
  ;        Bernd Kuemmel + bek@mmf.ruc.dk + VOX: +45 46 75 77 81 * 2275
  ;        IMFUFA, Roskilde University Centre, PB 260, DK-4000 Roskilde
  ;          Disclaimer: They do not necessarily agree with all this.
  ;
  ;}

;- ---------------------------------------------------------------------------
;-  Documentation / Notes on Implementaiton
;-   ---------------------------------------------------------------------------

;{
  ;
  ; *** PUREBASIC IMPLEMENTATION
  ;
  ; based on a doc I found on the internet... a set of routines created / collected / referenced by schlatter and baker in 1991
  ;
  ; I've been translating (part of) them from their original fortran form into purebasic (and I'm no fortran expert, mind you :-))
  ; note that code has NOT been optimized for purebasic but has stayed as close to the original as possible for error testing
  ; and solving
  ;
  ; I have left the original documentation in as a whole in this procedure, as well as in parts with each single procedure, in the
  ; hope that might help someone
  ;
  ; this is a work in progress, not everything has been done yet, or is working entirely as it should, all help appreciated :-)
  ;
  ; I've matched the outcome to the expected outcome shown in the original code, and marked all procedures that match well
  ; With 'matches', those that failed With (obviously) 'failed'... if the original code was wrong, then ofcourse my
  ; conclusion means little :-)
  ;
  ;
  ; *** NOTES ON FORTRAN
  ;
  ; I know pretty much nothing about fortran, but the internet does, here's some quick notes that I've used to convert to purebasic
  ;
  ;   a ** b       pow( a , b)
  ;   .LT.         lesser than
  ;   .GT.         greater than
  ;
  ; *** NOTES ON VAPOUR PRESSURE, FROM WIKIPEDIA
  ;
  ; The vapour pressure of water is the pressure exerted by molecules of water vapor in gaseous form 
  ; (whether pure Or in a mixture With other gases such As air). The saturation vapour pressure is 
  ; the pressure at which water vapour is in thermodynamic equilibrium With its condensed state.
  ; At pressures higher than vapour pressure, water would condense, whilst at lower pressures it 
  ; would evaporate Or sublimate. The saturation vapour pressure of water increases With increasing
  ; temperature And can be determined With the Clausius–Clapeyron relation. The boiling point of water
  ; is the temperature at which the saturated vapour pressure equals the ambient pressure.
  ; 
  ; Calculations of the (saturation) vapour pressure of water are commonly used in meteorology.
  ; The temperature-vapour pressure relation inversely describes the relation between the boiling point
  ; of water And the pressure. This is relevant To both pressure cooking And cooking at high altitude.
  ; An understanding of vapour pressure is also relevant in explaining high altitude breathing And cavitation.
  ;
  ; *** ORIGINAL DOCUMENTATION
  ;
  ;
  ; General information:
  ; --------------------
  ; This is an index of the thermodynamic subprograms located in THERMO.OLB.  They
  ; are listed according To the general type of calculation that is desired,
  ; divided into the following categories:
  ;
  ;         (a) moisture parameters
  ;         (b) latent heat
  ;         (c) pressure
  ;         (d) temperature
  ;         (e) thickness
  ;
  ; These algorithms were collected, edited, commented, And tested by Thomas W.
  ; Schlatter And Donald V. Baker from August To October 1981 in the PROFS Program
  ; Office, NOAA Environmental Research Laboratories, Boulder, Colorado.  Where
  ; possible, credit has been given To the original author of the algorithm And a
  ; reference provided.
  ;
  ;
  ; The input/output units are As follows:
  ;
  ; Temperature                     Celsius
  ; Pressure                        millibars
  ; Relative humidity               percent
  ; Saturation specific humidity    g vapor/kg moist air
  ; Mixing ratio                    g vapor/kg dry air
  ; Thickness                       meters
  ; Precipitable water              centimeters
  ; Latent heat                     joules/kg
  ;
  ;
  ; The following symbols are used in subprogram calls:
  ;
  ; EW      water vapor pressure
  ; EQPT    equivalent potential temperature
  ; P       pressure
  ; PC      pressure at the convective condensation level
  ; PS      surface pressure
  ; RH      relative humidity
  ; T       temperature
  ; TC      temperature at the lifting condensation level
  ; TD      dew point
  ; TH      potential temperature (a dry adiabat)
  ; THW     wet bulb potential temperature (a moist adiabat)
  ; W       mixing ratio
  ; WBAR    mean mixing ratio from surface To pressure pm
  ;

  ;
  ; Index:  routines available For various calculations                                 CONVERTED TO PUREBASIC
  ; ---------------------------------------------------                                 ----------------------
  ; (A) Moisture Parameters
  ;
  ;      To Calculate:                      Available Routine(s):
  ;
  ;      1. Relative humidity               3. HUM(T,TD)                                HUM()
  ;
  ;      2. Saturation specific humidity    4. SSH(T,P)                                 SSH()
  ;
  ;      3. Saturation mixing ratio         1. a) WMR(T,P)                              WMR()
  ;                                            b) W(T,P)                                W()
  ;
  ;      4. Precipitable water              2. PRECPW(TD,P,N)                           PRECPW() - untested
  ;         (Td And P are dimensioned by N)
  ;
  ;
  ; (B) Pressure
  ;
  ;      To Calculate:                      Available Routine(s):
  ;
  ;
  ;      1. Saturation vapor pressure       1. a) ESAT(T)                               ESAT()
  ;         over liquid water                  b) ESW(T)                                ESW()
  ;                                            c) ES(T)                                 ES()
  ;                                            d) ESGG(T)                               ESGG()   ; by S.Maag
  ;                                            e) ESRW(T)                               ESRW()   ; by S.Maag
  ;                                            f) ESLO(T)                               ESLO()   ; by S.Maag
  ;
  ;      2. Saturation vapor pressure       3. a) ESICE(T)                              ESICE()  ; by S.Maag
  ;         over ice                           b) ESILO(T)                              ESILO()  ; by S.Maag

  ;      3. Pressure at Lifting             3. a) ALCL(T,TD,P)                          ALCL()
  ;         Condensation Level                 b) PCON(P,T,TC)                          PCON()
  ;                                            c) (subroutine) PTLCL(P,T,TD,PC,TC)      -
  ;
  ;      4. Pressure at Convective          4. PCCL(PM,P,T,TD,WBAR,N)                   -
  ;         Condensation Level (P, T, And
  ;         Td are dimensioned by N)
  ;
  ;
  ; (C) Temperature
  ;
  ;      To Calculate:                      Available Routine(s):
  ;
  ;     
  ;      1. Dew point                       1. a) DWPT(T,rH)                           DWPT()
  ;                                            b) DEWPT(EW)                            DEWPT()
  ;                                            c) DPT(EW)                              DPT()
  ;
  ;      2. Equivalent temperature          2. TE(T,TD,P)                              TE()       ; by. SMaag
  ;
  ;      3. Potential temperature           3. O(T,P)                                  O()
  ;
  ;      4. Equivalent potential            4. a) OS(T,P)                              OS()
  ;         temperature                        b) OE(T,TD,P)                           OE()       ; by S.Maag
  ;                                            c) EPT(T,TD,P)                          EPT()      ; by S.Maag 
  ;
  ;
  ;      5. Wet bulb temperature            5. TW(T,TD,P)                              TW()
  ;
  ;      6. Wet bulb potential              6. a) OW(T,TD,P)                           OW()
  ;         temperature                        b) POWT(T,TD,P)                         POWT()
  ;                                            c) THM(W,P)                             THM()
  ;
  ;      7. Difference in Wet Bulb Poten-   7. WOBF(T)                                 WOBF()
  ;         tial Temperatures For two
  ;         parcels of air at the same
  ;         temperature - one saturated
  ;         And the other completely dry
  ;
  ;
  ;      8. Convective temperature          8. CT(WBAR,PC,PS)                          CT()       ; by S.Maag
  ;
  ;      9. Virtual temperature             9. TV(T,TD,P)                              TV()
  ;
  ;
  ;     10. Temperature at Lifting         10. a) TCON(T,TD)                           TCON()
  ;         Condensation Level                 b) TLCL1(T,TD)                          TLCL1()      ; by S.Maag
   ;
  ;     11. Temperature along moist        11. SATLFT(THW,P)                           SATLFT()     ; by S.Maag
  ;         adiabat at given pressure
  ;
  ;     12. Temperature on a dry adiabat   12. TDA(TH,P)                               TDA()
  ;         at given pressure
  ;
  ;     13. Temperature on a moist adiabat 13. a) TSA(EQPT,P)                          TSA()
  ;         corresponding To an Equivalent     b) TMLAPS(EQPT,P)                       -
  ;         Potential Temperature "EQPT",
  ;         at given pressure
  ;
  ;     14. Temperature on a mixing ratio  14. TMR(W,P)                                TMR()
  ;         line at given pressure
  ;

  ;
  ; (D) Other Functions
  ;
  ;      To Calculate                       Available Routines:                         Converted to PureBasic by S.Maag
  ;
  ;      1. Latent Heat                     
  ;         a) Evaporization/Condensation   HEATL(T, 1)                                 HEATL(TK.d, Key.i=#TD_HEATL_KEY_EVAPORATION)
  ;
  ;         b) Melting/Freezing             HEATL(T, 2)                                 HEATL(TK.d, Key.i=#TD_HEATL_KEY_MELTING)
  ;
  ;         c) Sublimation/Deposition       HEATL(T, 3)                                 HEATL(TK.d, Key.i=#TD_HEATL_KEY_SUBLIMATION)
  ;
  ;
  ;      2. Thickness between the surface   1. Z(PT,P,T,TD,N)                           -                      -
  ;         And any other pressure level
  ;         PT in the sounding.  (P,T, And
  ;         Td are dimensioned by N.)
  ;
  ;

  ; (E) Miscellaneous Functions: not converted from Schlatter And Baker!
  ;
  ;      To Calculate                       Available Routines:                         Inmplemented in PureBasic 
  ;
  ;      1. DryToWet                        1. DryToWet(T,rH)                           DryToWet()    ; by Bernd Kuemmel
  ;         convert dry bulb to 
  ;         wet bulb temperature
  ;
  ;}

DeclareModule TD          ; ThermoDynamic
  
  EnableExplicit
  
  ;- DECLARE
  
  ; ---------------------------------------------------------------------------
  ;    Pressure conversion bar <=> Pascal  
  ; ---------------------------------------------------------------------------

  ; 1Pa = 0.00001 bar +1E-5
  ; 1bar = 100.000Pa
  ; 1mbar = 100Pa
  Macro Pa_to_bar(Pa)
    Pa * 100000  
  EndMacro
  
  Macro bar_to_Pa(bar)
    bar/100000  
  EndMacro
  
  Macro Pa_to_mbar(Pa)
    Pa * 100  
  EndMacro
  
  Macro mbar_to_Pa(mBar)
    mBar/100  
  EndMacro

  ; KEYs for LatentHeat Function HEATL(KEY, TK)
  #TD_HEATL_KEY_EVAPORATION = 1   ; HEATL KEY for: EVAPORATION/CONDENSATION
  #TD_HEATL_KEY_MELTING = 2       ; HEATL KEY for: MELTING/FREEZING
  #TD_HEATL_KEY_SUBLIMATION = 3   ; HEATL KEY for: SUBLIMATION/DEPOSITION
    
  ; A) Moisture Functions (humidity)
  Declare.d HUM(T.d, TD.d)          ; RELATIVE HUMIDITY [%] GIVEN THE TEMPERATURE T And DEW POINT TD [°C]
  Declare.d SSH(T.d, P.d)           ; SATURATION SPECIFIC HUMIDITY SSH (GRAMS OF WATER VAPOR PER KILOGRAM OF MOIST AIR)
  Declare.d W  (T.d, P.d)           ; THE MIXING RATIO (GRAMS OF WATER VAPOR PER KILOGRAM OF DRY AIR)                     
  Declare.d WMR(P.d, T.d)           ; MIXING RATIO WMR (GRAMS OF WATER VAPOR PER KILOGRAM OF DRY AIR) 

  Declare.d PRECPW(Array TD.d(1), Array P.d(1), n.i) ; TOTAL PRECIPITABLE WATER PRECPW [cm] IN A VERTICAL COLUMN OF AIR BASED UPON SOUNDING Data AT N LEVELS
  
  ; B) Pressure Functions   
  Declare.d ESAT(T.d)               ; SATURATION VAPOR PRESSURE ESAT  [mabr] OVER WATER (NORDQUIST ALGORITHM, 1973)
  Declare.d ESW (T.d)               ; SATURATION VAPOR PRESSURE ESW   [mabr] OVER WATER (HERMAN WOBUS POLYNOMIAL APPROXIMATION, -50..:100°C)
  Declare.d ES  (T.d)               ; SATURATION VAPOR PRESSURE ES    [mabr] OVER WATER (FORMULA BY BOLTON, DAVID, 1980 -35..35C°C)
  Declare.d ESGG(T.d)
  Declare.d ESRW(T.d)
  Declare.d ESLO(T)
    
  Declare.d ESICE(T.d)              ; SATURATION VAPOR PRESSURE ESICE [mabr] OVER ICE   (GOFF-GRATCH FORMULA, 1963)
  Declare.d ESILO(T.d)              ; SATURATION VAPOR PRESSURE ESILO [mabr] OVER ICE   (LOWE, PAUL R., POLYNOMIAL APPROXIMATING; 1977)
   
  Declare.d ALCL(T.d, P.d, TD.d)    ; PRESSURE ALCL [mabr] OF THE LIFTING CONDENSATION LEVEL (LCL)
  Declare.d PCON(T.d, P.d, TC.d)    ; PRESSURE PCON [mbar] AT THE LIFTED CONDENSATION LEVEL (LCL)
 
     
  ; C) Temperature Functions [°C] 
  Declare.d DWPT (T.d, rH.d)        ; DEW POINT [°C] GIVEN THE TEMPERATURE [°C] AND RELATIVE HUMIDITY [%]
  Declare.d DEWPT(EW.d)             ; DEW POINT DEWPT [°C], GIVEN THE WATER VAPOR PRESSURE EW [mabr]
  Declare.d DPT  (EW.d)             ; DEW POINT DPT   [°C], GIVEN THE WATER VAPOR PRESSURE EW [mabr]     
  
  Declare.d TE(T, P, TD)
  
  Declare.d O    (T.d, P.d)         ; POTENTIAL TEMPERATURE O [°C] AT GIVEN TEMPERATURE [°C] AND PRESSURE [mbar] BY SOLVING THE POISSON EQUATION                     
  Declare.d OS   (T.d, P.d)         ; EQUIVALENT POTENTIAL TEMPERATURE OS [°C] FOR A PARCEL OF AIR SATURATED AT TEMPERATURE [°C] And PRESSURE [mabr]           
  Declare.d OE   (T, P, TD)
  Declare.d TW   (T.d, P.d, TD.d)   ; WET-BULB TEMPERATURE TW (CELSIUS) GIVEN THE TEMPERATURE T [°C], DEW POINT TD [°C] AND PRESSURE P [mabr]                       
  Declare.d OW   (T.d, P.d, TD.d)   ; WET-BULB POTENTIAL TEMPERATURE OW [°C] GIVEN THE TEMPERATURE T [°C], DEW POINT TD [°C], And PRESSURE P [mabr]
  Declare.d POWT (T.d, P.d, TD.d)   ; YIELDS WET-BULB POTENTIAL TEMPERATURE POWT [°C]
  Declare.d THM  (T.d, P.d)         ; WET-BULB POTENTIAL TEMPERATURE THM [°C] CORRESPONDING TO A PARCEL OF AIR SATURATED AT TEMPERATURE T [°C] AND PRESSURE P [mabr]
  Declare.d WOBF (T.d)              ; DIFFERENCE OF THE WET-BULB POTENTIAL TEMPERATURES [°C] FOR SATURATED AND DRY AIR GIVEN THE TEMPERATURE [°C]
  
  Declare.d CT(WBAR, PC, PS)
  Declare.d TV(T, P, TD)
  
  Declare.d TCON (T.d, TD.d)        ; TEMPERATURE TCON [°C] AT THE LIFTING CONDENSATION LEVEL, GIVEN THE TEMPERATURE T [°C] And THE DEW POINT D [°C]
  Declare.d TLCL1(T, TD)
  Declare.d SATLFT(THW, P)
    
    Declare.d TDA  (O.d, P.d)         ; TEMPERATURE TDA [°C] ON A DRY ADIABAT AT PRESSURE [mbar]  
  Declare.d TSA  (OS.d, P.d )       ; TEMPERATURE TSA [°C] ON A SATURATION ADIABAT AT PRESSURE P [mabr]                     
  Declare.d TMR  (W.d, P.d)         ; TEMPERATURE [°C] ON A MIXING RATIO LINE W [g/KG] AT PRESSURE P [mbar]                    
  
  ; D) Other Heat Functions  
  Declare.d HEATL(TK.d, Key.i=#TD_HEATL_KEY_EVAPORATION) ; LATENT HEAT OF EVAPORATION/CONDENSATION, MELTING/FREEZING, SUBLIMATION/DEPOSITION
 
  ; E) Miscellaneous Functions ;
  Declare.d DryToWet(T.d, rH.d)               ; DRY BULB TO WET BULB TEMPERATURE            ; by Bernd Kuemmel
    
EndDeclareModule

;- ---------------------------------------------------------------------------
;- MODULE
;   ---------------------------------------------------------------------------

Module TD         ; ThermoDynamic
  EnableExplicit  
      
  #TD_ES0 = 6.1121           ; Guildner, Johnson, and Jones 1976. highly accurate measurements of the vapor pressure 
  #TD_ES0_OLD = 6.10752      ; 1971, Wexler and Greenspan equation

  #TD_CTA = 273.15            ; Offset Kelvin to Celsius; Kelvon = Celsius -273.15°C
  
  ;- ---------------------------------------------------------------------------
  ;-  A) Moisture Functions 
  ;- ---------------------------------------------------------------------------

  Procedure.d HUM(T.d, TD.d) 
  ; ======================================================================
  ; NAME: HUM
  ; DESC: relative humidity
  ; VAR(T.d): Temeprature [°C]
  ; VAR(TD.d): dew point [°C]
  ; RET.d: relative humidity rH [%]
  ; ======================================================================
   Protected HUM.d
    ;
    ; *** matches
    ;
    ;       FUNCTION HUM(T,TD)
    ;
    ;   THIS FUNCTION RETURNS RELATIVE HUMIDITY (%) GIVEN THE
    ;   TEMPERATURE T And DEW POINT TD (CELSIUS).  As CALCULATED HERE,
    ;   RELATIVE HUMIDITY IS THE RATIO OF THE ACTUAL VAPOR PRESSURE To
    ;   THE SATURATION VAPOR PRESSURE.
    ;
    ;       HUM= 100.*(ESAT(TD)/ESAT(T))
    ;
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn  ESAT(TD) / ESAT(T) * 100                                       
  EndProcedure
  
  Procedure.d SSH(T.d, P.d)         ; Paramater order changed!
  ; ======================================================================
  ; NAME: SSH
  ; DESC: saturation specific humidity
  ; VAR(T.d): Temeprature [°C]
  ; VAR(P.d): Pressure [mbar]
  ; RET.d: gramms of water per kg of moist air [g/kg]
  ; ======================================================================
   Protected  W.d, Q.d
    ;
    ; *** matches
    ;
    ;       FUNCTION SSH(P,T)
    ;   THIS FUNCTION RETURNS SATURATION SPECIFIC HUMIDITY SSH (GRAMS OF
    ;   WATER VAPOR PER KILOGRAM OF MOIST AIR) GIVEN THE PRESSURE P
    ;   (MILLIBARS) And THE TEMPERATURE T (CELSIUS). THE EQUATION IS GIVEN
    ;   IN STANDARD METEOROLOGICAL TEXTS. If T IS DEW Point (CELSIUS), THEN
    ;   SSH RETURNS THE ACTUAL SPECIFIC HUMIDITY.
    ;   COMPUTE THE DIMENSIONLESS MIXING RATIO.
    ;
    ;       W = .001*WMR(P, T)
    ;
    W = 0.001 * WMR(P, T)
    ;
    ;   COMPUTE THE DIMENSIONLESS SATURATION SPECIFIC HUMIDITY.
    ;
    ;       Q = W/(1.+W)
    ;       SSH = 1000.*Q
    ;
    Q = W / (1 + W)
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn 1000 * Q                                         
  EndProcedure
  
  Procedure.d W(T.d, P.d)                                 
  ; ======================================================================
  ; NAME: W
  ; DESC: mixing ration in grams of water per kilogram dry air
  ; VAR(T.d): Temperature in Celsius
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: g Water / kg DryAir
  ; ======================================================================
    
    Protected W.d, x.d
    ;
    ; *** matches
    ;
    ;       FUNCTION W(T,P)
    ;
    ;  THIS FUNCTION RETURNS THE MIXING RATIO (GRAMS OF WATER VAPOR PER
    ;  KILOGRAM OF DRY AIR) GIVEN THE DEW Point (CELSIUS) And PRESSURE
    ;  (MILLIBARS). If THE TEMPERTURE  IS INPUT INSTEAD OF THE
    ;  DEW POINT, THEN SATURATION MIXING RATIO (SAME UNITS) IS RETURNED.
    ;  THE FORMULA IS FOUND IN MOST METEOROLOGICAL TEXTS.
    ;
    ;         X= ESAT(T)
    ;
    x = ESAT(T)
    ;
    ;         W= 622.*X/(P-X)
    ;
    W = 622 * x / (P - x)
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn W                                           
  EndProcedure
  
  Procedure.d WMR(P.d, T.d)   ; Paramater order changed!
  ; ======================================================================
  ; NAME: WMR
  ; DESC: WaterMixingRatio : mixing ratio of gramm water per kilogram air
  ; VAR(P.d): Pressure [mbar]
  ; VAR(T.d): Temperature [°C] 
  ; RET.d: 
  ; ======================================================================
    Protected x.d, wfw.d, fwesw.d, r.d, efs.d
    ;
    ; *** matches
    ;
    ;       FUNCTION WMR(P, T)
    ;
    ;   THIS FUNCTION APPROXIMATES THE MIXING RATIO WMR (GRAMS OF WATER
    ;   VAPOR PER KILOGRAM OF DRY AIR) GIVEN THE PRESSURE P (MB) And THE
    ;   TEMPERATURE T (CELSIUS). THE FORMULA USED IS GIVEN ON P. 302 OF THE
    ;   SMITHSONIAN METEOROLOGICAL TABLES BY ROLAND List (6TH EDITION).
    ;
    ;       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ;       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;   EPS = RATIO OF THE MEAN MOLECULAR WEIGHT OF WATER (18.016 G/MOLE)
    ;         To THAT OF DRY AIR (28.966 G/MOLE)
    ;
    ;       Data EPS/0.62197/
    ;
    #eps = 0.62197
    ;
    ;   THE Next TWO LINES CONTAIN A FORMULA BY HERMAN WOBUS For THE
    ;   CORRECTION FACTOR WFW For THE DEPARTURE OF THE MIXTURE OF AIR
    ;   And WATER VAPOR FROM THE IDEAL GAS LAW. THE FORMULA FITS VALUES
    ;   IN TABLE 89, P. 340 OF THE SMITHSONIAN METEOROLOGICAL TABLES,
    ;   BUT ONLY For TEMPERATURES And PRESSURES NORMALLY ENCOUNTERED IN
    ;   IN THE ATMOSPHERE.
    ;
    ;       X = 0.02*(T-12.5+7500./P)
    ;
    x = 0.02 * (T - 12.5 + 7500 / P)
    ;
    ;       WFW = 1.+4.5E-06*P+1.4E-03*X*X
    ;
    wfw = 1 + 4.5e-06 * P + 1.4E-03 * x * x
    ;
    ;       FWESW = WFW*ESW(T)
    ;
    fwesw = wfw * ESW(T)
    ;
    ;       R = EPS*FWESW/(P-FWESW)
    ;
    r = #eps * fwesw / ( P - fwesw )
    ;
    ;   CONVERT R FROM A DIMENSIONLESS RATIO To GRAMS/KILOGRAM.
    ;
    ;       WMR = 1000.*R
    ;       Return
    ;       End
         
    ProcedureReturn 1000 * r                                         
  EndProcedure
  
  Procedure.d PRECPW(Array TD.d(1), Array P.d(1), n.i)
  ; ======================================================================
  ; NAME: PRECPW
  ; DESC: total precipitable water
  ; VAR(Array TD.d(1)): dew point [°C]
  ; VAR(Array  P.d(1)): Pressure [mbar]
  ; VAR(n.i):
  ; RET.d: Waterlevel [cm]
  ; ======================================================================
    Protected  g.d, pw.d, nl.i, wbot.d, wtop.d, i.i, W.d, wl.d, ql.d, dp.d
    ;
    ; *** untested
    ;
    ;       FUNCTION PRECPW(TD,P,N)
    ;
    ;   THIS FUNCTION COMPUTES TOTAL PRECIPITABLE WATER PRECPW (CM) IN A
    ;   VERTICAL COLUMN OF AIR BASED UPON SOUNDING Data AT N LEVELS:
    ;          TD = DEW Point (CELSIUS)
    ;          P = PRESSURE (MILLIBARS)
    ;   CALCULATIONS ARE DONE IN CGS UNITS.
    ;
    ;       DIMENSION TD(N),P(N)
    ;
    ;   G = ACCELERATION DUE To THE EARTH'S GRAVITY (CM/S**2)
    ;
    ;       Data G/980.616/
    ;
    g = 980.616
    ;
    ;   INITIALIZE VALUE OF PRECIPITABLE WATER
    ;
    ;       PW = 0.
    ;       NL = N-1
    ;
    pw = 0
    nl = n-1
    ;
    ; C   CALCULATE THE MIXING RATIO AT THE LOWEST LEVEL.
    ;
    ;         WBOT = WMR(P(1),TD(1))
    ;
    wbot = WMR(P(1), TD(1))
    ;
    ;         DO 5 I=1,NL
    ;         WTOP = WMR(P(I+1),TD(I+1))
    ;
    For i = 1 To nl
      wtop = WMR(P(i+1), TD(i+1) )
      ;
      ;   CALCULATE THE LAYER-MEAN MIXING RATIO (G/KG).
      ;
      ;         W = 0.5*(WTOP+WBOT)
      ;
      W = 0.5 * ( wtop + wbot )
      ;
      ;   MAKE THE MIXING RATIO DIMENSIONLESS.
      ;
      ;       WL = .001*W
      ;
      wl = 0.001 * W
      ;
      ;   CALCULATE THE SPECIFIC HUMIDITY.
      ;
      ;       QL = WL/(WL+1.)
      ;
      ql = wl / (wl + 1)
      ;
      ;   THE FACTOR OF 1000. BELOW CONVERTS FROM MILLIBARS To DYNES/CM**2.
      ;
      ;       DP = 1000.*(P(I)-P(I+1))
      ;       PW = PW+(QL/G)*DP
      ;       WBOT = WTOP
      ;   5   Continue
      ;
      dp = 1000 * ( P(i) - P(i+1) )
      pw = pw + ( ql / g ) * dp
      wbot = wtop
    Next i
    
    ;         PRECPW = PW
    ;         Return
    ;         End
  
    ProcedureReturn pw                                      
  EndProcedure
    
  ;- ---------------------------------------------------------------------------
  ;-  B) Pressure Functions 
  ;- ---------------------------------------------------------------------------
  
  Procedure.d ESAT(T.d)       ;   (NORDQUIST ALGORITHM, 1973)   
  ; ======================================================================
  ; NAME: ESAT
  ; DESC: Saturation vapor pressure over water
  ; VAR(T.d): Temperature in Celsius
  ; RET.d: ESAT [mbar]
  ; ======================================================================
    Protected TK.d , P.d , ESAT.d , p1.d , p2.d , c1.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ESAT(T)
    ;   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER
    ;   WATER (MB) GIVEN THE TEMPERATURE (CELSIUS).
    ;   THE ALGORITHM IS DUE To NORDQUIST, W.S.,1973: "NUMERICAL APPROXIMA-
    ;   TIONS OF SELECTED METEORLOLGICAL PARAMETERS For CLOUD PHYSICS PROB-
    ;   LEMS," ECOM-5475, ATMOSPHERIC SCIENCES LABORATORY, U.S. ARMY
    ;   ELECTRONICS COMMAND, WHITE SANDS MISSILE RANGE, NEW MEXICO 88002.
    ;
    ;         TK = T+273.15
    ;
    TK = T + #TD_CTA
    ;
    ;         P1 = 11.344-0.0303998*TK
    ;
    p1 = 11.344 - 0.0303998 * TK
    ;
    ;         P2 = 3.49149-1302.8844/TK
    ;
    p2 = 3.49149 - 1302.8844 / TK
    ;
    ;         C1 = 23.832241-5.02808*ALOG10(TK)
    ;
    c1 = 23.832241 - 5.028208 * Log10(TK)
    ;
    ;         ESAT = 10.**(C1-1.3816E-7*10.**P1+8.1328E-3*10.**P2-2949.076/TK)
    ;
    ESAT = Pow(10, (c1 - 1.3816E-7 * Pow(10, p1) + 8.1328E-3 * Pow(10, p2) - 2949.076 / TK ))
    
     ProcedureReturn ESAT                                        
  EndProcedure
  
  Procedure.d ESW(T.d)  ; (HERMAN WOBUS POLYNOMIAL APPROXIMATION, -50..:100°C)
  ; ======================================================================
  ; NAME: ESW
  ; DESC: Saturation vapor pressure over water
  ; VAR(T.d): Temperature [°C] 
  ; RET.d: Pressure [Pa]
  ; ======================================================================
    Protected ESW.d, eso.d, pol.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ESW(T)
    ;
    ;   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE ESW (MILLIBARS)
    ;   OVER LIQUID WATER GIVEN THE TEMPERATURE T (CELSIUS). THE POLYNOMIAL
    ;   APPROXIMATION BELOW IS DUE To HERMAN WOBUS, A MATHEMATICIAN WHO
    ;   WORKED AT THE NAVY WEATHER RESEARCH FACILITY, NORFOLK, VIRGINIA,
    ;   BUT WHO IS NOW RETIRED. THE COEFFICIENTS OF THE POLYNOMIAL WERE
    ;   CHOSEN To FIT THE VALUES IN TABLE 94 ON PP. 351-353 OF THE SMITH-
    ;   SONIAN METEOROLOGICAL TABLES BY ROLAND List (6TH EDITION). THE
    ;   APPROXIMATION IS VALID For -50 < T < 100C.
    ;
    ;       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ;       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;   ES0 = SATURATION VAPOR RESSURE OVER LIQUID WATER AT 0C
    ;
    ;       Data ES0/6.1078/
    ;
    eso = 6.1078
    ;
    ;       POL = 0.99999683       + T*(-0.90826951E-02 +
    ;    1     T*(0.78736169E-04   + T*(-0.61117958E-06 +
    ;    2     T*(0.43884187E-08   + T*(-0.29883885E-10 +
    ;    3     T*(0.21874425E-12   + T*(-0.17892321E-14 +
    ;    4     T*(0.11112018E-16   + T*(-0.30994571E-19)))))))))
    ;
    ;
    pol = T * ( 0.11112018E-16 + T * (-0.30994571E-19 ))
    pol = T * ( 0.21874425E-12 + T * (-0.17892321E-14 + pol ))
    pol = T * ( 0.43884187E-08 + T * (-0.29883885E-10 + pol ))
    pol = T * ( 0.78736169E-04 + T * (-0.61117958E-06 + pol ))
    pol = 0.99999683 + T * ( -0.90826951E-02 + pol )
    ;
    ;       ESW = ES0/POL**8
    ;
    ESW = eso / Pow(pol , 8)
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn ESW                                         
  EndProcedure
  
  Procedure.d ES(T.d)       ; (FORMULA BY BOLTON, DAVID, 1980 -35..35C°C)
  ; ======================================================================
  ; NAME: ES
  ; DESC: saturation vapor pression over liquid water
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Pressure [mbar]
  ; ======================================================================
    Protected ES.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ES(T)
    ;
    ;   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE ES (MB) OVER
    ;   LIQUID WATER GIVEN THE TEMPERATURE T (CELSIUS). THE FORMULA APPEARS
    ;   IN BOLTON, DAVID, 1980: "THE COMPUTATION OF EQUIVALENT POTENTIAL
    ;   TEMPERATURE," MONTHLY WEATHER REVIEW, VOL. 108, NO. 7 (JULY),
    ;   P. 1047, EQ.(10). THE QUOTED ACCURACY IS 0.3% Or BETTER For
    ;   -35 < T < 35C.
    ;
    ;       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ;       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;   ES0 = SATURATION VAPOR PRESSURE OVER LIQUID WATER AT 0C
    ;
    ;       Data ES0/6.1121/
    ;       ES = ES0*Exp(17.67*T/(T+243.5))
    ;       Return
    ;       End
    ;
    ES = 6.1121 * Exp( 17.67 * T / ( T + 243.5 ))
    ;
    ProcedureReturn ES                                          
  EndProcedure  
  
  Procedure.d ESGG(T.d)

    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER LIQUID
    ; C   WATER ESGG (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE
    ; C   FORMULA USED, DUE To GOFF And GRATCH, APPEARS ON P. 350 OF THE
    ; C   SMITHSONIAN METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963,
    ; C   BY ROLAND List.
    ;
    ;         Data CTA,EWS,TS/273.15,1013.246,373.15/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ; C   EWS = SATURATION VAPOR PRESSURE (MB) OVER LIQUID WATER AT 100C
    ; C   TS = BOILING POINT OF WATER (K)
    ;
    ;         Data C1,      C2,      C3,      C4,       C5,       C6
    ;      1  / 7.90298, 5.02808, 1.3816E-7, 11.344, 8.1328E-3, 3.49149 /
    ;         TK = T+CTA
     
    ; C   GOFF-GRATCH FORMULA
    ;
    ;         RHS = -C1*(TS/TK-1.)+C2*ALOG10(TS/TK)-C3*(10.**(C4*(1.-TK/TS))
    ;      1        -1.)+C5*(10.**(-C6*(TS/TK-1.))-1.)+ALOG10(EWS)
    ;         ESW = 10.**RHS
    ;         If (ESW.LT.0.) ESW = 0.
    ;         ESGG = ESW
    ;         Return
    ;         End
    
    Protected.d TK, RHS, ESW, TS
    #C1_ =  7.90298
    #C2_ =  5.02808
    #C3_ =  1.3816E-7
    #C4_ = 11.344
    #C5_ =  8.1328E-3
    #C6_ =  3.49149
    #EWS_ = 1013.246    ; SATURATION VAPOR PRESSURE (MB) OVER LIQUID WATER AT 100C
    
    TS = 100 + #TD_CTA  ; Boiling Point of Water
    TK = T + #TD_CTA    ; Temperature K
    
    RHS - #C1_ * (TS/TK-1.)
    RHS + #C2_ * Log10(TS/TK)
    RHS - #C3_ * Pow(10, ( #C4_ * (1 - TK/TS) ) -1)
    RHS + #C5_ * Pow(10, (-#C6_ * (TS/TK - 1) ) -1) + Log10(#EWS_)
    
    ESW = Pow(10, RHS)
    
    If ESW < 0 : ESW = 0 : EndIf
    
    ProcedureReturn ESW
  EndProcedure
  
  Procedure.d ESRW(T.d)
    
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER LIQUID
    ; C   WATER ESRW (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE
    ; C   FORMULA USED IS DUE To RICHARDS, J.M., 1971: SIMPLE EXPRESSION
    ; C   For THE SATURATION VAPOUR PRESSURE OF WATER IN THE RANGE -50 To
    ; C   140C, BRITISH JOURNAL OF APPLIED PHYSICS, VOL. 4, PP.L15-L18.
    ; C   THE FORMULA WAS QUOTED MORE RECENTLY BY WIGLEY, T.M.L.,1974:
    ; C   COMMENTS ON 'A SIMPLE BUT ACCURATE FORMULA FOR THE SATURATION
    ; C   VAPOR PRESSURE OVER LIQUID WATER,' JOURNAL OF APPLIED METEOROLOGY,
    ; C   VOL. 13, NO. 5 (AUGUST) P.606.
    ;
    ;         Data CTA,TS,EWS/273.15,373.15,1013.25/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ; C   TS = TEMPERATURE OF THE BOILING POINT OF WATER (K)
    ; C   EWS = SATURATION VAPOR PRESSURE OVER LIQUID WATER AT 100C
    ;
    ;         Data C1,     C2,     C3,     C4
    ;      1  / 13.3185,-1.9760,-0.6445,-0.1299 /
    ;         TK = T+CTA
    ;         X = 1.-TS/TK
    ;         PX = X*(C1+X*(C2+X*(C3+C4*X)))
    ;         VP = EWS*Exp(PX)
    ;         If (VP.LT.0) VP = 0.
    ;         ESRW = VP
    ;         Return
    ;         End
    
    Protected.d TK, TS, X, PX, VP
    
    #_C1_ = 13.3185
    #_C2_ = -1.9760
    #_C3_ = -0.6445
    #_C4_ = -0.1299
    #_EWS_ = 1013.246    ; SATURATION VAPOR PRESSURE (MB) OVER LIQUID WATER AT 100C

    TS = 100 + #TD_CTA  ; Boiling Point of Water
    TK = T + #TD_CTA    ; Temperature K
    
    X = 1 - TS/TK
    PX = X * ( #_C1_ + X*(#_C2_ + X*(#_C3_ + #_C4_*X)))
    VP = #_EWS_ * Exp(PX)
    
    If VP < 0 : VP = 0 : EndIf
    ProcedureReturn VP
  EndProcedure
  
  Procedure.d ESLO(T)
    
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER LIQUID
    ; C   WATER ESLO (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE
    ; C   FORMULA IS DUE To LOWE, PAUL R.,1977: AN APPROXIMATING POLYNOMIAL
    ; C   For THE COMPUTATION OF SATURATION VAPOR PRESSURE, JOURNAL OF APPLIED
    ; C   METEOROLOGY, VOL 16, NO. 1 (JANUARY), PP. 100-103.
    ; C   THE POLYNOMIAL COEFFICIENTS ARE A0 THROUGH A6.
    ;
    ;         Data A0,A1,A2,A3,A4,A5,A6
    ;      1  /6.107799961,     4.436518521E-01, 1.428945805E-02,
    ;      2   2.650648471E-04, 3.031240396E-06, 2.034080948E-08,
    ;      3   6.136820929E-11/
    ;         ES = A0+T*(A1+T*(A2+T*(A3+T*(A4+T*(A5+A6*T)))))
    ;         If (ES.LT.0.) ES = 0.
    ;         ESLO = ES
    ;         Return
    ;         End
    
    Protected.d ES
    #A0_ = 6.107799961         ; ES0 SATURATION VAPOR PRESSURE (MB) OVER LIQUID WATER AT 0C
    #A1_ = 4.436518521E-01
    #A2_ = 1.428945805E-02
    #A3_ = 2.650648471E-04
    #A4_ = 3.031240396E-06
    #A5_ = 2.034080948E-08
    #A6_ = 6.136820929E-11
    
    ES = #A0_ + T*(#A1_ + T*(#A2_ + T*(#A3_+ T *(#A4_ + T*(#A5_ + #A6_*T)))))
    If ES < 0 : ES = 0 : EndIf
    
    ProcedureReturn ES
  EndProcedure
    
  Procedure.d ESICE(T.d)   ; (GOFF-GRATCH FORMULA, 1963)
  ; ======================================================================
  ; NAME: ESICE
  ; DESC: Saturation vapor pressure over ice
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Pressure [mbar]
  ; ======================================================================
   
    #EIS = 6.1071 ; SATURATION VAPOR PRESSURE (mbar) OVER A WATER-ICE MIXTURE AT 0°C
    #C1 = 9.09718
    #C2 = 3.56654
    #C3 = 0.876793
    
    Protected.d TF, TK, RHS, ESI
    
    ; 
    ;    THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE With RESPECT To
    ;    ICE ESICE (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS).
    ;    THE FORMULA USED IS BASED UPON THE INTEGRATION OF THE CLAUSIUS-
    ;    CLAPEYRON EQUATION BY GOFF And GRATCH.  THE FORMULA APPEARS ON P.350
    ;    OF THE SMITHSONIAN METEOROLOGICAL TABLES, SIXTH REVISED EDITION,
    ;    1963.
    
    ;         Data CTA,EIS/273.15,6.1071/
    ; 
    ;    CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ;    EIS = SATURATION VAPOR PRESSURE (MB) OVER A WATER-ICE MIXTURE AT 0C
    ; 
    ;         Data C1,C2,C3/9.09718,3.56654,0.876793/
    ; 
    ;    C1,C2,C3 = EMPIRICAL COEFFICIENTS IN THE GOFF-GRATCH FORMULA
    ; 
    ;         If (T.LE.0.) GO To 5
    ;         ESICE = 99999.
    ;         WRITE(6,3)ESICE
    ;         UNLOCK (6)
    ;     3   FORMAT(' SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED',
    ;     1         /' FOR TEMPERATURE > 0C. ESICE =',F7.0)
    ;         Return
    ;     5   Continue
    ; 
    ;    TF FREEZING POINT OF WATER (K)
    ;         TF = CTA
    ;         TK = T+CTA
    ; 
    ;    GOFF-GRATCH FORMULA
    ; 
    ;         RHS = -C1*(TF/TK-1.)-C2*ALOG10(TF/TK)+C3*(1.-TK/TF)+ALOG10(EIS)
    ;         ESI = 10.**RHS
    ;         If (ESI.LT.0.) ESI = 0.
    ;         ESICE = ESI
    ;         Return
    ;         End
  
    If T < 0
      ; SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED! TEMPERTURE TO HIGH!
      ProcedureReturn NaN()   ; Not a Number or Infinity() of a float or double
      ; you can test the validty of Calculation in your Code with PureBasic Command IsNaN() - Is_Not_a_Number!
    Else 
      
      TF = #TD_CTA         ; FREEZING POINT OF WATER (K)
      TK = T + #TD_CTA     ; Temperatur T °C => T Kelvin
      
      ; GOFF-GRATCH FORMULA
  
      RHS = -#C1*(TF/TK -1) - #C2 * Log10(TF/TK) + #C3*(1-TK/TF) + Log10(#EIS)
      ESI = Pow(10, RHS)
      
      If ESI < 0 : ESI = 0 : EndIf
      
      ProcedureReturn ESI
      
    EndIf
    
   EndProcedure
      
  Procedure.d ESILO(T.d)  ; (LOWE, PAUL R., POLYNOMIAL APPROXIMATING; 1977)
  ; ======================================================================
  ; NAME: ESILO
  ; DESC: Saturation vapor pressure over ice
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Pressure [mbar]
  ; ======================================================================
     
    #A0=6.109177956
    #A1=5.034698970E-01
    #A2=1.886013408E-02
    #A3=4.176223716E-04
    #A4=5.824720280E-06     
    #A5=4.838803174E-08
    #A6=1.838826904E-10
   
      ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER ICE
      ; C   ESILO (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE FORMULA
      ; C   IS DUE To LOWE, PAUL R., 1977: AN APPROXIMATING POLYNOMIAL For 
      ; C   THE COMPUTATION OF SATURATION VAPOR PRESSURE, JOURNAL OF APPLIED
      ; C   METEOROLOGY, VOL. 16, NO. 1 (JANUARY), PP. 100-103.
      ; C   THE POLYNOMIAL COEFFICIENTS ARE A0 THROUGH A6.
      ; 
      ;         Data A0,A1,A2,A3,A4,A5,A6
      ;      1  /6.109177956,     5.034698970E-01, 1.886013408E-02,
      ;      2   4.176223716E-04, 5.824720280E-06, 4.838803174E-08,
      ;      3   1.838826904E-10/
      ;         If (T.LE.0.) GO To 5
      ;         ESILO = 9999.
      ;         WRITE(6,3)ESILO
      ;         UNLOCK (6)
      ;      3   FORMAT(' SATURATION VAPOR PRESSURE OVER ICE IS UNDEFINED FOR',
      ;      1  /' TEMPERATURE > 0C. ESILO =',F6.0)
      ;         Return
      ;      5  Continue
      ;         ESILO = A0+T*(A1+T*(A2+T*(A3+T*(A4+T*(A5+A6*T)))))
      ;         Return
      ;         End

    If T < 0
      ; SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED! TEMPERTURE TO HIGH!
      ProcedureReturn NaN()   ; Not a Number or Infinity() of a float or double
      ; you can test the validty of Calculation in your Code with PureBasic Command IsNaN() - Is_Not_a_Number!
    Else 
      ProcedureReturn #A0+T*(#A1+T*(#A2+T*(#A3+T*(#A4+T*(#A5+#A6*T)))))
    EndIf
        
  EndProcedure
  
  Procedure.d ALCL(T.d, P.d, TD.d) ; Paramater order changed! from (T,TD,P)
  ; ======================================================================
  ; NAME: ALCL
  ; DESC: pressure of the lifting condensation level
  ; VAR(T.d): Temperature [°C] 
  ; VAR(TD.d): 
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Pressure [Pa]
  ; ======================================================================
    Protected aw.d, ao.d, pi.d, i.i, x.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ALCL(T,TD,P)
    ;
    ;   THIS FUNCTION RETURNS THE PRESSURE ALCL (MB) OF THE LIFTING CONDEN-
    ;   SATION LEVEL (LCL) For A PARCEL INITIALLY AT TEMPERATURE T (CELSIUS)
    ;   DEW POINT TD (CELSIUS) And PRESSURE P (MILLIBARS). ALCL IS COMPUTED
    ;   BY AN ITERATIVE Procedure DESCRIBED BY EQS. 8-12 IN STIPANUK (1973),
    ;   PP.13-14.
    ;   DETERMINE THE MIXING RATIO LINE THROUGH TD And P.
    ;
    ;         AW = W(TD,P)
    ;
    aw = W(TD, P)
    ;
    ;   DETERMINE THE DRY ADIABAT THROUGH T And P.
    ;
    ;         AO = O(T,P)
    ;
    ao = O(T, P)
    ;
    ;   ITERATE To LOCATE PRESSURE PI AT THE INTERSECTION OF THE TWO
    ;   CURVES. PI HAS BEEN SET To P For THE INITIAL GUESS.
    ;
    ;  3      Continue
    ;            PI = P
    ;            DO 4 I= 1,10
    ;               X= .02*(TMR(AW,PI)-TDA(AO,PI))
    ;               If (Abs(X).LT.0.01) GO To 5
    ;  4            PI= PI*(2.**(X))
    ;  5         ALCL= PI
    ;         Return
    ;         End
    ;
    pi = P
    For i = 1 To 10
      x = 0.02 * (TMR(aw, pi) - TDA(ao, pi))
      If ( Abs(x) < 0.01 )
        Break
      EndIf
      pi = pi * Pow(2, x)
    Next i
    
    ProcedureReturn pi
  EndProcedure
       
  Procedure.d PCON(T.d, P.d, TC.d)   ; Paramater order changed!
  ; ======================================================================
  ; NAME: PCON
  ; DESC: PRESSURE PCON (MB) AT THE LIFTED CONDENSATION LEVEL,
  ; DESC: GIVEN THE INITIAL PRESSURE P (MB) And TEMPERATURE T (CELSIUS) AT THE
  ; VAR(P.d] Pressure [mbar]
  ; VAR(T.d): Temeprature [°C]
  ; VAR(TC.d): Temeprature [°C]  
  ; RET.d: Pressure [mbar]
  ; ======================================================================
    
    Protected PCON.d, akapi.d, TK.d, tck.d
    
    ;         FUNCTION PCON(P,T,TC)
    ;
    ;   THIS FUNCTION RETURNS THE PRESSURE PCON (MB) AT THE LIFTED CONDENSA-
    ;   TION LEVEL, GIVEN THE INITIAL PRESSURE P (MB) And TEMPERATURE T
    ;   (CELSIUS) OF THE PARCEL And THE TEMPERATURE TC (CELSIUS) AT THE
    ;   LCL. THE ALGORITHM IS EXACT.  IT MAKES USE OF THE FORMULA For THE
    ;   POTENTIAL TEMPERATURES CORRESPONDING To T AT P And TC AT PCON.
    ;   THESE TWO POTENTIAL TEMPERATURES ARE EQUAL.
    ;
    ;       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ;       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; 
    ;         Data AKAPI/3.5037/
    ;
    #akapi = 3.5037
    ;
    ;   AKAPI = (SPECIFIC HEAT AT CONSTANT PRESSURE For DRY AIR) /
    ;           (GAS CONSTANT For DRY AIR)
    ;
    ;   CONVERT T And TC To KELVIN TEMPERATURES.
    ;
    ;         TK = T+273.15
    ;         TCK = TC+273.15
    ;         PCON = P*(TCK/TK)**AKAPI
    ;         Return
    ;         End
    ;
    TK = T + #TD_CTA
    tck = TC + #TD_CTA
    PCON = P * Pow( (tck/TK), #akapi)
    ;
    ProcedureReturn PCON
  EndProcedure
  
  Procedure.d PCCL(PM, Array P(1), Array T(1), Array TD(1), WBAR, N)

    ; C   THIS FUNCTION RETURNS THE PRESSURE AT THE CONVECTIVE CONDENSATION
    ; C   LEVEL GIVEN THE APPROPRIATE SOUNDING Data.
    ; C   ON INPUT:
    ; C       P = PRESSURE (MILLIBARS). NOTE THAT P(I).GT.P(I+1).
    ; C       T = TEMPERATURE (CELSIUS)
    ; C       TD = DEW Point (CELSIUS)
    ; C       N = NUMBER OF LEVELS IN THE SOUNDING And THE DIMENSION OF
    ; C           P, T And TD
    ; C       PM = PRESSURE (MILLIBARS) AT UPPER BOUNDARY OF THE LAYER For
    ; C            COMPUTING THE MEAN MIXING RATIO. P(1) IS THE LOWER
    ; C            BOUNDARY.
    ; C   ON OUTPUT:
    ; C       PCCL = PRESSURE (MILLIBARS) AT THE CONVECTIVE CONDENSATION LEVEL
    ; C       WBAR = MEAN MIXING RATIO (G/KG) IN THE LAYER BOUNDED BY
    ; C              PRESSURES P(1) AT THE BOTTOM And PM AT THE TOP
    ; C   THE ALGORITHM IS DECRIBED ON P.17 OF STIPANUK, G.S.,1973:
    ; C   "ALGORITHMS FOR GENERATING A SKEW-T LOG P DIAGRAM AND COMPUTING
    ; C   SELECTED METEOROLOGICAL QUANTITIES," ATMOSPHERIC SCIENCES LABORA-
    ; C   TORY, U.S. ARMY ELECTRONICS COMMAND, WHITE SANDS MISSILE RANGE, NEW
    ; C   MEXICO 88002.
    ;
    ;         DIMENSION T(1),P(1),TD(1)
    ;         If (PM.NE.P(1)) GO To 5
    ;         WBAR= W(TD(1),P(1))
    ;         PC= PM
    ;         If (Abs(T(1)-TD(1)).LT.0.05) GO To 45
    ;         GO To 25
    ;     5   Continue
    
    Protected.d PC, X, DEL, A
    Protected.i I, J, K, L
    
    If PM = P(1)
      WBAR = W(TD(1), P(1))
      PC= PM
      
      If (Abs(T(1)-TD(1)) < 0.05) 
        Goto M45:
      EndIf
      
    EndIf  ; M5:
    WBAR= 0
    K= 0
    ;         WBAR= 0.
    ;         K= 0
    
    ;    10   Continue
    ;         K = K+1
    ;         If (P(K).GT.PM) GO To 10
    While P(K) > PM  And K <= N  ; added a DimensionCheck
      K + 1
    Wend
    K -1 
    J = K - 1
    
    ;         K= K-1
    ;         J= K-1
    ;         If(J.LT.1) GO To 20
    
    If J<1
      Goto M20:
      
    ; C   COMPUTE THE AVERAGE MIXING RATIO....ALOG = NATURAL LOG
    ;
    ;         DO 15 I= 1,J
    ;            L= I+1
    ;    15      WBAR= (W(TD(I),P(I))+W(TD(L),P(L)))*ALOG(P(I)/P(L))
    ;      *          +WBAR
    ;    20   Continue
    ;         L= K+1
      
      For I = 1 To J
        L = I + 1
        WBAR= ( W(TD(I), P(I) ) + W( TD(L), P(L)) ) * Log( P(I)/P(L) ) + WBAR
      Next
    EndIf
    
      M20:
      L= K+1
      
    ; C   ESTIMATE THE DEW POINT AT PRESSURE PM.
    ;
    ;         TQ= TD(K)+(TD(L)-TD(K))*(ALOG(PM/P(K)))/(ALOG(P(L)/P(K)))
    ;         WBAR= WBAR+(W(TD(K),P(K))+W(TQ,PM))*ALOG(P(K)/PM)
    ;         WBAR= WBAR/(2.*ALOG(P(1)/PM))
    ;
    ; C   FIND LEVEL AT WHICH THE MIXING RATIO LINE WBAR CROSSES THE
    ; C   ENVIRONMENTAL TEMPERATURE PROFILE.
    ;
    ;    25   Continue
    ;         DO 30 J= 1,N
    ;            I= N-J+1
    ;            If (P(I).LT.300.) GO To 30
    ;
    ; C   TMR = TEMPERATURE (CELSIUS) AT PRESSURE P (MB) ALONG A MIXING
    ; C         RATIO LINE GIVEN BY WBAR (G/KG)
    ;
    ;            X= TMR(WBAR,P(I))-T(I)
    ;            If (X.LE.0.) GO To 35
    ;    30   Continue
      
      For J = 1 To N
        I = n-J+1
        If P(I) < 300 : Break : EndIf     ; If (P(I).LT.300.) GO To 30
        
        X= TMR(WBAR,P(I))-T(I)
        
        If X < 0 : Goto M35: EndIf
      Next
      
    ;         PCCL= 0.0
    ;         Return
    ;
    ; C  SET UP BISECTION ROUTINE
    ;
    M35:  
    ;    35   L = I
    ;         I= I+1
    ;         DEL= P(L)-P(I)
    ;         PC= P(I)+.5*DEL
    ;         A= (T(I)-T(L))/ALOG(P(L)/P(I))
    L = I
    I= I+1
    DEL= P(L)-P(I)
    PC= P(I) + 0.5*DEL
    A= (T(I)-T(L)) / Log(P(L)/P(I))
    
    ;         DO 40 J= 1,10
    ;            DEL= DEL/2.
    ;            X= TMR(WBAR,PC)-T(L)-A*(ALOG(P(L)/PC))
    ;
    ; C   THE SIGN FUNCTION REPLACES THE SIGN OF THE FIRST ARGUMENT
    ; C   With THAT OF THE SECOND.
    ;
    ;    40   PC= PC+Sign(DEL,X)
    
    M45:
    ;    45   PCCL = PC
    ;         Return
    ;         End
    
    ProcedureReturn PC
  EndProcedure
  
  ;- ---------------------------------------------------------------------------
  ;-  C) Temperature Functions
  ;- ---------------------------------------------------------------------------
  
  Procedure.d DWPT(T.d, rH.d)
  ; ======================================================================
  ; NAME: DWPT
  ; DESC: dew point
  ; VAR(T.d): Temperature [°C] 
  ; VAR(rH.d): relavie humidity [%]
  ; RET.d: Dew Point Temperature TD [°C]
  ; ======================================================================
    
    Protected dpd.d, x.d
    ;
    ; *** matches
    ;
    ;       FUNCTION DWPT(T,RH)
    ;
    ;   THIS FUNCTION RETURNS THE DEW Point (CELSIUS) GIVEN THE TEMPERATURE
    ;   (CELSIUS) And RELATIVE HUMIDITY (%). THE FORMULA IS USED IN THE
    ;   PROCESSING OF U.S. RAWINSONDE Data And IS REFERENCED IN PARRY, H.
    ;   DEAN, 1969: "THE SEMIAUTOMATIC COMPUTATION OF RAWINSONDES,"
    ;   TECHNICAL MEMORANDUM WBTM EDL 10, U.S. DEPARTMENT OF COMMERCE,
    ;   ENVIRONMENTAL SCIENCE SERVICES ADMINISTRATION, WEATHER BUREAU,
    ;   OFFICE OF SYSTEMS DEVELOPMENT, EQUIPMENT DEVELOPMENT LABORATORY,
    ;   SILVER SPRING, MD (OCTOBER), PAGE 9 And PAGE II-4, LINE 460.
    ;
    ;       X = 1.-0.01*RH
    ;
    x = 1 - 0.01 * rH
    ;
    ;   COMPUTE DEW POINT DEPRESSION.
    ;
    ;       DPD =(14.55+0.114*T)*X+((2.5+0.007*T)*X)**3+(15.9+0.117*T)*X**14
    ;
    dpd =( 14.55 + 0.114 * T ) * x + Pow((( 2.5 + 0.007 * T ) * x ) , 3) + ( 15.9 + 0.117 * T ) * Pow( x , 14 )
    ;
    ;       DWPT = T-DPD
    ;       Return
    ;       End
 
    ProcedureReturn T - dpd                                        
  EndProcedure
  
  Procedure.d DEWPT(EW.d)
  ; ======================================================================
  ; NAME: DEWPT
  ; DESC: dew point
  ; VAR(EW.d): WATER VAPOR PRESSURE [mbar]
  ; RET.d: Dew Point Temperature TD [°C]
  ; ======================================================================
    Protected ENL.d
    ;
    ; *** matches, see also DPT()
    ;
    ;       FUNCTION DEWPT(EW)
    ;
    ;   THIS FUNCTION YIELDS THE DEW POINT DEWPT (CELSIUS), GIVEN THE
    ;   WATER VAPOR PRESSURE EW (MILLIBARS).
    ;   THE EMPIRICAL FORMULA APPEARS IN BOLTON, DAVID, 1980:
    ;   "THE COMPUTATION OF EQUIVALENT POTENTIAL TEMPERATURE,"
    ;   MONTHLY WEATHER REVIEW, VOL. 108, NO. 7 (JULY), P. 1047, EQ.(11).
    ;   THE QUOTED ACCURACY IS 0.03C Or LESS For -35 < DEWPT < 35C.
    ;
    ;       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ;       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;       ENL = ALOG(EW)
    ;       DEWPT = (243.5*ENL-440.8)/(19.48-ENL)
    ;       Return
    ;       End
    ;
    ENL = Log(EW)
    ProcedureReturn (243.5 * ENL - 440.8) / (19.48 - ENL)
  EndProcedure
  
  Procedure.d DPT(EW.d)                                 
  ; ======================================================================
  ; NAME: DPT
  ; DESC: dew point
  ; VAR(EW.d): WATER VAPOR PRESSURE [mbar]
  ; RET.d: Dew Point Temperature TD [°C]
  ; ======================================================================
    Protected x,d, dnm.d, T.d, fac.d, edp.d, dtdew.d, dt.d
    ;
    ; *** matches, see also DEWPT()
    ;
    ;       FUNCTION DPT(EW)
    ;
    ;   THIS FUNCTION RETURNS THE DEW POINT DPT (CELSIUS), GIVEN THE
    ;   WATER VAPOR PRESSURE EW (MILLIBARS).
    ;   APPROXIMATE DEW POINT BY MEANS OF TETEN'S FORMULA.
    ;   THE FORMULA APPEARS As EQ.(8) IN BOLTON, DAVID, 1980:
    ;   "THE COMPUTATION OF EQUIVALENT POTENTIAL TEMPERATURE,"
    ;   MONTHLY WEATHER REVIEW, VOL 108, NO. 7 (JULY), P.1047.
    ;   THE FORMULA IS EW(T) = ES0*10**(7.5*T/(T+237.3))
    ;            Or    EW(T) = ES0*Exp(17.269388*T/(T+237.3))
    ;   THE INVERSE FORMULA IS USED BELOW.
    ;
     ;
    #ESO = 6.1078
    ;
    ;       Data ES0/6.1078/
    ;
    ;   ES0 = SATURATION VAPOR PRESSURE (MB) OVER WATER AT 0C
    ;   Return A FLAG VALUE If THE VAPOR PRESSURE IS OUT OF RANGE.
    ;
    ;       If (EW.GT..06.And.EW.LT.1013.) GO To 5
    ;       DPT = 9999.
    ;       Return
    ;   5   Continue
    ;
    If EW <= 0.06 Or EW >= 1013
      ProcedureReturn 9999                                         
    EndIf
    ;
    ;       X = ALOG(EW/ES0)
    ;
    x = Log(EW / #ESO)
    ;
    ;       DNM = 17.269388-X
    ;
    dnm = 17.263988 - x
    ;
    ;       T = 237.3*X/DNM
    ;
    T = 237.3 * x / dnm
    ;
    ;       FAC = 1./(EW*DNM)
    ;
    fac = 1 / (EW * dnm)
    ;
    ;   LOOP For ITERATIVE IMPROVEMENT OF THE ESTIMATE OF DEW POINT
    ;
    ;  10   Continue
    ;
    Repeat
      ;
      ;   GET THE PRECISE VAPOR PRESSURE CORRESPONDING To T.
      ;
      ;       EDP = ESW(T)
      ;
      edp = ESW(T)
      ;
      ;   ESTIMATE THE CHANGE IN TEMPERATURE CORRESPONDING To (EW-EDP)
      ;   ASSUME THAT THE DERIVATIVE OF TEMPERATURE With RESPECT To
      ;   VAPOR PRESSURE (DTDEW) IS GIVEN BY THE DERIVATIVE OF THE
      ;   INVERSE TETEN FORMULA.
      ;
      ;       DTDEW = (T+237.3)*FAC
      ;
      dtdew = (T + 237.3) * fac
      ;
      ;       DT = DTDEW*(EW-EDP)
      ;
      dt = dtdew * (EW - edp)
      ;
      ;       T = T+DT
      ;
      T = T + dt
      ;
      ;       If (Abs(DT).GT.1.E-04) GO To 10
      ;
    Until Abs( dt) <= 1E-04
    ;
    ;       DPT = T
    ;       Return
    ;       End
    ;
    ProcedureReturn T                                           
  EndProcedure
  
  Procedure.d TE(T, P, TD)
    ;
    ;
    ; C   THIS FUNCTION RETURNS THE EQUIVALENT TEMPERATURE TE (CELSIUS) OF A
    ; C   PARCEL OF AIR GIVEN ITS TEMPERATURE T (CELSIUS), DEW Point (CELSIUS)
    ; C   And PRESSURE P (MILLIBARS).
    ; C   CALCULATE EQUIVALENT POTENTIAL TEMPERATURE.
    ;
    ;         AOE = OE(T,TD,P)
    ;
    ; C   USE POISSONS'S EQUATION TO CALCULATE EQUIVALENT TEMPERATURE.
    ;
    ;         TE= TDA(AOE,P)
    ;         Return
    ;         End
    Protected.d AOE, TE
    AOE = OE(T, P, TD)
    TE = TDA(AOE, P)
    
    ProcedureReturn TE
  EndProcedure
  
  Procedure.d O(T.d, P.d)                      
  ; ======================================================================
  ; NAME: O
  ; DESC: equivalent potential temperature
  ; VAR(T.d): Temperature in Celsius
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Temperataure [°C]
  ; ======================================================================
    
    Protected O.d, TK.d, OK.d
    ;
    ; *** matches
    ;
    ;       FUNCTION O(T,P)
    ;
    ;   THIS FUNCTION RETURNS POTENTIAL TEMPERATURE (CELSIUS) GIVEN
    ;   TEMPERATURE T (CELSIUS) And PRESSURE P (MB) BY SOLVING THE POISSON
    ;   EQUATION.
    ;
    ;       TK = T+273.15
    ;
    TK = T + #TD_CTA
    ;
    ;       OK = TK*((1000./P)**.286)
    ;
    OK = TK * Pow ( 1000 / P , 0.286 )
    ;
    ;       O = OK-273.15
    ;       Return
    ;       End
    ;
    ProcedureReturn OK - #TD_CTA                                          
  EndProcedure
  
  Procedure.d OS(T.d, P.d)                     
  ; ======================================================================
  ; NAME: OS
  ; DESC: equivalent potential temperature
  ; VAR(T.d): Temperature [°C]
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Temperature [°C]
  ; ======================================================================
    
    Protected b.d, TK.d, OSK.d
    ;
    ; *** matches, may be inaccurate
    ;
    ;       FUNCTION OS(T,P)
    ;
    ;   THIS FUNCTION RETURNS THE EQUIVALENT POTENTIAL TEMPERATURE OS
    ;   (CELSIUS) For A PARCEL OF AIR SATURATED AT TEMPERATURE T (CELSIUS)
    ;   And PRESSURE P (MILLIBARS).
    ;
    ;         Data B/2.6518986/
    ;
    b = 2.6518986
    ;
    ;   B IS AN EMPIRICAL CONSTANT APPROXIMATELY EQUAL To THE LATENT HEAT
    ;   OF VAPORIZATION For WATER DIVIDED BY THE SPECIFIC HEAT AT CONSTANT
    ;   PRESSURE For DRY AIR.
    ;
    ;       TK = T+273.15
    ;
    TK = T + #TD_CTA
    ;
    ;     OSK= TK*((1000./P)**.286)*(Exp(B*W(T,P)/TK))
    ;
    ;     OSK = TK * ( Pow(( 1000 / P ) , 0.286 )) * ( Exp( b * W(T,P) / TK ))
    ;
    OSK = Exp( b * W(T,P) / TK )
    OSK = TK * Pow(( 1000 / P) , 0.286) * OSK
    ;
    ;     OS= OSK-273.15
    ;     Return
    ;     End
    ;
    ProcedureReturn OSK - #TD_CTA
  EndProcedure
   
  Procedure.d OE(T, P, TD)
    ;
    ; C   THIS FUNCTION RETURNS EQUIVALENT POTENTIAL TEMPERATURE OE (CELSIUS)
    ; C   OF A PARCEL OF AIR GIVEN ITS TEMPERATURE T (CELSIUS), DEW POINT
    ; C   TD (CELSIUS) And PRESSURE P (MILLIBARS).
    ; C   FIND THE WET BULB TEMPERATURE OF THE PARCEL.
    ;
    ;         ATW = TW(T,TD,P)
    ;
    ; C   FIND THE EQUIVALENT POTENTIAL TEMPERATURE.
    ;
    ;         OE = OS(ATW,P)
    ;         Return
    ;         End
    
    Protected.d ATW, OE
    
    ATW = TW(T, P, TD)
    OE = OS(ATW, P)
    ProcedureReturn OE
  EndProcedure
  
  Procedure.d EPT(T, P, TD)
    
    ; C   THIS FUNCTION RETURNS THE EQUIVALENT POTENTIAL TEMPERATURE EPT
    ; C   (CELSIUS) For A PARCEL OF AIR INITIALLY AT TEMPERATURE T (CELSIUS),
    ; C   DEW POINT TD (CELSIUS) And PRESSURE P (MILLIBARS). THE FORMULA USED
    ; C   IS EQ.(43) IN BOLTON, DAVID, 1980: "THE COMPUTATION OF EQUIVALENT
    ; C   POTENTIAL TEMPERATURE," MONTHLY WEATHER REVIEW, VOL. 108, NO. 7
    ; C   (JULY), PP. 1046-1053. THE MAXIMUM ERROR IN EPT IN 0.3C.  IN MOST
    ; C   CASES THE ERROR IS LESS THAN 0.1C.
    ; C
    ; C   COMPUTE THE MIXING RATIO (GRAMS OF WATER VAPOR PER KILOGRAM OF
    ; C   DRY AIR).
    ;
    ;         W = WMR(P,TD)
    ;
    ; C   COMPUTE THE TEMPERATURE (CELSIUS) AT THE LIFTING CONDENSATION LEVEL.
    ;
    ;         TLCL = TCON(T,TD)
    ;         TK = T+273.15
    ;         TL = TLCL+273.15
    ;         PT = TK*(1000./P)**(0.2854*(1.-0.00028*W))
    ;         EPTK = PT*Exp((3.376/TL-0.00254)*W*(1.+0.00081*W))
    ;         EPT= EPTK-273.15
    ;         Return
    ;         End
    
    Protected.d W, TLCL, TK, TL, PT, EPTK
    
    W= WMR(P, T)
    TK = T + #TD_CTA
    TLCL = TCON(T,TD)
    TL = TLCL + #TD_CTA
    ; PT = TK*(1000/P)**(0.2854*(1 - 0.00028 * W))
    PT = TK*(1000/P)
    PT = Pow( PT, (0.2854*(1 - 0.00028 * W)) )
    
    ; EPTK = PT * Exp( (3.376/TL-0.00254)*W*(1.+0.00081*W) )
    EPTK = (3.376/TL -0.00254) * W *(1 + 0.00081 *W)
    EPTK = PT * Exp(EPTK)
    
    ProcedureReturn EPTK - #TD_CTA
  EndProcedure
  
  Procedure.d TW(T.d, TD.d, P.d)                     
  ; ======================================================================
  ; NAME: TW
  ; DESC: wet bulb temperature
  ; VAR(T.d): Temperature [°C] 
  ; VAR(TD.d): 
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Temperature [°C]
  ; ======================================================================
    Protected aw.d, ao.d, pi.d, i.i, x.d, ti.d, aos.d
    ;
    ; *** matches, may be inaccurate
    ;
    ;       FUNCTION TW(T,TD,P)
    ;
    ;   THIS FUNCTION RETURNS THE WET-BULB TEMPERATURE TW (CELSIUS)
    ;   GIVEN THE TEMPERATURE T (CELSIUS), DEW POINT TD (CELSIUS)
    ;   And PRESSURE P (MB).  SEE P.13 IN STIPANUK (1973), REFERENCED
    ;   ABOVE, For A DESCRIPTION OF THE TECHNIQUE.
    ;
    ;
    ;   DETERMINE THE MIXING RATIO LINE THRU TD And P.
    ;
    ;       AW = W(TD,P)
    ;
    aw = W(TD, P)
    ;
    ;   DETERMINE THE DRY ADIABAT THRU T And P.
    ;
    ;         AO = O(T,P)
    ;
    ao = O(T, P)
    ;
    ;         PI = P
    ;
    pi = P
    ;
    ;   ITERATE To LOCATE PRESSURE PI AT THE INTERSECTION OF THE TWO
    ;   CURVES .  PI HAS BEEN SET To P For THE INITIAL GUESS.
    ;
    ;        DO 4 I= 1,10
    ;             X= .02*(TMR(AW,PI)-TDA(AO,PI))
    ;             If (Abs(X).LT.0.01) GO To 5
    ;   4         PI= PI*(2.**(X))
    ;
    For i = 1 To 10
      x = 0.02 * ( TMR(aw, pi) - TDA(ao, pi))
      If ( Abs(x) < 0.01 )
        Break
      EndIf
      pi = pi * Pow(2, x)
    Next i
    ;
    ;   FIND THE TEMPERATURE ON THE DRY ADIABAT AO AT PRESSURE PI.
    ;
    ;   5    TI= TDA(AO,PI)
    ;
    ti = TDA(ao, pi)
    ;
    ;   THE INTERSECTION HAS BEEN LOCATED...NOW, FIND A SATURATION
    ;   ADIABAT THRU THIS POINT. FUNCTION OS RETURNS THE EQUIVALENT
    ;   POTENTIAL TEMPERATURE (C) OF A PARCEL SATURATED AT TEMPERATURE
    ;   TI And PRESSURE PI.
    ;
    ;        AOS= OS(TI,PI)
    ;
    aos = OS(ti, pi)
    ;
    ;   FUNCTION TSA RETURNS THE WET-BULB TEMPERATURE (C) OF A PARCEL AT
    ;   PRESSURE P WHOSE EQUIVALENT POTENTIAL TEMPERATURE IS AOS.
    ;
    ;       TW = TSA(AOS,P)
    ;       Return
    ;       End
    ;
    ProcedureReturn TSA(aos, P)                                          
  EndProcedure
  
  Procedure.d OW(T.d, TD.d, P.d)  
  ; ======================================================================
  ; NAME: POWT
  ; DESC: wet bulb potential temperature
  ; VAR(T.d): Temeprature [°C]
  ; VAR(TD.d): dew point [°C]
  ; VAR(P.d): Pressure [mbar]
  ; RET.d: Temeprature [°C]
  ; ======================================================================
    
    Protected OW.d, atw.d, aos.d, qw.d
    ;
    ; *** matches, may be inaccurate
    ;
    ;       FUNCTION OW(T,TD,P)
    ;
    ;   THIS FUNCTION RETURNS THE WET-BULB POTENTIAL TEMPERATURE OW
    ;   (CELSIUS) GIVEN THE TEMPERATURE T (CELSIUS), DEW POINT TD
    ;   (CELSIUS), And PRESSURE P (MILLIBARS).  THE CALCULATION For OW IS
    ;   VERY SIMILAR To THAT For WET BULB TEMPERATURE. SEE P.13 STIPANUK (1973).
    ;   FIND THE WET BULB TEMPERATURE OF THE PARCEL
    ;
    ;       ATW = TW(T,TD,P)
    ;
    atw = TW(T, TD, P)
    ;
    ;   FIND THE EQUIVALENT POTENTIAL TEMPERATURE OF THE PARCEL.
    ;
    ;       AOS= OS(ATW,P)
    ;
    aos = OS (atw, P)
    ;
    ;   FIND THE WET-BULB POTENTIAL TEMPERATURE.
    ;
    ;       OW= TSA(AOS,1000.)
    ;
    OW = TSA(aos, 1000)
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn OW                                          
  EndProcedure
 
  Procedure.d POWT(T.d, TD.d, P.d)
  ; ======================================================================
  ; NAME: POWT
  ; DESC: wet bulb potential temperature
  ; VAR(T.d): Temeprature [°C]
  ; VAR(TD.d): dew point [°C]
  ; VAR(P.d): Pressure [mbar]
  ; RET.d: Temeprature [°C]
  ; ======================================================================
    Protected POWT.d, akap.d, pt.d, TC.d
    ;
    ; *** matches
    ;
    ;         FUNCTION POWT(T,P,TD)
    ;
    ; C   THIS FUNCTION YIELDS WET-BULB POTENTIAL TEMPERATURE POWT
    ; C   (CELSIUS), GIVEN THE FOLLOWING INPUT:
    ; C          T = TEMPERATURE (CELSIUS)
    ; C          P = PRESSURE (MILLIBARS)
    ; C          TD = DEW Point (CELSIUS)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;         Data CTA,AKAP/273.15,0.28541/
    ;
     akap = 0.28541
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ; C   AKAP = (GAS CONSTANT For DRY AIR) / (SPECIFIC HEAT AT
    ; C          CONSTANT PRESSURE For DRY AIR)
    ; C   COMPUTE THE POTENTIAL TEMPERATURE (CELSIUS)
    ;
    ;         PT = (T+CTA)*(1000./P)**AKAP-CTA
    ;
    pt = (T + #TD_CTA) * Pow((1000 / P), akap) - #TD_CTA
    ;
    ; C   COMPUTE THE LIFTING CONDENSATION LEVEL (LCL).
    ;
    ;         TC = TCON(T,TD)
    ;
    TC = TCON(T, TD)
    ;
    ;
    ; C   For THE ORIGIN OF THE FOLLOWING APPROXIMATION, SEE THE DOCUMEN-
    ; C   TATION For THE WOBUS FUNCTION.
    ;
    ;         POWT = PT-WOBF(PT)+WOBF(TC)
    ;
    POWT = pt - WOBF(pt) + WOBF(TC)
    ;
    ;         Return
    ;         End
    ;
    ProcedureReturn POWT                                        
  EndProcedure
  
  ; Private
  Procedure.d _THM_F(x.d)  ; part of THM()
    Protected f.d
    ;
    ; this function belongs to THM()
    ;
    ;       F(X) =   1.8199427E+01+X*( 2.1640800E-01+X*( 3.0716310E-04+X*
    ;    1         (-3.8953660E-06+X*( 1.9618200E-08+X*( 5.2935570E-11+X*
    ;    2         ( 7.3995950E-14+X*(-4.1983500E-17)))))))
    ;
    ; f = 1.8199427E+01 + x *( 2.1640800E-01 + x * ( 3.0716310E-04 + x * ( -3.8953660E-06 + x *( 1.9618200E-08 + x * ( 5.2935570E-11 + x * ( 7.3995950E-14 + x * ( -4.1983500E-17 )))))))
    ;
    ; just hit a bug in pb4.51rc2, where the line above doesn't work when called indirectly... weird
    ;
    f = x * (-4.1983500E-17)
    f = x * (7.3995950E-14  + f)
    f = x * (5.2935570E-11  + f)
    f = x * (1.9618200E-08  + f)
    f = x * (-3.8953660E-06 + f)
    f = x * (3.0716310E-04  + f)
    f = x * (2.1640800E-01  + f)
    f = f + 1.8199427E+01
    ;
    ;       Return
    ;       End
 
    ProcedureReturn f                                           
  EndProcedure

  Procedure.d THM(T.d, P.d)
  ; ======================================================================
  ; NAME: THM
  ; DESC: wet bulb potential temperature
  ; VAR(T.d): Temperature [°C] 
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Temperature [°C] 
  ; ======================================================================
   Protected.d THM, THD
    ;
    ; *** matches
    ;
    ;       FUNCTION THM(T,P)
    ;   THIS FUNCTION RETURNS THE WET-BULB POTENTIAL TEMPERATURE THM
    ;   (CELSIUS) CORRESPONDING To A PARCEL OF AIR SATURATED AT
    ;   TEMPERATURE T (CELSIUS) And PRESSURE P (MILLIBARS).
    ;
    ;       F(X) =   1.8199427E+01+X*( 2.1640800E-01+X*( 3.0716310E-04+X*
    ;    1         (-3.8953660E-06+X*( 1.9618200E-08+X*( 5.2935570E-11+X*
    ;    2         ( 7.3995950E-14+X*(-4.1983500E-17)))))))
    ;       THM = T
    ;
    THM = T
    ;
    ;       If (P.EQ.1000.) Return
    ;
    If P = 1000
      ProcedureReturn THM                                         
    EndIf
    ;
    ;   COMPUTE THE POTENTIAL TEMPERATURE (CELSIUS).
    ;
    ;       THD = (T+273.15)*(1000./P)**.286-273.15
    ;
    THD = (T + #TD_CTA) * Pow((1000 / P), 0.286) - #TD_CTA
    ;
    ;       THM = THD+6.071*(Exp(T/F(T))-Exp(THD/F(THD)))
    ;
    THM = THD + 6.071 * (Exp(T / _THM_F(T)) - Exp(THD / _THM_F(THD)))
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn THM                                         
  EndProcedure
  
  Procedure.d WOBF(T.d)          
  ; ======================================================================
  ; NAME: WOBF
  ; DESC: difference in potential wet bulb temperatures
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Temeprature [°C]
  ; ======================================================================
    Protected WOBF.d, x.d, pol.d
    ;
    ; *** matches
    ;
    ;       FUNCTION WOBF(T)
    ;
    ;   THIS FUNCTION CALCULATES THE DIFFERENCE OF THE WET-BULB POTENTIAL
    ;   TEMPERATURES For SATURATED And DRY AIR GIVEN THE TEMPERATURE.
    ;
    ;        LET WBPTS = WET-BULB POTENTIAL TEMPERATURE For SATURATED
    ;   AIR AT TEMPERATURE T (CELSIUS). LET WBPTD = WET-BULB POTENTIAL
    ;   TEMPERATURE For COMPLETELY DRY AIR AT THE SAME TEMPERATURE T.
    ;   THE WOBUS FUNCTION WOBF (IN DEGREES CELSIUS) IS DEFINED BY
    ;                      WOBF(T) = WBPTS-WBPTD.
    ;   ALTHOUGH WBPTS And WBPTD ARE FUNCTIONS OF BOTH PRESSURE And
    ;   TEMPERATURE, THEIR DIFFERENCE IS A FUNCTION OF TEMPERATURE ONLY.
    ;
    ;        To UNDERSTAND WHY, CONSIDER A PARCEL OF DRY AIR AT TEMPERA-
    ;   TURE T And PRESSURE P. THE THERMODYNAMIC STATE OF THE PARCEL IS
    ;   REPRESENTED BY A POINT ON A PSEUDOADIABATIC CHART. THE WET-BULB
    ;   POTENTIAL TEMPERATURE CURVE (MOIST ADIABAT) PASSING THROUGH THIS
    ;   POINT IS WBPTS. NOW T IS THE EQUIVALENT TEMPERATURE For ANOTHER
    ;   PARCEL SATURATED AT SOME LOWER TEMPERATURE TW, BUT AT THE SAME
    ;   PRESSURE P.  To FIND TW, ASCEND ALONG THE DRY ADIABAT THROUGH
    ;   (T,P). AT A GREAT HEIGHT, THE DRY ADIABAT And SOME MOIST
    ;   ADIABAT WILL NEARLY COINCIDE. DESCEND ALONG THIS MOIST ADIABAT
    ;   BACK To P. THE PARCEL TEMPERATURE IS NOW TW. THE WET-BULB
    ;   POTENTIAL TEMPERATURE CURVE (MOIST ADIABAT) THROUGH (TW,P) IS WBPTD.
    ;   THE DIFFERENCE (WBPTS-WBPTD) IS PROPORTIONAL To THE HEAT IMPARTED
    ;   To A PARCEL SATURATED AT TEMPERATURE TW If ALL ITS WATER VAPOR
    ;   WERE CONDENSED. SINCE THE AMOUNT OF WATER VAPOR A PARCEL CAN
    ;   HOLD DEPENDS UPON TEMPERATURE ALONE, (WBPTD-WBPTS) MUST DEPEND
    ;   ON TEMPERATURE ALONE.
    ;
    ;        THE WOBUS FUNCTION IS USEFUL For EVALUATING SEVERAL THERMO-
    ;   DYNAMIC QUANTITIES.  BY DEFINITION:
    ;                   WOBF(T) = WBPTS-WBPTD.               (1)
    ;   If T IS AT 1000 MB, THEN T IS A POTENTIAL TEMPERATURE PT And
    ;   WBPTS = PT. THUS
    ;                   WOBF(PT) = PT-WBPTD.                 (2)
    ;   If T IS AT THE CONDENSATION LEVEL, THEN T IS THE CONDENSATION
    ;   TEMPERATURE TC And WBPTS IS THE WET-BULB POTENTIAL TEMPERATURE
    ;   WBPT. THUS
    ;                   WOBF(TC) = WBPT-WBPTD.               (3)
    ;   If WBPTD IS ELIMINATED FROM (2) And (3), THERE RESULTS
    ;                   WBPT = PT-WOBF(PT)+WOBF(TC).
    ;   If WBPTD IS ELIMINATED FROM (1) And (2), THERE RESULTS
    ;                   WBPTS = PT-WOBF(PT)+WOBF(T).
    ;
    ;        If T IS AN EQUIVALENT POTENTIAL TEMPERATURE EPT (IMPLYING
    ;   THAT THE AIR AT 1000 MB IS COMPLETELY DRY), THEN WBPTS = EPT
    ;   And WBPTD = WBPT. THUS
    ;                   WOBF(EPT) = EPT-WBPT.
    ;   THIS FORM IS THE BASIS For A POLYNOMIAL APPROXIMATION To WOBF.
    ;   IN TABLE 78 ON PP.319-322 OF THE SMITHSONIAN METEOROLOGICAL
    ;   TABLES BY ROLAND List (6TH REVISED EDITION), ONE FINDS WET-BULB
    ;   POTENTIAL TEMPERATURES And THE CORRESPONDING EQUIVALENT POTENTIAL
    ;   TEMPERATURES LISTED TOGETHER. HERMAN WOBUS, A MATHEMATICIAN For-
    ;   MERLY AT THE NAVY WEATHER RESEARCH FACILITY, NORFOLK, VIRGINIA,
    ;   And NOW RETIRED, COMPUTED THE COEFFICIENTS For THE POLYNOMIAL
    ;   APPROXIMATION FROM NUMBERS IN THIS TABLE.
    ;
    ;                                    NOTES BY T.W. SCHLATTER
    ;                                    NOAA/ERL/PROFS PROGRAM OFFICE
    ;                                    AUGUST 1981
    ;
    ;       X = T-20.
    
    x = T - 20
    
    ;       If (X.GT.0.) GO To 10
    
    If x <= 0
      ;
      ;         POL = 1.                 +X*(-8.8416605E-03
      ;      1       +X*( 1.4714143E-04  +X*(-9.6719890E-07
      ;      2       +X*(-3.2607217E-08  +X*(-3.8598073E-10)))))
      ;
      pol = x * ( -3.2607217E-08 + x * ( -3.8598073E-10 ) )
      pol = x * ( 1.4714143E-04 + x *( -9.6719890E-07 + pol ))
      pol = 1 + x * ( -8.8416605E-03 + pol )
      ;
      ;         WOBF = 15.130/POL**4
      ;         Return
      ;
      WOBF = 15.130 / Pow ( pol , 4 )
      ProcedureReturn WOBF                                        
      
    Else
      ;
      ;    10   Continue
      ;
      ;         POL = 1.                 +X*( 3.6182989E-03
      ;      1       +X*(-1.3603273E-05  +X*( 4.9618922E-07
      ;      2       +X*(-6.1059365E-09  +X*( 3.9401551E-11
      ;      3       +X*(-1.2588129E-13  +X*( 1.6688280E-16)))))))
      ;
      pol = x * ( -1.2588129E-13 + x * ( 1.6688280E-16))
      pol = x * ( -6.1059365E-09 + x * ( 3.9401551E-11 + pol ))
      pol = x * ( -1.3603273E-05 + x * ( 4.9618922E-07 + pol ))
      pol = 1 + x * ( 3.6182989E-03 + pol )
      ;
      ;         WOBF = 29.930/POL**4+0.96*X-14.8
      ;
      WOBF = 29.930 / Pow(pol, 4) + 0.96 * x - 14.8
      ;
      ;         Return
      ;         End
      ;
      ProcedureReturn WOBF                                        
    EndIf
  EndProcedure
  
  Procedure.d CT(WBAR,PC,PS)
 
    ; C   THIS FUNCTION RETURNS THE CONVECTIVE TEMPERATURE CT (CELSIUS)
    ; C   GIVEN THE MEAN MIXING RATIO WBAR (G/KG) IN THE SURFACE LAYER,
    ; C   THE PRESSURE PC (MB) AT THE CONVECTIVE CONDENSATION LEVEL (CCL)
    ; C   And THE SURFACE PRESSURE PS (MB).
    ; C   COMPUTE THE TEMPERATURE (CELSIUS) AT THE CCL.
    ;
    ;         TC= TMR(WBAR,PC)
    ;
    ; C   COMPUTE THE POTENTIAL TEMPERATURE (CELSIUS), I.E., THE DRY
    ; C   ADIABAT AO THROUGH THE CCL.
    ;
    ;         AO= O(TC,PC)
    ;
    ; C   COMPUTE THE SURFACE TEMPERATURE ON THE SAME DRY ADIABAT AO.
    ;
    ;         CT= TDA(AO,PS)
    ;         Return
    ;         End
    
    Protected.d TC, AO, CT
    
    TC= TMR(WBAR,PC)
    AO= O(TC,PC)
    CT= TDA(AO,PS)
    ProcedureReturn CT
  EndProcedure
  
  Procedure.d TV(T, TD, P)
    
    ; C   THIS FUNCTION RETURNS THE VIRTUAL TEMPERATURE TV (CELSIUS) OF
    ; C   A PARCEL OF AIR AT TEMPERATURE T (CELSIUS), DEW POINT TD
    ; C   (CELSIUS), And PRESSURE P (MILLIBARS). THE EQUATION APPEARS
    ; C   IN MOST STANDARD METEOROLOGICAL TEXTS.
    ;
    ;         Data CTA,EPS/273.15,0.62197/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES.
    ; C   EPS = RATIO OF THE MEAN MOLECULAR WEIGHT OF WATER (18.016 G/MOLE)
    ; C         To THAT OF DRY AIR (28.966 G/MOLE)
    ;
    ;         TK = T+CTA
    ;
    ; C   CALCULATE THE DIMENSIONLESS MIXING RATIO.
    ;
    ;         W = .001*WMR(P,TD)
    ;         TV = TK*(1.+W/EPS)/(1.+W)-CTA
    ;         Return
    ;         End
    
    Protected.d TK, W, TV
    
    #EPS = 0.62197
    TK = T+ #TD_CTA
    
    W = 0.001 * WMR(P, TD)
    TV = TK * (1 + W/#EPS) / (1 + W) 
    
    ProcedureReturn TV - #TD_CTA
  EndProcedure
  
  Procedure.d TCON(T.d, TD.d)
  ; ======================================================================
  ; NAME: TCON
  ; DESC: temperature at lifting condensation level
  ; VAR(T.d): Temeprature [°C]
  ; VAR(TD.d): dew point [°C]
  ; RET.d: Temeprature [°C]
  ; ======================================================================
    
    Protected s.d, dlt.d
    ;
    ; *** matches
    ;
    ;       FUNCTION TCON(T,D)
    ;
    ;   THIS FUNCTION RETURNS THE TEMPERATURE TCON (CELSIUS) AT THE LIFTING
    ;   CONDENSATION LEVEL, GIVEN THE TEMPERATURE T (CELSIUS) And THE
    ;   DEW POINT D (CELSIUS).
    ;
    ;       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ;       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;
    ;   COMPUTE THE DEW POINT DEPRESSION S.
    ;         S = T-D
    ;
    s = T - TD
    ;
    ;   THE APPROXIMATION BELOW, A THIRD ORDER POLYNOMIAL IN S And T,
    ;   IS DUE To HERMAN WOBUS. THE SOURCE OF Data For FITTING THE
    ;   POLYNOMIAL IS UNKNOWN.
    ;
    ;       DLT = S*(1.2185+1.278E-03*T+
    ;    1        S*(-2.19E-03+1.173E-05*S-5.2E-06*T))
    ;
    dlt = s * ( 1.2185 + 1.278E-03 * T + s * ( -2.19e-03 + 1.173e-05 * s - 5.2e-06 * T ))
    ;
    ;       TCON = T-DLT
    ;       Return
    ;       End
    ;
    ProcedureReturn T - dlt                                        
  EndProcedure
  
  Procedure.d TLCL1(T,TD)

    ; C   THIS FUNCTION RETURNS THE TEMPERATURE TLCL1 (CELSIUS) OF THE LIFTING
    ; C   CONDENSATION LEVEL (LCL) GIVEN THE INITIAL TEMPERATURE T (CELSIUS)
    ; C   And DEW POINT TD (CELSIUS) OF A PARCEL OF AIR.
    ; C   ERIC SMITH AT COLORADO STATE UNIVERSITY HAS USED THE FORMULA
    ; C   BELOW, BUT ITS ORIGIN IS UNKNOWN.
    ;
    ;         Data CTA/273.15/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ;
    ;         TK = T+CTA
    ;
    ; C   COMPUTE THE PARCEL VAPOR PRESSURE (MB).
    ;         ES = ESLO(TD)
    ;         TLCL = 2840./(3.5*ALOG(TK)-ALOG(ES)-4.805)+55.
    ;         TLCL1 = TLCL-CTA
    ;         Return
    ;         End
    
    Protected.d TK, TLCL, ES
    
    TK = T + #TD_CTA
    ES = ESLO(TD)
    TLCL = 2840 / (3.5 * Log(TK) - Log(ES)-4.805) + 55
    
    ProcedureReturn TLCL - #TD_CTA
  EndProcedure
  
  Procedure.d SATLFT(THW, P)
    
    ; C   INPUT:  THW = WET-BULB POTENTIAL TEMPERATURE (CELSIUS).
    ; C                 THW DEFINES A MOIST ADIABAT.
    ; C           P = PRESSURE (MILLIBARS)
    ; C   OUTPUT: SATLFT = TEMPERATURE (CELSIUS) WHERE THE MOIST ADIABAT
    ; C                 CROSSES P
    ;
    ;         Data CTA,AKAP/273.15,0.28541/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ; C   AKAP = (GAS CONSTANT For DRY AIR) / (SPECIFIC HEAT AT CONSTANT
    ; C           PRESSURE For DRY AIR)
    ;
    ; C        THE ALGORITHM BELOW CAN BEST BE UNDERSTOOD BY REFERRING To A
    ; C   SKEW-T/LOG P CHART.  IT WAS DEVISED BY HERMAN WOBUS, A MATHEMATI-
    ; C   CIAN FORMERLY AT THE NAVY WEATHER RESEARCH FACILITY BUT NOW RETIRED.
    ; C   THE VALUE RETURNED BY SATLFT CAN BE CHECKED BY REFERRING To TABLE
    ; C   78, PP.319-322, SMITHSONIAN METEOROLOGICAL TABLES, BY ROLAND List
    ; C   (6TH REVISED EDITION).
    ; C
    ;
    ;         If (P.NE.1000.) GO To 5
    ;         SATLFT = THW
    ;         Return
    ;     5   Continue
    ;
    ; C   COMPUTE TONE, THE TEMPERATURE WHERE THE DRY ADIABAT With VALUE THW
    ; C   (CELSIUS) CROSSES P.
    ;
    ;         PWRP = (P/1000.)**AKAP
    ;         TONE = (THW+CTA)*PWRP-CTA
    ;
    ; C   CONSIDER THE MOIST ADIABAT EW1 THROUGH TONE AT P.  USING THE DEFINI-
    ; C   TION OF THE WOBUS FUNCTION (SEE DOCUMENTATION ON WOBF), IT CAN BE
    ; C   SHOWN THAT EONE = EW1-THW.
    ;
    ;         EONE = WOBF(TONE)-WOBF(THW)
    ;         RATE = 1.
    ;         GO To 15
    ;
    ; C   IN THE LOOP BELOW, THE ESTIMATE OF SATLFT IS ITERATIVELY IMPROVED.
    ;
    ;    10   Continue
    ;
    ; C   RATE IS THE RATIO OF A CHANGE IN T To THE CORRESPONDING CHANGE IN
    ; C   E.  ITS INITIAL VALUE WAS SET To 1 ABOVE.
    ;
    ;         RATE = (TTWO-TONE)/(ETWO-EONE)
    ;         TONE = TTWO
    ;         EONE = ETWO
    ;    15   Continue
    ;
    ; C   TTWO IS AN IMPROVED ESTIMATE OF SATLFT.
    ;
    ;         TTWO = TONE-EONE*RATE
    ;
    ; C   PT IS THE POTENTIAL TEMPERATURE (CELSIUS) CORRESPONDING To TTWO AT P
    ;
    ;         PT = (TTWO+CTA)/PWRP-CTA
    ;
    ; C   CONSIDER THE MOIST ADIABAT EW2 THROUGH TTWO AT P. USING THE DEFINI-
    ; C   TION OF THE WOBUS FUNCTION, IT CAN BE SHOWN THAT ETWO = EW2-THW.
    ;
    ;         ETWO = PT+WOBF(TTWO)-WOBF(PT)-THW
    ;
    ; C   DLT IS THE CORRECTION To BE SUBTRACTED FROM TTWO.
    ;
    ;         DLT = ETWO*RATE
    ;         If (Abs(DLT).GT.0.1) GO To 10
    ;         SATLFT = TTWO-DLT
    ;         Return
    ;         End
    
    Protected.d PWRP, TONE, EONE, RATE, TTWO, PT, ETWO, DLT
    #AKAP = 0.28541
    
    If P = 1000
      ProcedureReturn 1000
    EndIf
    
    PWRP = Pow( (P/1000), #AKAP)
    TONE = (THW+#TD_CTA)*PWRP-#TD_CTA
    EONE = WOBF(TONE) - WOBF(THW)
    RATE = 1
        
    Repeat 
      ; 15   Fortran Jump Lable 15
      TTWO = TONE-EONE*RATE
      PT = (TTWO + #TD_CTA)/PWRP - #TD_CTA
      ETWO = PT + WOBF(TTWO) - WOBF(PT) - THW
      DLT = ETWO * RATE
      
      If Abs(DLT) > 0.1
        ; Fortran Jump Lable 10
        RATE = (TTWO - TONE) / (ETWO - EONE)
        TONE = TTWO
        EONE = ETWO
      Else 
        Break
      EndIf
    ForEver
       
    ProcedureReturn  TTWO-DLT   
  EndProcedure
  
  Procedure.d TDA(O.d, P.d)          ; RET [°C]                         
  ; ======================================================================
  ; NAME: TDA
  ; DESC: temperature on a dry adiabat at pressure P
  ; VAR(OW.d): 
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Temperature [°C]
  ; ======================================================================
    
    Protected OK.d, TDAK.d
    ;
    ; *** matches
    ;
    ;       FUNCTION TDA(O,P)
    ;
    ;   THIS FUNCTION RETURNS THE TEMPERATURE TDA (CELSIUS) ON A DRY ADIABAT
    ;   AT PRESSURE P (MILLIBARS). THE DRY ADIABAT IS GIVEN BY
    ;   POTENTIAL TEMPERATURE O (CELSIUS). THE COMPUTATION IS BASED ON
    ;   POISSON'S EQUATION.
    ;
    ;       OK= O+273.15
    ;
    OK = O + #TD_CTA
    ;
    ;       TDAK= OK*((P*.001)**.286)
    ;
    TDAK = OK * (Pow((P * 0.001), 0.286))
    ;
    ;       TDA= TDAK-273.15
    ;       Return
    ;       End
    ;
    ProcedureReturn TDAK - #TD_CTA                                         
  EndProcedure
   
  Procedure.d TSA(OS.d, P.d )            ; RET [°C]                     
  ; ======================================================================
  ; NAME: TSA
  ; DESC: temperature on a saturation adiabat
  ; VAR(OS.d): 
  ; VAR(P.d): Pressure [Pa]
  ; RET.d: Temperature [°C]
  ; ======================================================================
    Protected b.d, a.d, d.d, i.i, x.d, TQK.d, TQ.d
    ;
    ; *** matches
    ;
    ;       FUNCTION TSA(OS,P)
    ;
    ;   THIS FUNCTION RETURNS THE TEMPERATURE TSA (CELSIUS) ON A SATURATION
    ;   ADIABAT AT PRESSURE P (MILLIBARS). OS IS THE EQUIVALENT POTENTIAL
    ;   TEMPERATURE OF THE PARCEL (CELSIUS). SIGN(A,B) REPLACES THE
    ;   ALGEBRAIC SIGN OF A With THAT OF B.
    ;   B IS AN EMPIRICAL CONSTANT APPROXIMATELY EQUAL To 0.001 OF THE LATENT
    ;   HEAT OF VAPORIZATION For WATER DIVIDED BY THE SPECIFIC HEAT AT CONSTANT
    ;   PRESSURE For DRY AIR.
    ;
    ;         Data B/2.6518986/
    ;
    b = 2.6518986
    ;
    ;         A= OS+273.15
    ;
    a = OS + #TD_CTA
    ;
    ;   TQ IS THE FIRST GUESS For TSA.
    ;
    ;       TQ= 253.15
    ;
    TQ = 253.15
    ;
    ;   D IS AN INITIAL VALUE USED IN THE ITERATION BELOW.
    ;
    ;       D = 120.
    ;
    d = 120
    ;
    ;   ITERATE To OBTAIN SUFFICIENT ACCURACY....SEE TABLE 1, P.8
    ;   OF STIPANUK (1973) For EQUATION USED IN ITERATION.
    ;
    ;       DO 1 I= 1,12
    ;          TQK= TQ-273.15
    ;          D= D/2.
    ;          X= A*Exp(-B*W(TQK,P)/TQ)-TQ*((1000./P)**.286)
    ;          If (Abs(X).LT.1E-7) GO To 2
    ;          TQ= TQ+Sign(D,X)
    ;  1    Continue
    ;  2    TSA= TQ-273.15
    ;
    ;       Return
    ;       End
    
    For i = 1 To 12
      TQK = TQ - #TD_CTA
      d = d/2
      x= a * Exp(-b * W(TQK, P) / TQ) - TQ * Pow((1000 / P), 0.286)
      
      If Abs(x) < 1e-7 
        Break
      EndIf
            
      ;   Function SIGN(x.d, y.d)               ; FORTRAN sign statement
      ;     ; equivalent to the fortran statement SIGN(x,y)
      ;     ; which is pretty much the same as:
      ;     If y >= 0
      ;       Return Abs(x)                                  
      ;     Else
      ;       Return -Abs(x)                                
      ;     EndIf    
      ;   EndFunction
      
      ; SIGN is only used here, so we can exchange it with an If

      ; TQ + SIGN(d, x)
      If x <0
        TQ -Abs(d)  
      Else
        TQ + Abs(d)
      EndIf      
    Next i
    
    ProcedureReturn TQ - #TD_CTA                                         
  EndProcedure

  Procedure.d TMR(W.d, P.d)         ; RET [°C]                             
  ; ======================================================================
  ; NAME: TMR
  ; DESC: temperature at a mixing ratio line at given pressure
  ; VAR(W.d): 
  ; VAR(P.d): Pressure [mbar]
  ; RET.d: Temperature [°C]
  ; ======================================================================
    
    Protected  x.d, TMRK.d, f.d
    ;
    ; *** matches, may be inaccurate
    ;
    ;   FUNCTION TMR(W,P)
    ;
    ;   THIS FUNCTION RETURNS THE TEMPERATURE (CELSIUS) ON A MIXING
    ;   RATIO LINE W (G/KG) AT PRESSURE P (MB). THE FORMULA IS GIVEN IN
    ;   TABLE 1 ON PAGE 7 OF STIPANUK (1973).
    ;
    ;   INITIALIZE CONSTANTS
    ;
    ;         Data C1/.0498646455/,C2/2.4082965/,C3/7.07475/
    ;         Data C4/38.9114/,C5/.0915/,C6/1.2035/
    ;
    
    #_C1 = 0.0498646455
    #_C2 = 2.4082965
    #_C3 = 7.07475
    #_C4 = 38.9114
    #_C5 = 0.0915
    #_C6 = 1.2035
    ;
    ;         X= ALOG10(W*P/(622.+W))
    ;
    x = Log10(W * P / (622 + W))
    ;
    ;  TMRK= 10.**(C1*X+C2)-C3+C4*((10.**(C5*X)-C6)**2.)
    ;
    ;  TMRK = Pow(10, (c1 * x + c2 )) - c3 + c4 * ( Pow(( Pow(10, (c5 * x)) - c6 ) , 2))
    ;
    TMRK = Pow(10, #_C5 *x) - #_C6
    TMRK = #_C4 * Pow(TMRK, 2)
    TMRK = Pow(10, (#_C1 * x + #_C2 )) - #_C3 + TMRK
    ;
    ;         TMR= TMRK-273.15
    ;         Return
    ;         End
    ;
    ProcedureReturn (TMRK - #TD_CTA)
    ;
   EndProcedure    
     
  ;- ---------------------------------------------------------------------------
  ;-  D) Other Functions 
  ;- ---------------------------------------------------------------------------
  
  Procedure.d HEATL(T.d, Key.i=#TD_HEATL_KEY_EVAPORATION)
  ; ======================================================================
  ; NAME: HEATL
  ; DESC: RETURNS THE LATENT HEAT OF
  ; DESC:     EVAPORATION/CONDENSATION 
  ; DESC:     MELTING/FREEZING         
  ; DESC:     SUBLIMATION/DEPOSITION   
  ; DESC: FOR WATER. THE LATENT HEAT HEATL (J/kg) IS A
  ; DESC: FUNCTION OF TEMPERATURE T (°C). THE FORMULAS ARE POLYNOMIAL
  ; DESC: APPROXIMATIONS To THE VALUES IN TABLE 92, P. 343 OF THE SMITHSONIAN
  ; DESC: METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963 BY ROLAND List.
  ; DESC: THE APPROXIMATIONS WERE DEVELOPED BY ERIC SMITH AT COLORADO STATE
  ; DESC: UNIVERSITY.
  ; VAR(Key)
  ; VAR(T.d): Temperature [°C]
  ; RET.d: J/kg
  ; ======================================================================
    
    ;         FUNCTION HEATL(KEY,T)
    ; C   THIS FUNCTION RETURNS THE LATENT HEAT OF
    ; C               EVAPORATION/CONDENSATION         For KEY=1
    ; C               MELTING/FREEZING                 For KEY=2
    ; C               SUBLIMATION/DEPOSITION           For KEY=3
    ; C   For WATER. THE LATENT HEAT HEATL (JOULES PER KILOGRAM) IS A
    ; C   FUNCTION OF TEMPERATURE T (CELSIUS). THE FORMULAS ARE POLYNOMIAL
    ; C   APPROXIMATIONS To THE VALUES IN TABLE 92, P. 343 OF THE SMITHSONIAN
    ; C   METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963 BY ROLAND List.
    ; C   THE APPROXIMATIONS WERE DEVELOPED BY ERIC SMITH AT COLORADO STATE
    ; C   UNIVERSITY.
    ; C   POLYNOMIAL COEFFICIENTS
    ;
    ;         Data A0,A1,A2/ 3337118.5,-3642.8583, 2.1263947/
    ;         Data B0,B1,B2/-1161004.0, 9002.2648,-12.931292/
    ;         Data C0,C1,C2/ 2632536.8, 1726.9659,-3.6248111/
    ;         HLTNT = 0.
    ;         TK = T+273.15
    ;         If (KEY.EQ.1) HLTNT=A0+A1*TK+A2*TK*TK
    ;         If (KEY.EQ.2) HLTNT=B0+B1*TK+B2*TK*TK
    ;         If (KEY.EQ.3) HLTNT=C0+C1*TK+C2*TK*TK
    ;         HEATL = HLTNT
    ;         Return
    ;         End
    
    Protected.d a, b, c
    Protected.d TK= T+ #TD_CTA

    Select Key
        
      Case #TD_HEATL_KEY_EVAPORATION
        Restore HEATL_EVAPORATION
        
      Case #TD_HEATL_KEY_MELTING
        Restore HEATL_MELTING
        
      Case #TD_HEATL_KEY_SUBLIMATION
        Restore HEATL_SUBLIMATION
        
      Default
        
    EndSelect
    
    ; READ POLYNOMIAL COEFFICIENTS FROM DataSection
    Read.d a
    Read.d b
    Read.d c
    
    ; HEATL = a + b*TK + c*TK²
    ProcedureReturn a + b * TK + c * TK * TK
    
    DataSection     ; PB supports Private DataSection in Procedure
      HEATL_EVAPORATION:
      Data.d  3337118.5,-3642.8583, 2.1263947   ; A0,A1,A2
      
      HEATL_MELTING:
      Data.d -1161004.0, 9002.2648,-12.931292   ; B0,B1,B2
      
      HEATL_SUBLIMATION:
      Data.d  2632536.8, 1726.9659,-3.6248111   ; C0,C1,C2
    EndDataSection
  
  EndProcedure
  
  ;- ---------------------------------------------------------------------------
  ;-  E) Miscellaneous  Functions 
  ;- ---------------------------------------------------------------------------
  
  Procedure Z(PT.d, Array P.d(1), Array T.d(1), Array TD.d(1), N.i)
     
    ;   FUNCTION Z(PT,P,T,TD,N)
      ;
    ; C   THIS FUNCTION RETURNS THE THICKNESS OF A LAYER BOUNDED BY PRESSURE
    ; C   P(1) AT THE BOTTOM And PRESSURE PT AT THE TOP.
    ; C   ON INPUT:
    ; C       P = PRESSURE (MB).  NOTE THAT P(I).GT.P(I+1).
    ; C       T = TEMPERATURE (CELSIUS)
    ; C       TD = DEW Point (CELSIUS)
    ; C       N = NUMBER OF LEVELS IN THE SOUNDING And THE DIMENSION OF
    ; C           P, T And TD
    ; C   ON OUTPUT:
    ; C       Z = GEOMETRIC THICKNESS OF THE LAYER (M)
    ; C   THE ALGORITHM INVOLVES NUMERICAL INTEGRATION OF THE HYDROSTATIC
    ; C   EQUATION FROM P(1) To PT. IT IS DESCRIBED ON P.15 OF STIPANUK
    ; C   (1973).
    ;
    ;         DIMENSION T(1),P(1),TD(1),TK(100)
    ;
    ; C       C1 = .001*(1./EPS-1.) WHERE EPS = .62197 IS THE RATIO OF THE
    ; C                             MOLECULAR WEIGHT OF WATER To THAT OF
    ; C                             DRY AIR. THE FACTOR 1000. CONVERTS THE
    ; C                             MIXING RATIO W FROM G/KG To A DIMENSION-
    ; C                             LESS RATIO.
    ; C       C2 = R/(2.*G) WHERE R IS THE GAS CONSTANT For DRY AIR
    ; C                     (287 KG/JOULE/DEG K) And G IS THE ACCELERATION
    ; C                     DUE To THE EARTH'S GRAVITY (9.8 M/S**2). THE
    ; C                     FACTOR OF 2 IS USED IN AVERAGING TWO VIRTUAL
    ; C                     TEMPERATURES.
    ;
    ;         Data C1/.0006078/,C2/14.64285/
    
    ;         DO 5 I= 1,N
    ;            TK(I)= T(I)+273.15
    ;     5   Continue
    ;         Z= 0.0
    ;         If (PT.LT.P(N)) GO To 20
    ;         I= 0
    ;    10   I= I+1
    ;         J= I+1
    ;         If (PT.GE.P(J)) GO To 15
    ;         A1= TK(J)*(1.+C1*W(TD(J),P(J)))
    ;         A2= TK(I)*(1.+C1*W(TD(I),P(I)))
    ;         Z= Z+C2*(A1+A2)*(ALOG(P(I)/P(J)))
    ;         GO To 10
    ;    15   Continue
    ;         A1= TK(J)*(1.+C1*W(TD(J),P(J)))
    ;         A2= TK(I)*(1.+C1*W(TD(I),P(I)))
    ;         Z= Z+C2*(A1+A2)*(ALOG(P(I)/PT))
    ;         Return
    ;  20     Z= -1.0
    ;         Return
    ;         End
    
    Protected.d Z
    Protected.i I
    Protected Dim TK(N)
    
    #__C1 = 0.0006078
    #__C2 = 14.64285
    
    For I = 0 To N
      TK(I) = T(I) + #TD_CTA  
    Next
  ; TODO Finish code
    
  EndProcedure
  
  Procedure.d DryToWet(T.d, rH.d)    ; by Bernd Kuemmel
  ; ======================================================================
  ; NAME: DryToWet
  ; DESC: convert dry bulb to wet bulb temperature
  ; DESC: The wet-bulb temperature is the lowest temperature that can be
  ; DESC: reached under current ambient conditions by the evaporation
  ; DESC: of water only!
  ; VAR(T.d): Temperature [°C]
  ; VAR(rH.d):
  ; RET.d: wet bulb temperature
  ; ======================================================================
    Protected e.d, TD.d, gamma.d, delta.d, wet.d
    
    ; ruben strijk, based on bernd kuemmel
     
    e = (rH / 100) * 0.611 * Exp(17.27 * T / (T + 237.3))
    TD = (116.9 + 237.3 * Log(e)) / (16.78 - Log(e))
    gamma = 0.00066 * 101.325
    delta = 4098 * e / Pow((TD + 237.3) , 2)
    wet = ((gamma * T) + (delta * TD)) / (gamma + delta)
    
    ProcedureReturn wet
  EndProcedure
  
EndModule

  ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;- ---------------------------------------------------------------------- 

CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  Structure TNIST
    T.d
    ES.d[10]
  EndStructure
  
  Debug "SizeOf TNIST = " + Str(SizeOf(TNIST))
  
  Structure pNIST
    rec.TNIST[0]  
  EndStructure
  
  Global *TabNIST.pNIST
  
  *TabNIST = ?NIST_ESAT_TAB  ; now we have an Array of TNIST overlayed on TAB_TNIST
  #TabNIST = 100
  
  UseModule TD
  
;   Define I
;   For I = 0 To 100
;     With *TabNIST\rec[I]
;       Debug Str( \T) + " : " + \ES[0]   
;     EndWith
;   Next
  
  Procedure Test_ESAT()                     ; test all schlatter and baker routines
    Protected.i n
    Protected.d P, T, TD, x, e, W, rH, sat, TC
    ;
    ; TEMP  ESW     ES     ESAT    ESGG    ESRW    ESLO    SMITH.(340)
    ; ---- -----  -----   ------  ------  ------  ------   ------
    ; -50 .06356  .06357  .06356  .06356  .06362  .06337   .06356
    ; -30 .50878  .51036  .50878  .50880  .50843  .50877   .5088
    ; -10 2.8627  2.8677  2.8626  2.8627  2.8625  2.8635   2.8627
    ;   0 6.1080  6.1121  6.1076  6.1078  6.1084  6.1078   6.1078
    ;  10 12.272  12.272  12.272  12.272  12.274  12.271   12.272
    ;  20 23.372  23.370  23.372  23.373  23.375  23.371   23.373
    ;  30 42.430  42.457  42.429  42.430  42.431  42.429   42.430
    ;
    DataSection
      DATA_ESAT:
      Data.d -50 , -30 , -10 , 0 , 10 , 20 , 30
    EndDataSection
    
    #dec = 3
    Debug ""
    Debug "ESW - matches"
    Debug "--------------"
    Restore DATA_ESAT
   
    For n = 1 To 7
      Read.d T
      Debug FormatNumber(ESW(T),#dec)
    Next
    
    Debug ""
    Debug "ES - matches"
    Debug "------------"
    
    Restore DATA_ESAT
    For n = 1 To 7
      Read.d T
      Debug FormatNumber(ES(T), #dec)
    Next n
    
    Debug ""
    Debug "ESAT - matches"
    Debug "--------------"
    
    Restore DATA_ESAT
    For n = 1 To 7
      Read.d T
      Debug FormatNumber(ESAT(T),  #dec)
    Next
       
    Debug ""
    Debug "NIST - matches"
    Debug "--------------"
    
    For n = 0 To 30 Step 10
      Debug FormatNumber(*TabNIST\rec[n]\ES[0]/100,  #dec)
    Next
    
    
    
    Debug ""
    Debug "ESGG - matches"
    Debug "--------------"
    
    Restore DATA_ESAT
    For n = 1 To 7
      Read.d T
      Debug FormatNumber(ESGG(T),  #dec)
    Next
    
    Debug ""
    Debug "ESRW - matches"
    Debug "--------------"
    
    Restore DATA_ESAT
    For n = 1 To 7
      Read.d T
      Debug FormatNumber(ESRW(T), #dec)
    Next
    
    Debug ""
    Debug "ESLO - matches"
    Debug "--------------"
    
    Restore DATA_ESAT
    For n = 1 To 7
      Read.d T
      Debug FormatNumber(ESLO(T), #dec)
    Next
    
    Debug #Null$
    #Loops = 5000 *1000
    T= 20
    Define.d ms = ElapsedMilliseconds()
    For n = 1 To #Loops
      e= ESAT(T)
    Next
    ms = (ElapsedMilliseconds() -ms) / 1000
    MessageRequester("Time", "ESAT : " + FormatNumber(ms,3) +"ms")
    
  EndProcedure
  
  Procedure Test_WMR()
    Protected.i n
    Protected.d P, T
    
    ; PRES  TEMP     WMR      W       SMITH.(302)
    ; ----  ----   ------   ------    ------
    ; 1000   30    27.699   27.560    27.69
    ; 1000    0     3.840    3.822     3.839
    ;  850   10     9.147    9.112     9.146
    ;  700   10    11.135   11.099    11.13
    ;  500  -20     1.568    1.564     1.568
    ;  400  -30     0.794    0.792     0.794
    ;
    DataSection
      DATA_w:
      Data.d 1000,30
      Data.d 1000,0
      Data.d 850,10
      Data.d 700,10
      Data.d 500,-20
      Data.d 400,-30
    EndDataSection
    
    Debug ""
    Debug "WMR - matches"
    Debug "------------"
    
    Restore DATA_w
    For n = 1 To 6
      Read.d P
      Read.d T
      Debug WMR(P, T)
    Next 
    Debug ""
    Debug "W - matches"
    Debug "----------"
    
    Restore DATA_w
    For n = 1 To 6
      Read.d P
      Read.d T
      Debug W(T,P)
    Next 
    
  EndProcedure
  
  Procedure Test_TCON()
    Protected.i n
    Protected.d P, T, TD
    
    ; TEMP  DWPT    TCON    TLCL    TLCL1    SMITH.(329)
    ; ----  ----   ------  ------  ------    ------
    ;  40    20    15.473  15.449  15.450    15.48
    ; -20   -45   -48.703 -48.768 -48.689   -48.79
    ;  10   -20   -25.237 -25.295 -29.401   -25.29
    ;   0   -25   -29.277 -29.331 -29.401   -29.31
    ;  30    10     5.708   5.682   5.679     5.72
    ;  40    35    33.710  33.727  33.636    33.74
    ;
    DataSection
      DATA_tcon:
      Data.d 40 , 20
      Data.d -20 , -45
      Data.d 10 , -20
      Data.d 0 , -25
      Data.d 30 , 10
      Data.d 40 , 35
    EndDataSection
    Debug ""
    Debug "TCON - matches"
    Debug "--------------"
    
    Restore DATA_tcon
    For n = 1 To 6
      Read.d T
      Read.d TD
      Debug TCON(T,TD)
    Next n
  EndProcedure
  
  Procedure Test_PCON()
   Protected.i n
   Protected.d P, T, TD, TC
   
    ; PRES  TEMP  TEML    PCON
    ; ----  ----  ----   ------
    ; 1000   35    20    839.59
    ;  975   30    20    866.89
    ;  950   15   -10    691.24
    ;  900   10   -25    566.87
    ;  500  -20   -20    500.00
    ;  500  -20   -50    321.40
    ;
    DataSection
      DATA_pcon:
      Data.d 1000 , 35 , 20
      Data.d 975 , 30 , 20
      Data.d 950 , 15 , -10
      Data.d 900 , 10 , -25
      Data.d 500 , -20 , -20
      Data.d 500 , -20 , -50
    EndDataSection
    Debug ""
    Debug "PCON - matches"
    Debug "--------------"
    
       
    For n = 1 To 6
      Read.d P
      Read.d T
      Read.d TC
      Debug PCON(T,P,TC)
    Next n
  EndProcedure
  
  Procedure Test_PTLCL()
    Protected.i n
    Protected.d P, T, TD

    ;
    ; PRES  TEMP  DWPT   PTLCL:P  PTLCL:T   ALCL
    ; ----  ----  ----   -------  -------  ------
    ; 1000   35    20     811.46   16.63   806.71
    ;  900   25    20     837.04   18.83   840.12
    ; 1000   30    28     971.57   27.51   973.34
    ;  850    0   -30     544.92  -34.66   528.01
    ;  900   16    16     900.00   16.00   900.00
    ;  700  -10   -60     333.50  -65.69   300.97
    ;
    DataSection
      DATA_plctl:
      Data.d 1000 , 35 , 20
      Data.d 900 , 25 , 20
      Data.d 1000 , 30 , 28
      Data.d 850 , 0 , -30
      Data.d 900 , 16 , 16
      Data.d 700 , -10 , -60
    EndDataSection
    Debug ""
    Debug "ALCL - matches"
    Debug "--------------"
    Debug ""
    Restore DATA_plctl
    For n = 1 To 6
      Read.d P
      Read.d T
      Read.d TD
    Debug ALCL(T, P, TD)
    Next n
  
  EndProcedure

  Procedure Test_WOBF()
    Protected.i n
    Protected.d P, T, e
   
    ;  EQPT   WOBF(=EQPT-WBPT)  SMITH.(319)
    ;  ----   ---------------   ------
    ; 205.24     165.2104       165.24
    ; 161.04     125.0629       125.04
    ; 113.04      83.1266        83.04
    ;  70.34      48.8294        48.34
    ;  54.84      37.4419        36.84
    ;  42.14      28.6543        28.14
    ;   6.74       8.8176         8.74
    ;
    DataSection
      DATA_wobf:
      Data.d 205.24
      Data.d 161.04
      Data.d 113.04
      Data.d 70.34
      Data.d 54.84
      Data.d 42.14
      Data.d 6.74
    EndDataSection
    Debug ""
    Debug "WOBF - matches"
    Debug "--------------"
    Restore DATA_wobf
    For n = 1 To 7
      Read.d e
      Debug WOBF(e)
    Next n
  EndProcedure
  
  Procedure Test_POWT()
    Protected.i n
    Protected.d P, T, TD
    
    
    ; TEMP  DWPT  PRES   POWT    OW
    ; ----  ----  ----  -----   -----
    ;  35    25   1000  27.55   27.61
    ;  10   -15   1000   2.13    1.83
    ; -10   -60    850  -4.64   -4.68
    ;  15    10    900  16.29   16.42
    ;  37    30   1050  29.98   30.13
    ;  -5    -5    500  22.05   22.22
    ;
    DataSection
      DATA_powt:
      Data.d 35 , 25 , 1000
      Data.d 10 , -15 , 1000
      Data.d -10 , -60 , 850
      Data.d 15 , 10 , 900
      Data.d 37 , 30 , 1050
      Data.d -5 , -5 , 500
    EndDataSection
    Debug ""
    Debug "POWT - matches"
    Debug "--------------"
    Restore DATA_powt
    For n = 1 To 6
      Read.d T
      Read.d TD
      Read.d P
      Debug POWT(T,TD,P)
    Next n
    Debug ""
    Debug "OW - matches"
    Debug "------------"
    Restore DATA_powt
    For n = 1 To 6
      Read.d T
      Read.d TD
      Read.d P
      Debug OW(T,TD,P)
    Next n
      
  EndProcedure 
  
  Procedure Test_DEWPT()
    Protected.i n
    Protected.d P, T, sat

    ; SAT.VP.    DPT    DEWPT    SMITH.(351)
    ; -------  ------  ------    ------
    ; 0.1891  -40.002  -40.025    -40
    ; 1.2540  -20.000  -20.032    -20
    ; 2.8627  -10.000  -10.022    -10
    ; 6.1078    0.000   -0.010      0
    ; 12.272   10.000   10.000     10
    ; 23.373   20.000   20.003     20
    ;
    DataSection
      DATA_dpt:
      Data.d 0.1891
      Data.d 1.2540
      Data.d 2.8627
      Data.d 6.1078
      Data.d 12.272
      Data.d 23.373
    EndDataSection
    Debug ""
    Debug "DPT - matches"
    Debug "------------"
    Restore DATA_dpt
    For n = 1 To 6
      Read.d sat
      Debug DPT(sat)
    Next n
    Debug ""
    Debug "DEWPT - matches"
    Debug "---------------"
    Restore DATA_dpt
    For n = 1 To 6
      Read.d sat
      Debug DEWPT(sat)
    Next 
  EndProcedure
  
  Procedure Test_HUM()
    Protected.i n
    Protected P, T, TD

    ; PRES     THETAW  SATLFT   SMITH.
    ; ------   ------  -------   ------
    ;  204.3    34    -19.791    -20
    ;  200      20    -60.356    -62
    ; 1071.4    38     40.151     40
    ;  501      32      9.941     10
    ;  422.7     0    -51.876    -52
    ;
    ; TEMP  DWPT   HUM
    ; ----  ----  -----
    ;  35    30   75.46
    ;  25    10   38.77
    ;   0   -15   31.18
    ;  20   -10   12.22
    ;  30    28   89.09
    ;
    Debug ""
    Debug "HUM - matches"
    Debug "-------------"
    DataSection
      DATA_hum:
      Data.d 35 , 30
      Data.d 25 , 10
      Data.d 0 , -15
      Data.d 20 , -10
      Data.d 30 , 28
    EndDataSection
    Restore DATA_hum
    For n = 1 To 5
      Read.d T
      Read.d TD
      Debug HUM(T,TD)
    Next
    
  EndProcedure
  
  Procedure Test_TW()
    Protected n
    Protected.d P, T, TD
   
    ; TEMP  DWPT  PRES   TW
    ; ----  ----  ----  -----
    ;  30    15   1000  19.99
    ;   0   -20    700  -6.05
    ;  10     0    850   5.11
    ; -15   -25    500 -17.39
    ;  25    20    900  21.57
    ;
    Debug ""
    Debug "TW - matches"
    Debug "------------"
    DataSection
      DATA_tw:
      Data.d 30,15,1000
      Data.d 0,-20,700
      Data.d 10,0,850
      Data.d -15,-25,500
      Data.d 25,20,900
    EndDataSection
    Restore DATA_tw
    For n = 1 To 5
      Read.d T
      Read.d TD
      Read.d P
      Debug TW(T,TD,P)
    Next
    
  EndProcedure
  
  Procedure Test_OE()
    Protected.i n
    Protected.d P, T
    

    ; TEMP  DWPT  PRES    OE     EPT
    ; ----  ----  ----   -----  -----
    ;  30    15   1000   62.24  62.49
    ;  0    -20    700   33.10  33.01
    ;  10     0    850   36.97  37.01
    ; -15   -25    500   45.04  45.02
    ;  25    20    900   85.02  84.60
    ;
    ; TEMP  DWPT  PRES    TE
    ; ----  ----  ----   -----
    ;  30    15   1000   62.24
    ;   0   -20    700    3.31
    ;  10     0    850   22.88
    ; -15   -25    500  -12.18
    ;  25    20    900   74.38
    ;
    ;  THETA  PRES     TDA     SMITH.(308)
    ;  -----  ----    ------   ------
    ; 132.74   250     -0.12      0
    ;  35.44   500    -20.05    -20
    ; -14.66  1050    -11.03    -11
    ;  28.64   850     14.93    -15
    ;  18.24   700    -10.02    -10
    ;
    DataSection
      DATA_tda:
      Data.d 132.74 , 250
      Data.d  35.44 , 500
      Data.d -14.66 , 1050
      Data.d  28.64 , 850
      Data.d  18.24 , 700
    EndDataSection
    Debug ""
    Debug "TDA - matches"
    Debug "------------"
    Restore DATA_tda
    For n = 1 To 4
      Read.d T
      Read.d P
      Debug TDA(T,P)
    Next n
    
  EndProcedure
  
  Procedure Test_TSA()
    Protected.i n
    Protected.d P, T, e

    ;   EQPT    PRES     TSA      TMLAPS    SMITH.(319)
    ; ------   ------   ------    -------   ------
    ; 181.64   870.9    34.170    33.940     34
    ; 113.04   577.0    12.139    12.080     12
    ;  70.34   896.0    18.057    17.950     18
    ;  10.24   496.0   -41.766   -41.669    -42
    ;  54.84   309.5   -39.658   -39.600    -40
    ;
    Debug ""
    Debug "TSA - matches"
    Debug "------------"
    DataSection
      DATA_tsa:
      Data.d 181.64 , 870.9
      Data.d 113.04 , 577.0
      Data.d 70.34 , 896.0
      Data.d 10.24 , 496.0
      Data.d 54.84 , 309.5
    EndDataSection
    Restore DATA_tsa
    For n = 1 To 5
      Read.d e
      Read.d P
      Debug TSA(e,P)
    Next n
  EndProcedure
  
  Procedure Test_O()
    Protected n
    Protected.d  P, T
    
    ; TEMP  PRES      O    SMITH.(309)
    ; ----  ----    -----  ------
    ; -35   850    -23.66  -23.66
    ; -10   500     47.74   47.74
    ; -20   950    -16.26  -16.26
    ;  10  1000     10.04   10.00
    ;
    Debug ""
    Debug "O - matches"
    Debug "----------"
    DataSection
      DATA_o:
      Data.d -35,850
      Data.d -10,500
      Data.d -20,950
      Data.d 10,1000
    EndDataSection
    Restore DATA_o
    For n = 1 To 4
      Read.d T
      Read.d P
      Debug O(T,P)
    Next n
     
    ;
    ; TEMP   PRES    OS      SMITH.(319)
    ; ----  -----  ------   -------
    ;   0   275.3  179.88    181.64
    ; -10   321.4  112.03    113.04
    ;  10   501.0  126.27    127.34
    ;  10   816.0   54.89     54.84
    ; -50   282.7   47.63     48.14
    ;
    Debug ""
    Debug "OS - matches"
    Debug "----------"
    DataSection
      DATA_os:
      Data.d 0 , 257.3
      Data.d -10 , 321.4
      Data.d 10 , 501.0
      Data.d 10 , 816.0
      Data.d -50 , 282.7
    EndDataSection
    Restore DATA_os
    For n = 1 To 5
      Read.d T
      Read.d P
      Debug OS(T,P)
    Next n
  EndProcedure
  
    
  Procedure Test_TMR()
    Protected n
    Protected.d P, T, W, rH

    ;   W   PRES   TMR    SMITH.(302)
    ; ----- ----  -----   ------
    ; 9.146  850  10.07    10
    ; 1.120  700 -19.96   -20
    ; 7.710  500   0.03     0
    ; 1.960  400 -19.97   -20
    ; 14.95 1000  20.10    20
    ;
    Debug ""
    Debug "TMR - matches"
    Debug "----------"
    DataSection
      DATA_TMR:
      Data.d 9.146 , 850
      Data.d 1.120 , 700
      Data.d 7.710 , 500
      Data.d 1.960 , 400
      Data.d 14.95 , 1000
    EndDataSection
    Restore DATA_TMR
    For n = 1 To 5
      Read.d W
      Read.d P
      Debug TMR(W,P)
    Next n
    ;
    ; TEMP    PRES     THM     SMITH.(319)
    ; ----   ------   ------   ------
    ;  12    369.6    46.277    40
    ; -32    188.2    41.376    32
    ;  38    1069.8   35.751    36
    ;  10     908.    14.205    14
    ; -14     648.     7.841     8
    ; -50    301.7    13.961    14
    ;
    Debug ""
    Debug "THM - matches"
    Debug "----------"
    DataSection
      DATA_thm:
      Data.d 12 , 369.6
      Data.d -32 , 188.2
      Data.d 38 , 1069.8
      Data.d 10 , 908.0
      Data.d -14 , 648.0
      Data.d -50 , 301.7
    EndDataSection
    Restore DATA_thm
    For n = 1 To 6
      Read.d T
      Read.d P
      Debug THM(T,P)
    Next n
    ;
    ; TEMP  REL.HUM.   TD     TD*
    ; ----  -------- ------  -----
    ;  35    75.46   30.14    30
    ;  25    38.77    9.93    10
    ;   0    31.18  -15.19   -15
    ;  20    12.22  -10.16   -10
    ;  30    89.09   28.01    28
    ;
    Debug ""
    Debug "DWPT - matches"
    Debug "--------------"
    DataSection
      DATA_dwpt:
      Data.d 35 , 75.46
      Data.d 25 , 38.77
      Data.d 0 , 31.18
      Data.d 20 , 12.22
      Data.d 30 , 89.09
    EndDataSection
    Restore DATA_dwpt
    For n = 1 To 5
      Read.d T
      Read.d rH
      Debug DWPT(T,rH)
    Next n
    ;
    ; PRES  TEMP   SSH
    ; ----  ----  -----
    ; 1000   10    7.70
    ; 1000    0    3.82
    ;  850  -10    2.11
    ;  700    0    5.46
    ;  500  -20    1.57
    ;  300  -30    1.06
    ;
    Debug ""
    Debug "SSH - matches"
    Debug "--------------"
    DataSection
      DATA_ssh:
      Data.d 1000 , 10
      Data.d 1000 , 0
      Data.d 850 , -10
      Data.d 700 , 0
      Data.d 500 , -20
      Data.d 300 , -30
    EndDataSection
    Restore DATA_ssh:
    For n = 1 To 6
      Read.d P
      Read.d T
      Debug SSH(T,P)
    Next n
    ;
    ; TEMP  DWPT  PRES    TV
    ; ----  ----  ----   -----
    ;  30    25   1000   33.69
    ;  20     0   1000   20.68
    ;  10   -10    850   10.36
    ;   0   -10    700    0.42
    ; -20   -30    500  -19.90
    ; -40   -60    300  -39.99
    ;
    ; TEMP   ESICE    ESILO    SMITH.(360)
    ; ----  -------  -------   ------
    ; -50   .03935   .03963   .03935
    ; -40   .1283    .1283    .1283
    ; -30   .3798    .3796    .3798
    ; -20   1.032    1.032    1.032
    ; -10   2.597    2.596    2.597
    ;
    ; TEMP    KEY=1     SMITH.    KEY=2      SMITH.     KEY=3      SMITH.
    ; ----  --------    -------  --------    ------   ---------    ------
    ; -100                                            674.2192     674.4
    ;  -80                                            676.1257     676.3
    ;  -60                                            677.3396     677.5
    ;  -50  628.1667    629.3     48.7133     48.6
    ;  -40                        56.1209     56.3    677.8610     678.0
    ;  -30  615.5021    615.0     62.9107     63.0
    ;  -20                        69.0828     69.0    677.6898     677.9
    ;  -10  603.2438    603.0     74.6372     74.5    677.3444     677.5
    ;    0  597.2670    597.3     79.5740     79.7    676.8259     677.0
    ;   10  591.3918    591.7
    ;   20  585.6181    586.0
    ;   40  574.3755    574.7
    ;   50  568.9066    569.0
    ;
    ;
    ; PRES  TEMP     WMR      W       SMITH.(302)
    ; ----  ----   ------   ------    ------
    ; 1000   30    27.699   27.560    27.69
    ; 1000    0     3.840    3.822     3.839
    ;  850   10     9.147    9.112     9.146
    ;  700   10    11.135   11.099    11.13
    ;  500  -20     1.568    1.564     1.568
    ;  400  -30     0.794    0.792     0.794
    ;
  EndProcedure
  
  Procedure Test_All_SchlatterAndBaker()
    Test_ESAT()
    
  EndProcedure
  
  ; *** main
  
  Procedure example()                                      
    Protected dry.d, dew.d, rH.d, wet.d
    ;
    ; converting dry bulb to wet bulb using schlatter and baker
    ;
    dry = 20
    rH = 50
    dew = DWPT(dry, rH)
    wet = TW(dry, dew, 1000)
    
    Debug #Null$
    Debug "DryToWet Schlatter and Baker"
    Debug "dry "+StrD(dry,4)+" at rH "+StrD(rH,4)+" -> wet "+StrD(wet,4)
    ;
    ; converting dry bulb to wet bulb using bernd kuemmel
    ;
    wet = DryToWet(dry,rH)
    Debug #Null$
    Debug "DryToWet Bernd Kuemmel"
    Debug "dry "+StrD(dry,4)+" at rH "+StrD(rH,4)+" -> wet "+StrD(wet,4)
    ;
  EndProcedure

  Test_All_SchlatterAndBaker()
  Debug ""
  example()
  UnuseModule TD
  
  DataSection
    ; This are the exact values measured in the Range form 0..100°C in Steps of 0.1°C 
    NIST_ESAT_TAB:  ; Temperature [°C] = Pressure [Pa] ; Values form original NIST Table 1976 
    ;      °C,       .0 ,       .1 ,       .2 ,       .3 ,       .4 ,       .5 ,       .6 ,       .7 ,       .8 ,      .9 ,
    Data.d  0,    611.21,    615.67,    620.15,    624.66,    629.20,    633.77,    638.37,    643.00,    647.66,    652.35
    Data.d  1,    657.07,    661.82,    666.60,    671.41,    676.25,    681.12,    686.02,    690.96,    695.92,    700.92
    Data.d  2,    705.95,    711.01,    716.10,    721.23,    726.39,    731.58,    736.80,    742.06,    747.34,    752.67
    Data.d  3,    758.02,    763.41,    768.84,    774.29,    779.79,    785.31,    790.87,    796.47,    802.10,    807.77
    Data.d  4,    813.47,    819.20,    824.98,    830.79,    836.63,    842.51,    848.43,    854.38,    860.38,    866.40
    Data.d  5,    872.47,    878.57,    884.71,    890.89,    897.11,    903.36,    909.66,    915.99,    922.36,    928.77
    Data.d  6,    935.22,    941.71,    948.24,    954.81,    961.42,    968.07,    974.76,    981.49,    988.26,    995.08
    Data.d  7,   1001.93,   1008.83,   1015.76,   1022.74,   1029.77,   1036.83,   1043.94,   1051.09,   1058.29,   1065.52
    Data.d  8,   1072.80,   1080.13,   1087.50,   1094.91,   1102.37,   1109.87,   1117.42,   1125.01,   1132.65,   1140.33
    Data.d  9,   1148.06,   1155.84,   1163.66,   1171.53,   1179.45,   1187.41,   1195.42,   1203.48,   1211.58,   1219.74
    Data.d 10,   1227.94,   1236.19,   1244.49,   1252.84,   1261.24,   1269.68,   1278.18,   1286.73,   1295.33,   1303.97
    Data.d 11,   1312.67,   1321.42,   1330.22,   1339.08,   1347.98,   1356.94,   1365.95,   1375.01,   1384.12,   1393.29
    Data.d 12,   1402.51,   1411.79,   1421.11,   1430.50,   1439.93,   1449.43,   1458.97,   1468.58,   1478.23,   1487.95
    Data.d 13,   1497.72,   1507.54,   1517.43,   1527.36,   1537.36,   1547.42,   1557.53,   1567.70,   1577.93,   1588.21
    Data.d 14,   1598.56,   1608.96,   1619.43,   1629.95,   1640.54,   1651.18,   1661.89,   1672.65,   1683.48,   1694.37
    Data.d 15,   1705.32,   1716.33,   1727.41,   1738.54,   1749.75,   1761.01,   1772.34,   1783.73,   1795.18,   1806.70
    Data.d 16,   1818.29,   1829.94,   1841.66,   1853.44,   1865.29,   1877.20,   1889.18,   1901.23,   1913.34,   1925.53
    Data.d 17,   1937.78,   1950.10,   1962.48,   1974.94,   1987.47,   2000.06,   2012.73,   2025.46,   2038.27,   2051.14
    Data.d 18,   2064.09,   2077.11,   2090.20,   2103.37,   2116.61,   2129.92,   2143.30,   2156.75,   2170.29,   2183.89
    Data.d 19,   2197.57,   2211.32,   2225.15,   2239.06,   2253.04,   2267.10,   2281.23,   2295.44,   2309.73,   2324.10
    Data.d 20,   2338.54,   2353.07,   2367.67,   2382.35,   2397.11,   2411.95,   2426.88,   2441.88,   2456.94,   2472.13
    Data.d 21,   2487.37,   2502.70,   2518.11,   2533.61,   2549.18,   2564.85,   2580.59,   2596.42,   2612.33,   2628.33
    Data.d 22,   2644.42,   2660.59,   2676.85,   2693.19,   2709.62,   2726.14,   2742.75,   2759.45,   2776.23,   2793.10
    Data.d 23,   2810.06,   2827.12,   2844.26,   2861.49,   2878.82,   2896.23,   2913.74,   2931.34,   2949.04,   2966.82
    Data.d 24,   2984.70,   3002.68,   3020.74,   3038.91,   3057.17,   3075.52,   3093.97,   3112.52,   3131.16,   3149.90
    Data.d 25,   3168.74,   3187.68,   3206.71,   3225.85,   3245.08,   3264.41,   3283.85,   3303.38,   3323.02,   3342.76
    Data.d 26,   3362.60,   3382.54,   3402.59,   3422.73,   3442.99,   3463.34,   3483.81,   3504.37,   3525.05,   3545.83
    Data.d 27,   3566.71,   3587.71,   3608.81,   3630.02,   3651.33,   3672.76,   3694.29,   3715.94,   3737.69,   3759.56
    Data.d 28,   3781.54,   3803.63,   3825.83,   3848.14,   3870.57,   3893.11,   3915.77,   3938.54,   3961.42,   3984.42
    Data.d 29,   4007.54,   4030.77,   4054.12,   4077.59,   4101.18,   4124.88,   4148.71,   4172.65,   4196.71,   4220.90
    Data.d 30,   4245.20,   4269.63,   4294.18,   4318.85,   4343.64,   4368.56,   4393.60,   4418.77,   4444.06,   4469.48
    Data.d 31,   4495.02,   4520.69,   4546.49,   4572.42,   4598.47,   4624.65,   4650.96,   4677.41,   4703.98,   4730.68
    Data.d 32,   4757.52,   4784.48,   4811.58,   4838.81,   4866.18,   4893.68,   4921.32,   4949.09,   4976.99,   5005.04
    Data.d 33,   5033.22,   5061.53,   5089.99,   5118.58,   5147.32,   5176.19,   5205.20,   5234.36,   5263.65,   5293.09
    Data.d 34,   5322.67,   5352.39,   5382.26,   5412.27,   5442.43,   5472.73,   5503.18,   5533.78,   5564.52,   5595.41
    Data.d 35,   5626.45,   5657.64,   5688.97,   5720.46,   5752.10,   5783.89,   5815.83,   5847.93,   5880.17,   5912.58
    Data.d 36,   5945.13,   5977.84,   6010.71,   6043.73,   6076.91,   6110.25,   6143.75,   6177.40,   6211.22,   6245.19
    Data.d 37,   6279.33,   6313.62,   6348.08,   6382.70,   6417.48,   6452.43,   6487.54,   6522.82,   6558.26,   6593.87
    Data.d 38,   6629.65,   6665.59,   6701.71,   6737.99,   6774.44,   6811.06,   6847.85,   6884.82,   6921.95,   6959.26
    Data.d 39,   6996.75,   7034.40,   7072.24,   7110.24,   7148.43,   7186.79,   7225.33,   7264.04,   7302.94,   7342.02
    Data.d 40,   7381.27,   7420.71,   7460.33,   7500.13,   7540.12,   7580.28,   7620.64,   7661.18,   7701.90,   7742.81
    Data.d 41,   7783.91,   7825.20,   7866.67,   7908.34,   7950.19,   7992.24,   8034.47,   8076.90,   8119.53,   8162.34
    Data.d 42,   8205.36,   8248.56,   8291.96,   8335.56,   8379.36,   8423.36,   8467.55,   8511.94,   8556.54,   8601.33
    Data.d 43,   8646.33,   8691.53,   8736.93,   8782.54,   8828.35,   8874.37,   8920.59,   8967.02,   9013.66,   9060.51
    Data.d 44,   9107.57,   9154.84,   9202.32,   9250.01,   9297.91,   9346.03,   9394.36,   9442.91,   9491.67,   9540.65
    Data.d 45,   9589.84,   9639.25,   9688.89,   9738.74,   9788.81,   9839.11,   9889.62,   9940.36,   9991.32,  10042.51
    Data.d 46,  10093.92,  10145.56,  10197.43,  10249.52,  10301.84,  10354.39,  10407.18,  10460.19,  10513.43,  10566.91
    Data.d 47,  10620.62,  10674.57,  10728.75,  10783.16,  10837.82,  10892.71,  10947.84,  11003.21,  11058.82,  11114.67
    Data.d 48,  11170.76,  11227.10,  11283.68,  11340.50,  11397.57,  11454.88,  11512.45,  11570.26,  11628.32,  11686.63
    Data.d 49,  11745.19,  11804.00,  11863.07,  11922.38,  11981.96,  12041.78,  12101.87,  12162.21,  12222.81,  12283.66  
    Data.d 50,  12344.78,  12406.16,  12467.79,  12529.70,  12591.86,  12654.29,  12716.98,  12779.94,  12843.17,  12906.66
    Data.d 51,  12970.42,  13034.46,  13098.76,  13163.33,  13228.18,  13293.30,  13358.70,  13424.37,  13490.32,  13556.54
    Data.d 52,  13623.04,  13689.82,  13756.88,  13824.23,  13891.85,  13959.76,  14027.95,  14096.43,  14165.19,  14234.24
    Data.d 53,  14303.57,  14373.20,  14443.11,  14513.32,  14583.82,  14654.61,  14725.69,  14797.07,  14868.74,  14940.72
    Data.d 54,  15012.98,  15085.55,  15158.42,  15231.59,  15305.06,  15378.83,  15452.90,  15527.28,  15601.97,  15676.96
    Data.d 55,  15752.26,  15827.87,  15903.79,  15980.02,  16056.57,  16133.42,  16210.59,  16288.07,  16365.87,  16443.99
    Data.d 56,  16522.43,  16601.18,  16680.26,  16759.65,  16839.37,  16919.41,  16999.78,  17080.47,  17161.49,  17242.84
    Data.d 57,  17324.51,  17406.52,  17488.86,  17571.52,  17654.53,  17737.86,  17821.53,  17905.54,  17989.88,  18074.57
    Data.d 58,  18159.59,  18244.95,  18330.66,  18416.71,  18503.10,  18589.84,  18676.92,  18764.35,  18852.13,  18940.26
    Data.d 59,  19028.74,  19117.58,  19206.76,  19296.30,  19386.20,  19476.45,  19567.06,  19658.03,  19749.35,  19841.04
    Data.d 60,  19933.09,  20025.51,  20118.29,  20211.43,  20304.95,  20398.82,  20493.07,  20587.69,  20682.68,  20778.05
    Data.d 61,  20873.78,  20969.90,  21066.39,  21163.25,  21260.50,  21358.12,  21456.13,  21554.51,  21653.28,  21752.44
    Data.d 62,  21851.98,  21951.91,  22052.23,  22152.93,  22254.03,  22355.52,  22457.40,  22559.68,  22662.35,  22765.42
    Data.d 63,  22868.89,  22972.75,  23077.02,  23181.69,  23286.76,  23392.23,  23498.12,  23604.40,  23711.10,  23818.20
    Data.d 64,  23925.72,  24033.65,  24141.99,  24250.74,  24359.91,  24469.50,  24579.51,  24689.93,  24800.78,  24912.04
    Data.d 65,  25023.74,  25135.85,  25248.39,  25361.36,  25474.76,  25588.58,  25702.84,  25817.53,  25932.66,  26048.22
    Data.d 66,  26164.21,  26280.64,  26397.52,  26514.83,  26632.58,  26750.78,  26869.42,  26988.51,  27108.04,  27228.02
    Data.d 67,  27348.46,  27469.34,  27590.68,  27712.46,  27834.71,  27957.41,  28080.57,  28204.19,  28328.26,  28452.80
    Data.d 68,  28577.81,  28703.28,  28829.21,  28955.61,  29082.48,  29209.82,  29337.64,  29465.92,  29594.68,  29723.92
    Data.d 69,  29853.63,  29983.82,  30114.49,  30245.65,  30377.28,  30509.40,  30642.01,  30775.10,  30908.68,  31042.75
    Data.d 70,  31177.32,  31312.37,  31447.92,  31583.97,  31720.51,  31857.55,  31995.09,  32133.14,  32271.68,  32410.73
    Data.d 71,  32550.29,  32690.35,  32830.93,  32972.01,  33113.61,  33255.71,  33398.34,  33541.48,  33685.13,  33829.31
    Data.d 72,  33974.01,  34119.23,  34264.97,  34411.24,  34558.03,  34705.36,  34853.21,  35001.59,  35150.51,  35299.96
    Data.d 73,  35449.95,  35600.47,  35751.54,  35903.14,  36055.29,  36207.98,  36361.21,  36514.99,  36669.32,  36824.20
    Data.d 74,  36979.63,  37135.61,  37292.15,  37449.24,  37606.89,  37765.10,  37923.87,  38083.21,  38243.10,  38403.56
    Data.d 75,  38564.59,  38726.19,  38888.36,  39051.10,  39214.41,  39378.30,  39542.76,  39707.80,  39873.42,  40039.63
    Data.d 76,  40206.41,  40373.78,  40541.74,  40710.28,  40879.42,  41049.14,  41219.46,  41390.37,  41561.88,  41733.99
    Data.d 77,  41906.69,  42080.00,  42253.91,  42428.42,  42603.54,  42779.27,  42955.61,  43132.55,  43310.11,  43488.29
    Data.d 78,  43667.08,  43846.48,  44026.51,  44207.16,  44388.43,  44570.33,  44752.85,  44936.00,  45119.77,  45304.18
    Data.d 79,  45489.23,  45674.91,  45861.22,  46048.17,  46235.76,  46424.00,  46612.87,  46802.39,  46992.56,  47183.38
    Data.d 80,  47374.85,  47566.97,  47759.74,  47953.17,  48147.25,  48342.00,  48537.40,  48733.47,  48930.20,  49127.60
    Data.d 81,  49325.67,  49524.40,  49723.81,  49923.89,  50124.64,  50326.08,  50528.19,  50730.98,  50934.45,  51138.61
    Data.d 82,  51343.45,  51548.98,  51755.20,  51962.11,  52169.72,  52378.01,  52587.01,  52796.70,  53007.10,  53218.20
    Data.d 83,  53430.00,  53642.50,  53855.72,  54069.64,  54284.28,  54499.63,  54715.69,  54932.47,  55149.97,  55368.19
    Data.d 84,  55587.13,  55806.80,  56027.20,  56248.32,  56470.17,  56692.76,  56916.08,  57140.13,  57364.92,  57590.45
    Data.d 85,  57816.73,  58043.74,  58271.51,  58500.02,  58729.27,  58959.28,  59190.05,  59421.57,  59653.84,  59886.87
    Data.d 86,  60120.67,  60355.23,  60590.55,  60826.64,  61063.50,  61301.12,  61539.52,  61778.70,  62018.65,  62259.38
    Data.d 87,  62500.89,  62743.18,  62986.26,  63230.12,  63474.78,  63720.22,  63966.45,  64213.48,  64461.31,  64709.93
    Data.d 88,  64959.35,  65209.58,  65460.61,  65712.45,  65965.09,  66218.55,  66472.82,  66727.90,  66983.80,  67240.52
    Data.d 89,  67498.06,  67756.42,  68015.60,  68275.62,  68536.46,  68798.13,  69060.64,  69323.98,  69588.15,  69853.17
    Data.d 90,  70119.03,  70385.73,  70653.28,  70921.67,  71190.91,  71461.01,  71731.96,  72003.76,  72276.42,  72549.95
    Data.d 91,  72824.33,  73099.58,  73375.70,  73652.68,  73930.54,  74209.27,  74488.87,  74769.35,  75050.71,  75332.95
    Data.d 92,  75616.07,  75900.08,  76184.98,  76470.77,  76757.44,  77045.02,  77333.49,  77622.86,  77913.13,  78204.30
    Data.d 93,  78496.38,  78789.36,  79083.26,  79378.06,  79673.78,  79970.42,  80267.97,  80566.45,  80865.85,  81166.17
    Data.d 94,  81467.42,  81769.60,  82072.71,  82376.75,  82681.73,  82987.65,  83294.51,  83602.31,  83911.06,  84220.75
    Data.d 95,  84531.40,  84842.99,  85155.54,  85469.05,  85783.51,  86098.94,  86415.33,  86732.68,  87051.00,  87370.29
    Data.d 96,  87690.56,  88011.80,  88334.01,  88657.20,  88981.38,  89306.54,  89632.68,  89959.82,  90287.94,  90617.06
    Data.d 97,  90947.17,  91278.28,  91610.39,  91943.50,  92277.62,  92612.74,  92948.87,  93286.02,  93624.18,  93963.35
    Data.d 98,  94303.54,  94644.76,  94986.99,  95330.26,  95674.55,  96019.87,  96366.23,  96713.62,  97062.05,  97411.51
    Data.d 99,  97762.02,  98113.58,  98466.18,  98819.83,  99174.54,  99530.30,  99887.11, 100244.99, 100603.93, 100963.93
    Data.d 100, 101324.99
  EndDataSection

CompilerEndIf

CompilerIf #False  ; don't bother the compiler with a lot of comments
  
;- ---------------------------------------------------------------------------  
;- original VAX Test Results  
;  ---------------------------------------------------------------------------

; RESULTS OF ORIGINAL SPEED COMPARE ON A VAX WORKSTATION
;{
    ; Notes prepared by D. Baker, 24 Dec 86.
    ;
    ; ###############################################################################
    ; General information:
    ; --------------------
    ;     The following tables give results of the tests performed on
    ; routines in [BAKER.THERMO]THERM.For. These routines calculate thermo-
    ; dynamic parameters that are of interest when analyzing sound-
    ; ings. the "Smithsonian Meterological Tables" were utilized To
    ; test the accuracy of each routine where possible...otherwise,
    ; a Skew T-Log p chart was used. In cases where more than one
    ; routine calculates a given parameter, an efficiency test is also
    ; included. For the efficiency tests, a specified number of calcula-
    ; tions was done by each routine using identical input. After 10
    ; trials, the average time needed by each routine was determined
    ; And is listed, thereby indicating which routine is most efficient.
    ; For further information involving any of the routines To follow,
    ; refer To documentation in [BAKER.THERMO]THERM.For.
    ;
    ; Computer used:
    ; VAX 11/780 @ NOAA/ERL/PROFS...Boulder, Colorado.
    ;
    ; Input/output units:
    ; Temperature............celsius
    ; Pressure...............millibars
    ; Mixing ratio...........gm vapor/kg dry air
    ; Relative humidity......percent
    ; Sat specific humidity..gm vapor/kg moist air
    ;
    ; Note: Smith = Smithsonian table value. Where these values do Not
    ;       appear, the routines have been verified using a Skew T-
    ;       Log p chart due To lack of an applicable table.  The number
    ;       in parentheses Next To "Smith" indicates the page number
    ;       (6th revised edition) of the table used For the test.
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS ESW,ES,ESAT,ESGG,ESRW,ESLO
    ; PURPOSE: CALCULATE SATURATION VAPOR PRESSURE OVER LIQUID WATER
    ;          GIVEN TEMPERATURE.
    ;
    ; TEMP  ESW     ES     ESAT    ESGG    ESRW    ESLO    SMITH.(340)
    ; ---- -----  -----   ------  ------  ------  ------   ------
    ; -50 .06356  .06357  .06356  .06356  .06362  .06337   .06356
    ; -30 .50878  .51036  .50878  .50880  .50843  .50877   .5088
    ; -10 2.8627  2.8677  2.8626  2.8627  2.8625  2.8635   2.8627
    ;   0 6.1080  6.1121  6.1076  6.1078  6.1084  6.1078   6.1078
    ;  10 12.272  12.272  12.272  12.272  12.274  12.271   12.272
    ;  20 23.372  23.370  23.372  23.373  23.375  23.371   23.373
    ;  30 42.430  42.457  42.429  42.430  42.431  42.429   42.430
    ;
    ; EFFICIENCY TEST: 5000 CALCULATIONS AT T=20C.
    ;
    ;            FUNC.  T(SEC)
    ;            ----   ------
    ;            ESW     1.12
    ;            ES      0.88
    ;            ESAT    4.50
    ;            ESGG    4.63
    ;            ESRW    1.08
    ;            ESLO    0.64
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS WMR,W
    ; PURPOSE: CALCULATE MIXING RATIO GIVEN PRESSURE And TEMPERATURE.
    ;
    ; PRES  TEMP     WMR      W       SMITH.(302)
    ; ----  ----   ------   ------    ------
    ; 1000   30    27.699   27.560    27.69
    ; 1000    0     3.840    3.822     3.839
    ;  850   10     9.147    9.112     9.146
    ;  700   10    11.135   11.099    11.13
    ;  500  -20     1.568    1.564     1.568
    ;  400  -30     0.794    0.792     0.794
    ;
    ; EFFICIENCY TEST: 2000 CALCULATIONS AT T=-10C, P=850MB.
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            WMR     0.82
    ;            W       1.86
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS TCON,TLCL,TLCL1
    ; PURPOSE: CALCULATE TEMPERATURE AT THE LCL GIVEN TEMPERATURE And
    ;          DEW POINT.
    ;
    ; TEMP  DWPT    TCON    TLCL    TLCL1    SMITH.(329)
    ; ----  ----   ------  ------  ------    ------
    ;  40    20    15.473  15.449  15.450    15.48
    ; -20   -45   -48.703 -48.768 -48.689   -48.79
    ;  10   -20   -25.237 -25.295 -29.401   -25.29
    ;   0   -25   -29.277 -29.331 -29.401   -29.31
    ;  30    10     5.708   5.682   5.679     5.72
    ;  40    35    33.710  33.727  33.636    33.74
    ;
    ; EFFICIENCY TEST: 5000 CALCULATIONS AT T=20C, TD= 10C.
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            TCON    0.65
    ;            TLCL    0.96
    ;            TLCL1   1.70
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION PCON
    ; PURPOSE: CALCULATE LCL PRESSURE GIVEN INITIAL TEMPERATURE, DEW
    ;          POINT, And LCL TEMPERATURE (TEML).
    ;
    ; PRES  TEMP  TEML    PCON
    ; ----  ----  ----   ------
    ; 1000   35    20    839.59
    ;  975   30    20    866.89
    ;  950   15   -10    691.24
    ;  900   10   -25    566.87
    ;  500  -20   -20    500.00
    ;  500  -20   -50    321.40
    ;
    ; ###############################################################################
    ;
    ; TEST OF SUBROUTINE PTLCL, And FUNCTION ALCL
    ; PURPOSE: GIVEN TEMPERATURE, DEW POINT, And PRESSURE... PLTLCL
    ;          ESTIMATES LCL TEMPERATURE And PRESSURE; ALCL CALC-
    ;          ULATES LCL PRESSURE ONLY.
    ;
    ; PRES  TEMP  DWPT   PTLCL:P  PTLCL:T   ALCL
    ; ----  ----  ----   -------  -------  ------
    ; 1000   35    20     811.46   16.63   806.71
    ;  900   25    20     837.04   18.83   840.12
    ; 1000   30    28     971.57   27.51   973.34
    ;  850    0   -30     544.92  -34.66   528.01
    ;  900   16    16     900.00   16.00   900.00
    ;  700  -10   -60     333.50  -65.69   300.97
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION WOBF
    ; PURPOSE: CALCULATE THE DIFFERENCE WBPTS-WBPTD (SEE NOTES IN
    ;          [SCHLATTER]THERMO.For For EXPLANATION) GIVEN THE TEMPER-
    ;          ATURE. IN THIS Case, EQUIVALENT POTENTIAL TEMPERATURE
    ;          WAS INPUT SO RESULTS COULD BE CHECKED USING THE
    ;          SMITHSONIAN TABLES.
    ;
    ;  EQPT   WOBF(=EQPT-WBPT)  SMITH.(319)
    ;  ----   ---------------   ------
    ; 205.24     165.2104       165.24
    ; 161.04     125.0629       125.04
    ; 113.04      83.1266        83.04
    ;  70.34      48.8294        48.34
    ;  54.84      37.4419        36.84
    ;  42.14      28.6543        28.14
    ;   6.74       8.8176         8.74
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS POWT,OW
    ; PURPOSE: CALCULATE THE WET-BULB POTENTIAL TEMPERATURE GIVEN THE
    ;          TEMPERATURE, DEW POINT, And PRESSURE.
    ;
    ; TEMP  DWPT  PRES   POWT    OW
    ; ----  ----  ----  -----   -----
    ;  35    25   1000  27.55   27.61
    ;  10   -15   1000   2.13    1.83
    ; -10   -60    850  -4.64   -4.68
    ;  15    10    900  16.29   16.42
    ;  37    30   1050  29.98   30.13
    ;  -5    -5    500  22.05   22.22
    ;
    ; EFFICIENCY TEST: 500 CALCULATIONS AT T=10C, TD=-10C, P=850MB.
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            POWT    0.53
    ;            OW     17.31
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS DPT,DEWPT
    ; PURPOSE: CALCULATE DEW POINT GIVEN SATURATION VAPOR PRESSURE.
    ;
    ; SAT.VP.    DPT    DEWPT    SMITH.(351)
    ; -------  ------  ------    ------
    ; 0.1891  -40.002  -40.025    -40
    ; 1.2540  -20.000  -20.032    -20
    ; 2.8627  -10.000  -10.022    -10
    ; 6.1078    0.000   -0.010      0
    ; 12.272   10.000   10.000     10
    ; 23.373   20.000   20.003     20
    ;
    ; EFFICIENCY TEST: 3000 CALCULATIONS AT SVP=.1891MB.
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            DPT     1.92
    ;            DEWPT   0.59
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION SATLFT
    ; PURPOSE: CALCULATE TEMPERATURE WHERE A MOIST ADIABAT CROSSES A GIVEN
    ;          PRESSURE GIVEN THE VALUE OF THE MOIST ADIABAT And THE
    ;          PRESSURE.
    ;
    ;   PRES  THETAW   SATLFT   SMITH.
    ;  -----  ------  -------   ------
    ;  204.3    34    -19.791    -20
    ;  200      20    -60.356    -62
    ; 1071.4    38     40.151     40
    ;  501      32      9.941     10
    ;  422.7     0    -51.876    -52
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION HUM
    ; PURPOSE: CALCULATE RELATIVE HUMIDITY GIVEN TEMPERATURE And
    ;          DEW POINT.
    ;
    ; TEMP  DWPT   HUM
    ; ----  ----  -----
    ;  35    30   75.46
    ;  25    10   38.77
    ;   0   -15   31.18
    ;  20   -10   12.22
    ;  30    28   89.09
    ;
    ;
    ; TEST OF FUNCTION TW
    ; PURPOSE: CALCULATE WET-BULB TEMPERATURE GIVEN TEMPERATURE, DEW
    ;          POINT, And PRESSURE.
    ;
    ; TEMP  DWPT  PRES   TW
    ; ----  ----  ----  -----
    ;  30    15   1000  19.99
    ;   0   -20    700  -6.05
    ;  10     0    850   5.11
    ; -15   -25    500 -17.39
    ;  25    20    900  21.57
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS OE,EPT
    ; PURPOSE: CALCULATE EQUIVALENT POTENTIAL TEMPERATURE GIVEN TEMP-
    ;          ERATURE, DEW POINT, And PRESSURE.
    ;
    ; TEMP  DWPT  PRES    OE     EPT
    ; ----  ----  ----   -----  -----
    ;  30    15   1000   62.24  62.49
    ;  0    -20    700   33.10  33.01
    ;  10     0    850   36.97  37.01
    ; -15   -25    500   45.04  45.02
    ;  25    20    900   85.02  84.60
    ;
    ; EFFICIENCY TEST: 1000 CALCULATIONS AT T=20C, TD=10C, P=1000MB.
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            OE      18.50
    ;            EPT      0.80
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION TE
    ; PURPOSE: CALCULATE EQUIVALENT TEMPERATURE GIVEN TEMPERATURE, DEW
    ;          POINT, And PRESSURE.
    ;
    ; TEMP  DWPT  PRES    TE
    ; ----  ----  ----   -----
    ;  30    15   1000   62.24
    ;   0   -20    700    3.31
    ;  10     0    850   22.88
    ; -15   -25    500  -12.18
    ;  25    20    900   74.38
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION TDA
    ; PURPOSE: CALCULATE THE TEMPERATURE ON A DRY ADIABAT GIVEN THE VALUE
    ;          OF THE DRY ADIABAT And THE PRESSURE.
    ;
    ;  THETA  PRES     TDA     SMITH.(308)
    ;  -----  ----    ------   ------
    ; 132.74   250     -0.12      0
    ;  35.44   500    -20.05    -20
    ; -14.66  1050    -11.03    -11
    ;  28.64   850     14.93    -15
    ;  18.24   700    -10.02    -10
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS TSA,TMLAPS
    ; PURPOSE: CALCULATE TEMPERATURE ON A MOIST ADIABAT GIVEN
    ;          EQUIVALENT POTENTIAL TEMPERATURE And PRESSURE.
    ;
    ;   EQPT    PRES     TSA      TMLAPS    SMITH.(319)
    ; ------   ------   ------    -------   ------
    ; 181.64   870.9    34.170    33.940     34
    ; 113.04   577.0    12.139    12.080     12
    ;  70.34   896.0    18.057    17.950     18
    ;  10.24   496.0   -41.766   -41.669    -42
    ;  54.84   309.5   -39.658   -39.600    -40
    ;
    ; EFFICIENCY TEST: 500 CALCULATIONS AT EQPT=113.04, P=577MB
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            TSA     7.16
    ;            TMLAPS  6.81
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION O
    ; PURPOSE: CALCULATE POTENTIAL TEMPERATURE GIVEN TEMPERATURE And
    ;          PRESSURE.
    ;
    ; TEMP  PRES      O    SMITH.(309)
    ; ----  ----    -----  ------
    ; -35   850    -23.66  -23.66
    ; -10   500     47.74   47.74
    ; -20   950    -16.26  -16.26
    ;  10  1000     10.04   10.00
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION OS
    ; PURPOSE: CALCULATE EQUIVALENT POTENTIAL TEMPERATURE For AIR SAT-
    ;          URATED AT GIVEN TEMPERATURE And PRESSURE.
    ;
    ; TEMP   PRES    OS      SMITH.(319)
    ; ----  -----  ------   -------
    ;   0   275.3  179.88    181.64
    ; -10   321.4  112.03    113.04
    ;  10   501.0  126.27    127.34
    ;  10   816.0   54.89     54.84
    ; -50   282.7   47.63     48.14
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION TMR
    ; PURPOSE: CALCULATE THE TEMPERATURE ALONG A GIVEN MIXING RATIO
    ;          LINE AT A GIVEN PRESSURE.
    ;
    ;   W   PRES   TMR    SMITH.(302)
    ; ----- ----  -----   ------
    ; 9.146  850  10.07    10
    ; 1.120  700 -19.96   -20
    ; 7.710  500   0.03     0
    ; 1.960  400 -19.97   -20
    ; 14.95 1000  20.10    20
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION THM
    ; PURPOSE: CALCULATE WET-BULB POTENTIAL TEMPERATURE OF A PARCEL
    ;          SATURATED AT A GIVEN TEMPERATURE And PRESSURE.
    ;
    ; TEMP    PRES     THM     SMITH.(319)
    ; ----   ------   ------   ------
    ;  12    369.6    46.277    40
    ; -32    188.2    41.376    32
    ;  38    1069.8   35.751    36
    ;  10     908.    14.205    14
    ; -14     648.     7.841     8
    ; -50    301.7    13.961    14
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION DWPT
    ; PURPOSE: CALCULATE DEW POINT GIVEN TEMPERATURE And RELATIVE HUM-
    ;          IDITY.
    ;
    ; TEMP  REL.HUM.   TD     TD*
    ; ----  -------- ------  -----
    ;  35    75.46   30.14    30
    ;  25    38.77    9.93    10
    ;   0    31.18  -15.19   -15
    ;  20    12.22  -10.16   -10
    ;  30    89.09   28.01    28
    ;
    ;          * INPUT RELATIVE HUMIDITY FROM OUTPUT OF FUNCTION HUM.
    ;            EXPECT DEW POINT OUTPUT To BE APPROX. DEW POINT INPUT
    ;            USED IN "HUM". SEE TEST OF FUNCTION HUM For COMPARISON.
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION SSH
    ; PURPOSE: CALCULATE SATURATION SPECIFIC HUMIDITY GIVEN THE
    ;          PRESSURE And TEMPERATURE.
    ;
    ; PRES  TEMP   SSH          !CHECKED ON HAND CALCULATOR.
    ; ----  ----  -----
    ; 1000   10    7.70
    ; 1000    0    3.82
    ;  850  -10    2.11
    ;  700    0    5.46
    ;  500  -20    1.57
    ;  300  -30    1.06
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION TV
    ; PURPOSE: CALCULATE VIRTUAL TEMPERATURE GIVEN TEMPERATURE, DEW POINT,
    ;          And PRESSURE.
    ;
    ; TEMP  DWPT  PRES    TV        !CHECKED ON HAND CALCULATOR.
    ; ----  ----  ----   -----
    ;  30    25   1000   33.69
    ;  20     0   1000   20.68
    ;  10   -10    850   10.36
    ;   0   -10    700    0.42
    ; -20   -30    500  -19.90
    ; -40   -60    300  -39.99
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTIONS ESICE,ESILO
    ; PURPOSE: CALCULATE SATURATION VAPOR PRESSURE OVER ICE GIVEN TEMP-
    ;          ERATURE.
    ;
    ; TEMP   ESICE    ESILO    SMITH.(360)
    ; ----  -------  -------   ------
    ; -50   .03935   .03963   .03935
    ; -40   .1283    .1283    .1283
    ; -30   .3798    .3796    .3798
    ; -20   1.032    1.032    1.032
    ; -10   2.597    2.596    2.597
    ;
    ; EFFICIENCY TEST: 2000 CALCULATIONS AT T=-10C.
    ;
    ;            FUNC.  T(SEC)
    ;            -----  ------
    ;            ESICE   1.10
    ;            ESILO   0.39
    ;
    ; ###############################################################################
    ;
    ; TEST OF FUNCTION HEATL
    ; PURPOSE: GIVEN TEMPERATURE, To CALCULATE.....
    ;          1) LATENT HEAT OF EVAPORATION/CONDENSATION (KEY=1)
    ;          2) LATENT HEAT OF FREEZING/MELTING         (KEY=2)
    ;          3) LATENT HEAT OF SUBLIMATION/DEPOSITION   (KEY=3)
    ;
    ;          (RESULTS VERIFIED USING P.343, SMITH.)
    ;
    ; TEMP    KEY=1     SMITH.    KEY=2      SMITH.     KEY=3      SMITH.
    ; ----  --------    -------  --------    ------   ---------    ------
    ; -100                                            674.2192     674.4
    ;  -80                                            676.1257     676.3
    ;  -60                                            677.3396     677.5
    ;  -50  628.1667    629.3     48.7133     48.6
    ;  -40                        56.1209     56.3    677.8610     678.0
    ;  -30  615.5021    615.0     62.9107     63.0
    ;  -20                        69.0828     69.0    677.6898     677.9
    ;  -10  603.2438    603.0     74.6372     74.5    677.3444     677.5
    ;    0  597.2670    597.3     79.5740     79.7    676.8259     677.0
    ;   10  591.3918    591.7
    ;   20  585.6181    586.0
    ;   40  574.3755    574.7
    ;   50  568.9066    569.0
    ;
    ; NOTE: HEATL IS DESIGNED To Return THE LATENT HEATS IN UNITS OF
    ;       JOULES/KG.  To MAKE RESULTS COMPATIBLE With VALUES IN THE
    ;       SMITHSONIAN TABLES (IT-CAL/GRAM), ANSWERS WERE MULTIPLIED
    ;       BY THE CORRECTION FACTOR 2.3884E-04 To OBTAIN THOSE SHOWN
    ;       ABOVE.
    ;
    ; ###############################################################################
    ;
;} END ORIGINAL SPEED COMPARE ON A VAX WORKSTATIOM
  
;- ---------------------------------------------------------------------------  
;- original FORTRAN Code
;- ---------------------------------------------------------------------------

; Original FORTRAN CODE OF "Algorithms, Comparisons and Source References by Schlatter and Baker"
; 
;{ FORTRAN START
    ; USER_DEV:[GULIB.THERMOSRC]ALCL_TG.For;1
    ;
    ;-         FUNCTION ALCL(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE PRESSURE ALCL (MB) OF THE LIFTING CONDEN-
    ; C   SATION LEVEL (LCL) For A PARCEL INITIALLY AT TEMPERATURE T (CELSIUS)
    ; C   DEW POINT TD (CELSIUS) And PRESSURE P (MILLIBARS). ALCL IS COMPUTED
    ; C   BY AN ITERATIVE Procedure DESCRIBED BY EQS. 8-12 IN STIPANUK (1973),
    ; C   PP.13-14.
    ; C   DETERMINE THE MIXING RATIO LINE THROUGH TD And P.
    ;
    ;         AW = W(TD,P)
    ;
    ; C   DETERMINE THE DRY ADIABAT THROUGH T And P.
    ;
    ;         AO = O(T,P)
    ;
    ; C   ITERATE To LOCATE PRESSURE PI AT THE INTERSECTION OF THE TWO
    ; C   CURVES. PI HAS BEEN SET To P For THE INITIAL GUESS.
    ;
    ;  3      Continue
    ;            PI = P
    ;            DO 4 I= 1,10
    ;               X= .02*(TMR(AW,PI)-TDA(AO,PI))
    ;               If (Abs(X).LT.0.01) GO To 5
    ;  4            PI= PI*(2.**(X))
    ;  5         ALCL= PI
    ;         Return
    ;
    ;         ENTRY ALCLM(T,TD,P)
    ; C   For ENTRY ALCLM ONLY, T IS THE MEAN POTENTIAL TEMPERATURE (CELSIUS)
    ; C   And TD IS THE MEAN MIXING RATIO (G/KG) OF THE LAYER CONTAINING THE
    ; C   PARCEL.
    ;
    ;         AW = TD
    ;         AO = T
    ;         GO To 3
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]CT_TG.For;1
    ;
    ;-         FUNCTION CT(WBAR,PC,PS)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE CONVECTIVE TEMPERATURE CT (CELSIUS)
    ; C   GIVEN THE MEAN MIXING RATIO WBAR (G/KG) IN THE SURFACE LAYER,
    ; C   THE PRESSURE PC (MB) AT THE CONVECTIVE CONDENSATION LEVEL (CCL)
    ; C   And THE SURFACE PRESSURE PS (MB).
    ; C   COMPUTE THE TEMPERATURE (CELSIUS) AT THE CCL.
    ;
    ;         TC= TMR(WBAR,PC)
    ;
    ; C   COMPUTE THE POTENTIAL TEMPERATURE (CELSIUS), I.E., THE DRY
    ; C   ADIABAT AO THROUGH THE CCL.
    ;
    ;         AO= O(TC,PC)
    ;
    ; C   COMPUTE THE SURFACE TEMPERATURE ON THE SAME DRY ADIABAT AO.
    ;
    ;         CT= TDA(AO,PS)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]DEWPT_TG.For;1
    ;
    ;         FUNCTION DEWPT(EW)
    ;
    ; C   THIS FUNCTION YIELDS THE DEW POINT DEWPT (CELSIUS), GIVEN THE
    ; C   WATER VAPOR PRESSURE EW (MILLIBARS).
    ; C   THE EMPIRICAL FORMULA APPEARS IN BOLTON, DAVID, 1980:
    ; C   "THE COMPUTATION OF EQUIVALENT POTENTIAL TEMPERATURE,"
    ; C   MONTHLY WEATHER REVIEW, VOL. 108, NO. 7 (JULY), P. 1047, EQ.(11).
    ; C   THE QUOTED ACCURACY IS 0.03C Or LESS For -35 < DEWPT < 35C.
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;         ENL = ALOG(EW)
    ;         DEWPT = (243.5*ENL-440.8)/(19.48-ENL)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]DPT_TG.For;1
    ;
    ;-         FUNCTION DPT(EW)
    ;
    ; C   THIS FUNCTION RETURNS THE DEW POINT DPT (CELSIUS), GIVEN THE
    ; C   WATER VAPOR PRESSURE EW (MILLIBARS).
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;         Data ES0/6.1078/
    ;
    ; C   ES0 = SATURATION VAPOR PRESSURE (MB) OVER WATER AT 0C
    ; C   Return A FLAG VALUE If THE VAPOR PRESSURE IS OUT OF RANGE.
    ;
    ;         If (EW.GT..06.And.EW.LT.1013.) GO To 5
    ;         DPT = 9999.
    ;         Return
    ;     5   Continue
    ;
    ; C   APPROXIMATE DEW POINT BY MEANS OF TETEN'S FORMULA.
    ; C   THE FORMULA APPEARS As EQ.(8) IN BOLTON, DAVID, 1980:
    ; C   "THE COMPUTATION OF EQUIVALENT POTENTIAL TEMPERATURE,"
    ; C   MONTHLY WEATHER REVIEW, VOL 108, NO. 7 (JULY), P.1047.
    ; C   THE FORMULA IS EW(T) = ES0*10**(7.5*T/(T+237.3))
    ; C            Or    EW(T) = ES0*Exp(17.269388*T/(T+237.3))
    ; C   THE INVERSE FORMULA IS USED BELOW.
    ;
    ;         X = ALOG(EW/ES0)
    ;         DNM = 17.269388-X
    ;         T = 237.3*X/DNM
    ;         FAC = 1./(EW*DNM)
    ;
    ; C   LOOP For ITERATIVE IMPROVEMENT OF THE ESTIMATE OF DEW POINT
    ;
    ;    10   Continue
    ;
    ; C   GET THE PRECISE VAPOR PRESSURE CORRESPONDING To T.
    ;
    ;         EDP = ESW(T)
    ;
    ; C   ESTIMATE THE CHANGE IN TEMPERATURE CORRESPONDING To (EW-EDP)
    ; C   ASSUME THAT THE DERIVATIVE OF TEMPERATURE With RESPECT To
    ; C   VAPOR PRESSURE (DTDEW) IS GIVEN BY THE DERIVATIVE OF THE
    ; C   INVERSE TETEN FORMULA.
    ;
    ;         DTDEW = (T+237.3)*FAC
    ;         DT = DTDEW*(EW-EDP)
    ;         T = T+DT
    ;         If (Abs(DT).GT.1.E-04) GO To 10
    ;         DPT = T
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]DWPT_TG.For;1
    ;
    ;-         FUNCTION DWPT(T,RH)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE DEW Point (CELSIUS) GIVEN THE TEMPERATURE
    ; C   (CELSIUS) And RELATIVE HUMIDITY (%). THE FORMULA IS USED IN THE
    ; C   PROCESSING OF U.S. RAWINSONDE Data And IS REFERENCED IN PARRY, H.
    ; C   DEAN, 1969: "THE SEMIAUTOMATIC COMPUTATION OF RAWINSONDES,"
    ; C   TECHNICAL MEMORANDUM WBTM EDL 10, U.S. DEPARTMENT OF COMMERCE,
    ; C   ENVIRONMENTAL SCIENCE SERVICES ADMINISTRATION, WEATHER BUREAU,
    ; C   OFFICE OF SYSTEMS DEVELOPMENT, EQUIPMENT DEVELOPMENT LABORATORY,
    ; C   SILVER SPRING, MD (OCTOBER), PAGE 9 And PAGE II-4, LINE 460.
    ;
    ;         X = 1.-0.01*RH
    ;
    ; C   COMPUTE DEW POINT DEPRESSION.
    ;
    ;         DPD =(14.55+0.114*T)*X+((2.5+0.007*T)*X)**3+(15.9+0.117*T)*X**14
    ;         DWPT = T-DPD
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]EPT_TG.For;1
    ;
    ;-         FUNCTION EPT(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE EQUIVALENT POTENTIAL TEMPERATURE EPT
    ; C   (CELSIUS) For A PARCEL OF AIR INITIALLY AT TEMPERATURE T (CELSIUS),
    ; C   DEW POINT TD (CELSIUS) And PRESSURE P (MILLIBARS). THE FORMULA USED
    ; C   IS EQ.(43) IN BOLTON, DAVID, 1980: "THE COMPUTATION OF EQUIVALENT
    ; C   POTENTIAL TEMPERATURE," MONTHLY WEATHER REVIEW, VOL. 108, NO. 7
    ; C   (JULY), PP. 1046-1053. THE MAXIMUM ERROR IN EPT IN 0.3C.  IN MOST
    ; C   CASES THE ERROR IS LESS THAN 0.1C.
    ; C
    ; C   COMPUTE THE MIXING RATIO (GRAMS OF WATER VAPOR PER KILOGRAM OF
    ; C   DRY AIR).
    ;
    ;         W = WMR(P,TD)
    ;
    ; C   COMPUTE THE TEMPERATURE (CELSIUS) AT THE LIFTING CONDENSATION LEVEL.
    ;
    ;         TLCL = TCON(T,TD)
    ;         TK = T+273.15
    ;         TL = TLCL+273.15
    ;         PT = TK*(1000./P)**(0.2854*(1.-0.00028*W))
    ;         EPTK = PT*Exp((3.376/TL-0.00254)*W*(1.+0.00081*W))
    ;         EPT= EPTK-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESAT_TG.For;1
    ;
    ;         FUNCTION ESAT(T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER
    ; C   WATER (MB) GIVEN THE TEMPERATURE (CELSIUS).
    ; C   THE ALGORITHM IS DUE To NORDQUIST, W.S.,1973: "NUMERICAL APPROXIMA-
    ; C   TIONS OF SELECTED METEORLOLGICAL PARAMETERS For CLOUD PHYSICS PROB-
    ; C   LEMS," ECOM-5475, ATMOSPHERIC SCIENCES LABORATORY, U.S. ARMY
    ; C   ELECTRONICS COMMAND, WHITE SANDS MISSILE RANGE, NEW MEXICO 88002.
    ;
    ;         TK = T+273.15
    ;         P1 = 11.344-0.0303998*TK
    ;         P2 = 3.49149-1302.8844/TK
    ;         C1 = 23.832241-5.02808*ALOG10(TK)
    ;         ESAT = 10.**(C1-1.3816E-7*10.**P1+8.1328E-3*10.**P2-2949.076/TK)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESGG_TG.For;1
    ;
    ;-        FUNCTION ESGG(T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER LIQUID
    ; C   WATER ESGG (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE
    ; C   FORMULA USED, DUE To GOFF And GRATCH, APPEARS ON P. 350 OF THE
    ; C   SMITHSONIAN METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963,
    ; C   BY ROLAND List.
    ;
    ;         Data CTA,EWS,TS/273.15,1013.246,373.15/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ; C   EWS = SATURATION VAPOR PRESSURE (MB) OVER LIQUID WATER AT 100C
    ; C   TS = BOILING POINT OF WATER (K)
    ;
    ;         Data C1,      C2,      C3,      C4,       C5,       C6
    ;      1  / 7.90298, 5.02808, 1.3816E-7, 11.344, 8.1328E-3, 3.49149 /
    ;         TK = T+CTA
    ;
    ; C   GOFF-GRATCH FORMULA
    ;
    ;         RHS = -C1*(TS/TK-1.)+C2*ALOG10(TS/TK)-C3*(10.**(C4*(1.-TK/TS))
    ;      1        -1.)+C5*(10.**(-C6*(TS/TK-1.))-1.)+ALOG10(EWS)
    ;         ESW = 10.**RHS
    ;         If (ESW.LT.0.) ESW = 0.
    ;         ESGG = ESW
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESICE_TG.For;2
    ;
    ;-       FUNCTION ESICE(T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE With RESPECT To
    ; C   ICE ESICE (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS).
    ; C   THE FORMULA USED IS BASED UPON THE INTEGRATION OF THE CLAUSIUS-
    ; C   CLAPEYRON EQUATION BY GOFF And GRATCH.  THE FORMULA APPEARS ON P.350
    ; C   OF THE SMITHSONIAN METEOROLOGICAL TABLES, SIXTH REVISED EDITION,
    ; C   1963.
    ;
    ;         Data CTA,EIS/273.15,6.1071/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ; C   EIS = SATURATION VAPOR PRESSURE (MB) OVER A WATER-ICE MIXTURE AT 0C
    ;
    ;         Data C1,C2,C3/9.09718,3.56654,0.876793/
    ;
    ; C   C1,C2,C3 = EMPIRICAL COEFFICIENTS IN THE GOFF-GRATCH FORMULA
    ;
    ;         If (T.LE.0.) GO To 5
    ;         ESICE = 99999.
    ;         WRITE(6,3)ESICE
    ;         UNLOCK (6)
    ;     3   FORMAT(' SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED',
    ;      1         /' FOR TEMPERATURE > 0C. ESICE =',F7.0)
    ;         Return
    ;     5   Continue
    ;
    ; C   FREEZING POINT OF WATER (K)
    ;
    ;         TF = CTA
    ;         TK = T+CTA
    ;
    ; C   GOFF-GRATCH FORMULA
    ;
    ;         RHS = -C1*(TF/TK-1.)-C2*ALOG10(TF/TK)+C3*(1.-TK/TF)+ALOG10(EIS)
    ;         ESI = 10.**RHS
    ;         If (ESI.LT.0.) ESI = 0.
    ;         ESICE = ESI
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESILO_TG.For;2
    ;
    ;-        FUNCTION ESILO(T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER ICE
    ; C   ESILO (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE FORMULA
    ; C   IS DUE To LOWE, PAUL R., 1977: AN APPROXIMATING POLYNOMIAL For
    ; C   THE COMPUTATION OF SATURATION VAPOR PRESSURE, JOURNAL OF APPLIED
    ; C   METEOROLOGY, VOL. 16, NO. 1 (JANUARY), PP. 100-103.
    ; C   THE POLYNOMIAL COEFFICIENTS ARE A0 THROUGH A6.
    ;
    ;         Data A0,A1,A2,A3,A4,A5,A6
    ;      1  /6.109177956,     5.034698970E-01, 1.886013408E-02,
    ;      2   4.176223716E-04, 5.824720280E-06, 4.838803174E-08,
    ;      3   1.838826904E-10/
    ;         If (T.LE.0.) GO To 5
    ;         ESILO = 9999.
    ;         WRITE(6,3)ESILO
    ;         UNLOCK (6)
    ;     3   FORMAT(' SATURATION VAPOR PRESSURE OVER ICE IS UNDEFINED FOR',
    ;      1  /' TEMPERATURE > 0C. ESILO =',F6.0)
    ;         Return
    ;     5   Continue
    ;         ESILO = A0+T*(A1+T*(A2+T*(A3+T*(A4+T*(A5+A6*T)))))
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESLO_TG.For;1
    ;
    ;-        FUNCTION ESLO(T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER LIQUID
    ; C   WATER ESLO (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE
    ; C   FORMULA IS DUE To LOWE, PAUL R.,1977: AN APPROXIMATING POLYNOMIAL
    ; C   For THE COMPUTATION OF SATURATION VAPOR PRESSURE, JOURNAL OF APPLIED
    ; C   METEOROLOGY, VOL 16, NO. 1 (JANUARY), PP. 100-103.
    ; C   THE POLYNOMIAL COEFFICIENTS ARE A0 THROUGH A6.
    ;
    ;         Data A0,A1,A2,A3,A4,A5,A6
    ;      1  /6.107799961,     4.436518521E-01, 1.428945805E-02,
    ;      2   2.650648471E-04, 3.031240396E-06, 2.034080948E-08,
    ;      3   6.136820929E-11/
    ;         ES = A0+T*(A1+T*(A2+T*(A3+T*(A4+T*(A5+A6*T)))))
    ;         If (ES.LT.0.) ES = 0.
    ;         ESLO = ES
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESRW_TG.For;1
    ;
    ;-        FUNCTION ESRW(T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER LIQUID
    ; C   WATER ESRW (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE
    ; C   FORMULA USED IS DUE To RICHARDS, J.M., 1971: SIMPLE EXPRESSION
    ; C   For THE SATURATION VAPOUR PRESSURE OF WATER IN THE RANGE -50 To
    ; C   140C, BRITISH JOURNAL OF APPLIED PHYSICS, VOL. 4, PP.L15-L18.
    ; C   THE FORMULA WAS QUOTED MORE RECENTLY BY WIGLEY, T.M.L.,1974:
    ; C   COMMENTS ON 'A SIMPLE BUT ACCURATE FORMULA FOR THE SATURATION
    ; C   VAPOR PRESSURE OVER LIQUID WATER,' JOURNAL OF APPLIED METEOROLOGY,
    ; C   VOL. 13, NO. 5 (AUGUST) P.606.
    ;
    ;         Data CTA,TS,EWS/273.15,373.15,1013.25/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ; C   TS = TEMPERATURE OF THE BOILING POINT OF WATER (K)
    ; C   EWS = SATURATION VAPOR PRESSURE OVER LIQUID WATER AT 100C
    ;
    ;         Data C1,     C2,     C3,     C4
    ;      1  / 13.3185,-1.9760,-0.6445,-0.1299 /
    ;         TK = T+CTA
    ;         X = 1.-TS/TK
    ;         PX = X*(C1+X*(C2+X*(C3+C4*X)))
    ;         VP = EWS*Exp(PX)
    ;         If (VP.LT.0) VP = 0.
    ;         ESRW = VP
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ESW_TG.For;1
    ;
    ;-        FUNCTION ESW(T)
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE ESW (MILLIBARS)
    ; C   OVER LIQUID WATER GIVEN THE TEMPERATURE T (CELSIUS). THE POLYNOMIAL
    ; C   APPROXIMATION BELOW IS DUE To HERMAN WOBUS, A MATHEMATICIAN WHO
    ; C   WORKED AT THE NAVY WEATHER RESEARCH FACILITY, NORFOLK, VIRGINIA,
    ; C   BUT WHO IS NOW RETIRED. THE COEFFICIENTS OF THE POLYNOMIAL WERE
    ; C   CHOSEN To FIT THE VALUES IN TABLE 94 ON PP. 351-353 OF THE SMITH-
    ; C   SONIAN METEOROLOGICAL TABLES BY ROLAND List (6TH EDITION). THE
    ; C   APPROXIMATION IS VALID For -50 < T < 100C.
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C
    ; C   ES0 = SATURATION VAPOR RESSURE OVER LIQUID WATER AT 0C
    ;
    ;         Data ES0/6.1078/
    ;         POL = 0.99999683       + T*(-0.90826951E-02 +
    ;      1     T*(0.78736169E-04   + T*(-0.61117958E-06 +
    ;      2     T*(0.43884187E-08   + T*(-0.29883885E-10 +
    ;      3     T*(0.21874425E-12   + T*(-0.17892321E-14 +
    ;      4     T*(0.11112018E-16   + T*(-0.30994571E-19)))))))))
    ;         ESW = ES0/POL**8
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]ES_TG.For;1
    ;
    ;-       FUNCTION ES(T)
    ;
    ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE ES (MB) OVER
    ; C   LIQUID WATER GIVEN THE TEMPERATURE T (CELSIUS). THE FORMULA APPEARS
    ; C   IN BOLTON, DAVID, 1980: "THE COMPUTATION OF EQUIVALENT POTENTIAL
    ; C   TEMPERATURE," MONTHLY WEATHER REVIEW, VOL. 108, NO. 7 (JULY),
    ; C   P. 1047, EQ.(10). THE QUOTED ACCURACY IS 0.3% Or BETTER For
    ; C   -35 < T < 35C.
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   ES0 = SATURATION VAPOR PRESSURE OVER LIQUID WATER AT 0C
    ;
    ;         Data ES0/6.1121/
    ;         ES = ES0*Exp(17.67*T/(T+243.5))
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]HEATL_TG.For;1
    ;
    ;-        FUNCTION HEATL(KEY,T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE LATENT HEAT OF
    ; C               EVAPORATION/CONDENSATION         For KEY=1
    ; C               MELTING/FREEZING                 For KEY=2
    ; C               SUBLIMATION/DEPOSITION           For KEY=3
    ; C   For WATER. THE LATENT HEAT HEATL (JOULES PER KILOGRAM) IS A
    ; C   FUNCTION OF TEMPERATURE T (CELSIUS). THE FORMULAS ARE POLYNOMIAL
    ; C   APPROXIMATIONS To THE VALUES IN TABLE 92, P. 343 OF THE SMITHSONIAN
    ; C   METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963 BY ROLAND List.
    ; C   THE APPROXIMATIONS WERE DEVELOPED BY ERIC SMITH AT COLORADO STATE
    ; C   UNIVERSITY.
    ; C   POLYNOMIAL COEFFICIENTS
    ;
    ;         Data A0,A1,A2/ 3337118.5,-3642.8583, 2.1263947/
    ;         Data B0,B1,B2/-1161004.0, 9002.2648,-12.931292/
    ;         Data C0,C1,C2/ 2632536.8, 1726.9659,-3.6248111/
    ;         HLTNT = 0.
    ;         TK = T+273.15
    ;         If (KEY.EQ.1) HLTNT=A0+A1*TK+A2*TK*TK
    ;         If (KEY.EQ.2) HLTNT=B0+B1*TK+B2*TK*TK
    ;         If (KEY.EQ.3) HLTNT=C0+C1*TK+C2*TK*TK
    ;         HEATL = HLTNT
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]HUM_TG.For;1
    ;
    ;-        FUNCTION HUM(T,TD)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS RELATIVE HUMIDITY (%) GIVEN THE
    ; C   TEMPERATURE T And DEW POINT TD (CELSIUS).  As CALCULATED HERE,
    ; C   RELATIVE HUMIDITY IS THE RATIO OF THE ACTUAL VAPOR PRESSURE To
    ; C   THE SATURATION VAPOR PRESSURE.
    ;
    ;         HUM= 100.*(ESAT(TD)/ESAT(T))
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]OE_TG.For;1
    ;
    ;-         FUNCTION OE(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS EQUIVALENT POTENTIAL TEMPERATURE OE (CELSIUS)
    ; C   OF A PARCEL OF AIR GIVEN ITS TEMPERATURE T (CELSIUS), DEW POINT
    ; C   TD (CELSIUS) And PRESSURE P (MILLIBARS).
    ; C   FIND THE WET BULB TEMPERATURE OF THE PARCEL.
    ;
    ;         ATW = TW(T,TD,P)
    ;
    ; C   FIND THE EQUIVALENT POTENTIAL TEMPERATURE.
    ;
    ;         OE = OS(ATW,P)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]OS_TG.For;1
    ;
    ;-        FUNCTION OS(T,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE EQUIVALENT POTENTIAL TEMPERATURE OS
    ; C   (CELSIUS) For A PARCEL OF AIR SATURATED AT TEMPERATURE T (CELSIUS)
    ; C   And PRESSURE P (MILLIBARS).
    ;         Data B/2.6518986/
    ; C   B IS AN EMPIRICAL CONSTANT APPROXIMATELY EQUAL To THE LATENT HEAT
    ; C   OF VAPORIZATION For WATER DIVIDED BY THE SPECIFIC HEAT AT CONSTANT
    ; C   PRESSURE For DRY AIR.
    ;
    ;         TK = T+273.15
    ;         OSK= TK*((1000./P)**.286)*(Exp(B*W(T,P)/TK))
    ;         OS= OSK-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]OW_TG.For;1
    ;
    ;-        FUNCTION OW(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE WET-BULB POTENTIAL TEMPERATURE OW
    ; C   (CELSIUS) GIVEN THE TEMPERATURE T (CELSIUS), DEW POINT TD
    ; C   (CELSIUS), And PRESSURE P (MILLIBARS).  THE CALCULATION For OW IS
    ; C   VERY SIMILAR To THAT For WET BULB TEMPERATURE. SEE P.13 STIPANUK (1973).
    ; C   FIND THE WET BULB TEMPERATURE OF THE PARCEL
    ;
    ;         ATW = TW(T,TD,P)
    ;
    ; C   FIND THE EQUIVALENT POTENTIAL TEMPERATURE OF THE PARCEL.
    ;
    ;         AOS= OS(ATW,P)
    ;
    ; C   FIND THE WET-BULB POTENTIAL TEMPERATURE.
    ;
    ;         OW= TSA(AOS,1000.)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]O_TG.For;1
    ;
    ;-        FUNCTION O(T,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS POTENTIAL TEMPERATURE (CELSIUS) GIVEN
    ; C   TEMPERATURE T (CELSIUS) And PRESSURE P (MB) BY SOLVING THE POISSON
    ; C   EQUATION.
    ;
    ;         TK= T+273.15
    ;         OK= TK*((1000./P)**.286)
    ;         O= OK-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]PCCL_TG.For;1
    ;
    ;-        FUNCTION PCCL(PM,P,T,TD,WBAR,N)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE PRESSURE AT THE CONVECTIVE CONDENSATION
    ; C   LEVEL GIVEN THE APPROPRIATE SOUNDING Data.
    ; C   ON INPUT:
    ; C       P = PRESSURE (MILLIBARS). NOTE THAT P(I).GT.P(I+1).
    ; C       T = TEMPERATURE (CELSIUS)
    ; C       TD = DEW Point (CELSIUS)
    ; C       N = NUMBER OF LEVELS IN THE SOUNDING And THE DIMENSION OF
    ; C           P, T And TD
    ; C       PM = PRESSURE (MILLIBARS) AT UPPER BOUNDARY OF THE LAYER For
    ; C            COMPUTING THE MEAN MIXING RATIO. P(1) IS THE LOWER
    ; C            BOUNDARY.
    ; C   ON OUTPUT:
    ; C       PCCL = PRESSURE (MILLIBARS) AT THE CONVECTIVE CONDENSATION LEVEL
    ; C       WBAR = MEAN MIXING RATIO (G/KG) IN THE LAYER BOUNDED BY
    ; C              PRESSURES P(1) AT THE BOTTOM And PM AT THE TOP
    ; C   THE ALGORITHM IS DECRIBED ON P.17 OF STIPANUK, G.S.,1973:
    ; C   "ALGORITHMS FOR GENERATING A SKEW-T LOG P DIAGRAM AND COMPUTING
    ; C   SELECTED METEOROLOGICAL QUANTITIES," ATMOSPHERIC SCIENCES LABORA-
    ; C   TORY, U.S. ARMY ELECTRONICS COMMAND, WHITE SANDS MISSILE RANGE, NEW
    ; C   MEXICO 88002.
    ;
    ;         DIMENSION T(1),P(1),TD(1)
    ;         If (PM.NE.P(1)) GO To 5
    ;         WBAR= W(TD(1),P(1))
    ;         PC= PM
    ;         If (Abs(T(1)-TD(1)).LT.0.05) GO To 45
    ;         GO To 25
    ;     5   Continue
    ;         WBAR= 0.
    ;         K= 0
    ;    10   Continue
    ;         K = K+1
    ;         If (P(K).GT.PM) GO To 10
    ;         K= K-1
    ;         J= K-1
    ;         If(J.LT.1) GO To 20
    ;
    ; C   COMPUTE THE AVERAGE MIXING RATIO....ALOG = NATURAL LOG
    ;
    ;         DO 15 I= 1,J
    ;            L= I+1
    ;    15      WBAR= (W(TD(I),P(I))+W(TD(L),P(L)))*ALOG(P(I)/P(L))
    ;      *          +WBAR
    ;    20   Continue
    ;         L= K+1
    ;
    ; C   ESTIMATE THE DEW POINT AT PRESSURE PM.
    ;
    ;         TQ= TD(K)+(TD(L)-TD(K))*(ALOG(PM/P(K)))/(ALOG(P(L)/P(K)))
    ;         WBAR= WBAR+(W(TD(K),P(K))+W(TQ,PM))*ALOG(P(K)/PM)
    ;         WBAR= WBAR/(2.*ALOG(P(1)/PM))
    ;
    ; C   FIND LEVEL AT WHICH THE MIXING RATIO LINE WBAR CROSSES THE
    ; C   ENVIRONMENTAL TEMPERATURE PROFILE.
    ;
    ;    25   Continue
    ;         DO 30 J= 1,N
    ;            I= N-J+1
    ;            If (P(I).LT.300.) GO To 30
    ;
    ; C   TMR = TEMPERATURE (CELSIUS) AT PRESSURE P (MB) ALONG A MIXING
    ; C         RATIO LINE GIVEN BY WBAR (G/KG)
    ;
    ;            X= TMR(WBAR,P(I))-T(I)
    ;            If (X.LE.0.) GO To 35
    ;    30   Continue
    ;         PCCL= 0.0
    ;         Return
    ;
    ; C  SET UP BISECTION ROUTINE
    ;
    ;    35   L = I
    ;         I= I+1
    ;         DEL= P(L)-P(I)
    ;         PC= P(I)+.5*DEL
    ;         A= (T(I)-T(L))/ALOG(P(L)/P(I))
    ;         DO 40 J= 1,10
    ;            DEL= DEL/2.
    ;            X= TMR(WBAR,PC)-T(L)-A*(ALOG(P(L)/PC))
    ;
    ; C   THE SIGN FUNCTION REPLACES THE SIGN OF THE FIRST ARGUMENT
    ; C   With THAT OF THE SECOND.
    ;
    ;    40   PC= PC+Sign(DEL,X)
    ;    45   PCCL = PC
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]PCON_TG.For;1
    ;
    ;-         FUNCTION PCON(P,T,TC)
    ;
    ; C   THIS FUNCTION RETURNS THE PRESSURE PCON (MB) AT THE LIFTED CONDENSA-
    ; C   TION LEVEL, GIVEN THE INITIAL PRESSURE P (MB) And TEMPERATURE T
    ; C   (CELSIUS) OF THE PARCEL And THE TEMPERATURE TC (CELSIUS) AT THE
    ; C   LCL. THE ALGORITHM IS EXACT.  IT MAKES USE OF THE FORMULA For THE
    ; C   POTENTIAL TEMPERATURES CORRESPONDING To T AT P And TC AT PCON.
    ; C   THESE TWO POTENTIAL TEMPERATURES ARE EQUAL.
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C
    ;         Data AKAPI/3.5037/
    ;
    ; C   AKAPI = (SPECIFIC HEAT AT CONSTANT PRESSURE For DRY AIR) /
    ; C           (GAS CONSTANT For DRY AIR)
    ;
    ; C   CONVERT T And TC To KELVIN TEMPERATURES.
    ;
    ;         TK = T+273.15
    ;         TCK = TC+273.15
    ;         PCON = P*(TCK/TK)**AKAPI
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]POWT_TG.For;1
    ;
    ;-        FUNCTION POWT(T,TD,P)
    ;
    ; C   THIS FUNCTION YIELDS WET-BULB POTENTIAL TEMPERATURE POWT
    ; C   (CELSIUS), GIVEN THE FOLLOWING INPUT:
    ; C          T = TEMPERATURE (CELSIUS)
    ; C          P = PRESSURE (MILLIBARS)
    ; C          TD = DEW Point (CELSIUS)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ;         Data CTA,AKAP/273.15,0.28541/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ; C   AKAP = (GAS CONSTANT For DRY AIR) / (SPECIFIC HEAT AT
    ; C          CONSTANT PRESSURE For DRY AIR)
    ; C   COMPUTE THE POTENTIAL TEMPERATURE (CELSIUS)
    ;
    ;         PT = (T+CTA)*(1000./P)**AKAP-CTA
    ;
    ; C   COMPUTE THE LIFTING CONDENSATION LEVEL (LCL).
    ;
    ;         TC = TCON(T,TD)
    ;
    ; C   For THE ORIGIN OF THE FOLLOWING APPROXIMATION, SEE THE DOCUMEN-
    ; C   TATION For THE WOBUS FUNCTION.
    ;
    ;         POWT = PT-WOBF(PT)+WOBF(TC)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]PRECPW_TG.For;1
    ;
    ;-        FUNCTION PRECPW(TD,P,N)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION COMPUTES TOTAL PRECIPITABLE WATER PRECPW (CM) IN A
    ; C   VERTICAL COLUMN OF AIR BASED UPON SOUNDING Data AT N LEVELS:
    ; C          TD = DEW Point (CELSIUS)
    ; C          P = PRESSURE (MILLIBARS)
    ; C   CALCULATIONS ARE DONE IN CGS UNITS.
    ;
    ;         DIMENSION TD(N),P(N)
    ;
    ; C   G = ACCELERATION DUE To THE EARTH'S GRAVITY (CM/S**2)
    ;
    ;         Data G/980.616/
    ;
    ; C   INITIALIZE VALUE OF PRECIPITABLE WATER
    ;
    ;         PW = 0.
    ;         NL = N-1
    ;
    ; C   CALCULATE THE MIXING RATIO AT THE LOWEST LEVEL.
    ;
    ;         WBOT = WMR(P(1),TD(1))
    ;         DO 5 I=1,NL
    ;         WTOP = WMR(P(I+1),TD(I+1))
    ;
    ; C   CALCULATE THE LAYER-MEAN MIXING RATIO (G/KG).
    ;
    ;         W = 0.5*(WTOP+WBOT)
    ;
    ; C   MAKE THE MIXING RATIO DIMENSIONLESS.
    ;
    ;         WL = .001*W
    ;
    ; C   CALCULATE THE SPECIFIC HUMIDITY.
    ;
    ;         QL = WL/(WL+1.)
    ;
    ; C   THE FACTOR OF 1000. BELOW CONVERTS FROM MILLIBARS To DYNES/CM**2.
    ;
    ;         DP = 1000.*(P(I)-P(I+1))
    ;         PW = PW+(QL/G)*DP
    ;         WBOT = WTOP
    ;     5   Continue
    ;         PRECPW = PW
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]PTLCL_TG.For;1
    ;
    ;         SUBROUTINE PTLCL(P,T,TD,PC,TC)
    ;
    ; C   THIS SUBROUTINE ESTIMATES THE PRESSURE PC (MB) And THE TEMPERATURE
    ; C   TC (CELSIUS) AT THE LIFTED CONDENSATION LEVEL (LCL), GIVEN THE
    ; C   INITIAL PRESSURE P (MB), TEMPERATURE T (CELSIUS) And DEW POINT
    ; C   (CELSIUS) OF THE PARCEL.  THE APPROXIMATION IS THAT LINES OF
    ; C   CONSTANT POTENTIAL TEMPERATURE And CONSTANT MIXING RATIO ARE
    ; C   STRAIGHT ON THE SKEW T/LOG P CHART.
    ; C   TETEN'S FORMULA FOR SATURATION VAPOR PRESSURE AS A FUNCTION OF
    ; C   PRESSURE WAS USED IN THE DERIVATION OF THE FORMULA BELOW.  For
    ; C   ADDITIONAL DETAILS, SEE MATH NOTES BY T. SCHLATTER DATED 8 SEP 81.
    ; C   T. SCHLATTER, NOAA/ERL/PROFS PROGRAM OFFICE, BOULDER, COLORADO,
    ; C   WROTE THIS SUBROUTINE.
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   AKAP = (GAS CONSTANT For DRY AIR) / (SPECIFIC HEAT AT CONSTANT
    ; C          PRESSURE For DRY AIR)
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ;
    ;         Data AKAP,CTA/0.28541,273.15/
    ;         C1 = 4098.026/(TD+237.3)**2
    ;         C2 = 1./(AKAP*(T+CTA))
    ;         PC = P*Exp(C1*C2*(T-TD)/(C2-C1))
    ;         TC = T+C1*(T-TD)/(C2-C1)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]SATLFT_TG.For;1
    ;
    ;-        FUNCTION SATLFT(THW,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   INPUT:  THW = WET-BULB POTENTIAL TEMPERATURE (CELSIUS).
    ; C                 THW DEFINES A MOIST ADIABAT.
    ; C           P = PRESSURE (MILLIBARS)
    ; C   OUTPUT: SATLFT = TEMPERATURE (CELSIUS) WHERE THE MOIST ADIABAT
    ; C                 CROSSES P
    ;
    ;         Data CTA,AKAP/273.15,0.28541/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES
    ; C   AKAP = (GAS CONSTANT For DRY AIR) / (SPECIFIC HEAT AT CONSTANT
    ; C           PRESSURE For DRY AIR)
    ;
    ; C        THE ALGORITHM BELOW CAN BEST BE UNDERSTOOD BY REFERRING To A
    ; C   SKEW-T/LOG P CHART.  IT WAS DEVISED BY HERMAN WOBUS, A MATHEMATI-
    ; C   CIAN FORMERLY AT THE NAVY WEATHER RESEARCH FACILITY BUT NOW RETIRED.
    ; C   THE VALUE RETURNED BY SATLFT CAN BE CHECKED BY REFERRING To TABLE
    ; C   78, PP.319-322, SMITHSONIAN METEOROLOGICAL TABLES, BY ROLAND List
    ; C   (6TH REVISED EDITION).
    ; C
    ;
    ;         If (P.NE.1000.) GO To 5
    ;         SATLFT = THW
    ;         Return
    ;     5   Continue
    ;
    ; C   COMPUTE TONE, THE TEMPERATURE WHERE THE DRY ADIABAT With VALUE THW
    ; C   (CELSIUS) CROSSES P.
    ;
    ;         PWRP = (P/1000.)**AKAP
    ;         TONE = (THW+CTA)*PWRP-CTA
    ;
    ; C   CONSIDER THE MOIST ADIABAT EW1 THROUGH TONE AT P.  USING THE DEFINI-
    ; C   TION OF THE WOBUS FUNCTION (SEE DOCUMENTATION ON WOBF), IT CAN BE
    ; C   SHOWN THAT EONE = EW1-THW.
    ;
    ;         EONE = WOBF(TONE)-WOBF(THW)
    ;         RATE = 1.
    ;         GO To 15
    ;
    ; C   IN THE LOOP BELOW, THE ESTIMATE OF SATLFT IS ITERATIVELY IMPROVED.
    ;
    ;    10   Continue
    ;
    ; C   RATE IS THE RATIO OF A CHANGE IN T To THE CORRESPONDING CHANGE IN
    ; C   E.  ITS INITIAL VALUE WAS SET To 1 ABOVE.
    ;
    ;         RATE = (TTWO-TONE)/(ETWO-EONE)
    ;         TONE = TTWO
    ;         EONE = ETWO
    ;    15   Continue
    ;
    ; C   TTWO IS AN IMPROVED ESTIMATE OF SATLFT.
    ;
    ;         TTWO = TONE-EONE*RATE
    ;
    ; C   PT IS THE POTENTIAL TEMPERATURE (CELSIUS) CORRESPONDING To TTWO AT P
    ;
    ;         PT = (TTWO+CTA)/PWRP-CTA
    ;
    ; C   CONSIDER THE MOIST ADIABAT EW2 THROUGH TTWO AT P. USING THE DEFINI-
    ; C   TION OF THE WOBUS FUNCTION, IT CAN BE SHOWN THAT ETWO = EW2-THW.
    ;
    ;         ETWO = PT+WOBF(TTWO)-WOBF(PT)-THW
    ;
    ; C   DLT IS THE CORRECTION To BE SUBTRACTED FROM TTWO.
    ;
    ;         DLT = ETWO*RATE
    ;         If (Abs(DLT).GT.0.1) GO To 10
    ;         SATLFT = TTWO-DLT
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]SSH_TG.For;1
    ;
    ;-        FUNCTION SSH(P,T)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS SATURATION SPECIFIC HUMIDITY SSH (GRAMS OF
    ; C   WATER VAPOR PER KILOGRAM OF MOIST AIR) GIVEN THE PRESSURE P
    ; C   (MILLIBARS) And THE TEMPERATURE T (CELSIUS). THE EQUATION IS GIVEN
    ; C   IN STANDARD METEOROLOGICAL TEXTS. If T IS DEW Point (CELSIUS), THEN
    ; C   SSH RETURNS THE ACTUAL SPECIFIC HUMIDITY.
    ; C   COMPUTE THE DIMENSIONLESS MIXING RATIO.
    ;
    ;         W = .001*WMR(P,T)
    ;
    ; C   COMPUTE THE DIMENSIONLESS SATURATION SPECIFIC HUMIDITY.
    ;
    ;         Q = W/(1.+W)
    ;         SSH = 1000.*Q
    ;         Return
    ;         End
    ;
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TCON_TG.For;1
    ;
    ;-        FUNCTION TCON(T,D)
    ;
    ; C   THIS FUNCTION RETURNS THE TEMPERATURE TCON (CELSIUS) AT THE LIFTING
    ; C   CONDENSATION LEVEL, GIVEN THE TEMPERATURE T (CELSIUS) And THE
    ; C   DEW POINT D (CELSIUS).
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C
    ; C   COMPUTE THE DEW POINT DEPRESSION S.
    ;         S = T-D
    ; C   THE APPROXIMATION BELOW, A THIRD ORDER POLYNOMIAL IN S And T,
    ; C   IS DUE To HERMAN WOBUS. THE SOURCE OF Data For FITTING THE
    ; C   POLYNOMIAL IS UNKNOWN.
    ;
    ;         DLT = S*(1.2185+1.278E-03*T+
    ;      1        S*(-2.19E-03+1.173E-05*S-5.2E-06*T))
    ;         TCON = T-DLT
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TDA_TG.For;1
    ;
    ;-        FUNCTION TDA(O,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE TEMPERATURE TDA (CELSIUS) ON A DRY ADIABAT
    ; C   AT PRESSURE P (MILLIBARS). THE DRY ADIABAT IS GIVEN BY
    ; C   POTENTIAL TEMPERATURE O (CELSIUS). THE COMPUTATION IS BASED ON
    ; C   POISSON'S EQUATION.
    ;
    ;         OK= O+273.15
    ;         TDAK= OK*((P*.001)**.286)
    ;         TDA= TDAK-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TE_TG.For;1
    ;
    ;-        FUNCTION TE(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE EQUIVALENT TEMPERATURE TE (CELSIUS) OF A
    ; C   PARCEL OF AIR GIVEN ITS TEMPERATURE T (CELSIUS), DEW Point (CELSIUS)
    ; C   And PRESSURE P (MILLIBARS).
    ; C   CALCULATE EQUIVALENT POTENTIAL TEMPERATURE.
    ;
    ;         AOE = OE(T,TD,P)
    ;
    ; C   USE POISSONS'S EQUATION TO CALCULATE EQUIVALENT TEMPERATURE.
    ;
    ;         TE= TDA(AOE,P)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]THM_TG.For;1
    ;
    ;-        FUNCTION THM(T,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE WET-BULB POTENTIAL TEMPERATURE THM
    ; C   (CELSIUS) CORRESPONDING To A PARCEL OF AIR SATURATED AT
    ; C   TEMPERATURE T (CELSIUS) And PRESSURE P (MILLIBARS).
    ;
    ;         F(X) =   1.8199427E+01+X*( 2.1640800E-01+X*( 3.0716310E-04+X*
    ;      1         (-3.8953660E-06+X*( 1.9618200E-08+X*( 5.2935570E-11+X*
    ;      2         ( 7.3995950E-14+X*(-4.1983500E-17)))))))
    ;         THM = T
    ;         If (P.EQ.1000.) Return
    ;
    ; C   COMPUTE THE POTENTIAL TEMPERATURE (CELSIUS).
    ;
    ;         THD = (T+273.15)*(1000./P)**.286-273.15
    ;         THM = THD+6.071*(Exp(T/F(T))-Exp(THD/F(THD)))
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TLCL1_TG.For;1
    ;
    ;-        FUNCTION TLCL1(T,TD)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE TEMPERATURE TLCL1 (CELSIUS) OF THE LIFTING
    ; C   CONDENSATION LEVEL (LCL) GIVEN THE INITIAL TEMPERATURE T (CELSIUS)
    ; C   And DEW POINT TD (CELSIUS) OF A PARCEL OF AIR.
    ; C   ERIC SMITH AT COLORADO STATE UNIVERSITY HAS USED THE FORMULA
    ; C   BELOW, BUT ITS ORIGIN IS UNKNOWN.
    ;
    ;         Data CTA/273.15/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ;
    ;         TK = T+CTA
    ;
    ; C   COMPUTE THE PARCEL VAPOR PRESSURE (MB).
    ;         ES = ESLO(TD)
    ;         TLCL = 2840./(3.5*ALOG(TK)-ALOG(ES)-4.805)+55.
    ;         TLCL1 = TLCL-CTA
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TLCL_TG.For;1
    ;
    ;         FUNCTION TLCL(T,TD)
    ; C   THIS FUNCTION YIELDS THE TEMPERATURE TLCL (CELSIUS) OF THE LIFTING
    ; C   CONDENSATION LEVEL, GIVEN THE TEMPERATURE T (CELSIUS) And THE
    ; C   DEW POINT TD (CELSIUS).  THE FORMULA USED IS IN BOLTON, DAVID,
    ; C   1980: "THE COMPUTATION OF EQUIVALENT POTENTIAL TEMPERATURE,"
    ; C   MONTHLY WEATHER REVIEW, VOL. 108, NO. 7 (JULY), P. 1048, EQ.(15).
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   CONVERT FROM CELSIUS To KELVIN DEGREES.
    ;
    ;         TK = T+273.15
    ;         TDK = TD+273.15
    ;         A = 1./(TDK-56.)
    ;         B = ALOG(TK/TDK)/800.
    ;         TC = 1./(A+B)+56.
    ;         TLCL = TC-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TMLAPS_TG.For;1
    ;
    ;-        FUNCTION TMLAPS(THETAE,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE TEMPERATURE TMLAPS (CELSIUS) AT PRESSURE
    ; C   P (MILLIBARS) ALONG THE MOIST ADIABAT CORRESPONDING To AN EQUIVALENT
    ; C   POTENTIAL TEMPERATURE THETAE (CELSIUS).
    ; C   THE ALGORITHM WAS WRITTEN BY ERIC SMITH AT COLORADO STATE
    ; C   UNIVERSITY.
    ;
    ;         Data CRIT/0.1/
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES.
    ; C   CRIT = CONVERGENCE CRITERION (DEGREES KELVIN)
    ;
    ;         EQ0 = THETAE
    ;
    ; C   INITIAL GUESS For SOLUTION
    ;
    ;         TLEV = 25.
    ;
    ; C   COMPUTE THE SATURATION EQUIVALENT POTENTIAL TEMPERATURE CORRESPON-
    ; C   DING To TEMPERATURE TLEV And PRESSURE P.
    ;
    ;         EQ1 = EPT(TLEV,TLEV,P)
    ;         DIF = Abs(EQ1-EQ0)
    ;         If (DIF.LT.CRIT) GO To 3
    ;         If (EQ1.GT.EQ0) GO To 1
    ;
    ; C   DT IS THE INITIAL STEPPING INCREMENT.
    ;
    ;         DT = 10.
    ;         I = -1
    ;         GO To 2
    ;     1   DT = -10.
    ;         I = 1
    ;     2   TLEV = TLEV+DT
    ;         EQ1 = EPT(TLEV,TLEV,P)
    ;         DIF = Abs(EQ1-EQ0)
    ;         If (DIF.LT.CRIT) GO To 3
    ;         J = -1
    ;         If (EQ1.GT.EQ0) J=1
    ;         If (I.EQ.J) GO To 2
    ;
    ; C   THE SOLUTION HAS BEEN PASSED. REVERSE THE DIRECTION OF SEARCH
    ; C   And DECREASE THE STEPPING INCREMENT.
    ;
    ;         TLEV = TLEV-DT
    ;         DT = DT/10.
    ;         GO To 2
    ;     3   TMLAPS = TLEV
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TMR_TG.For;1
    ;
    ;-        FUNCTION TMR(W,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE TEMPERATURE (CELSIUS) ON A MIXING
    ; C   RATIO LINE W (G/KG) AT PRESSURE P (MB). THE FORMULA IS GIVEN IN
    ; C   TABLE 1 ON PAGE 7 OF STIPANUK (1973).
    ; C
    ; C   INITIALIZE CONSTANTS
    ;
    ;         Data C1/.0498646455/,C2/2.4082965/,C3/7.07475/
    ;         Data C4/38.9114/,C5/.0915/,C6/1.2035/
    ;
    ;         X= ALOG10(W*P/(622.+W))
    ;         TMRK= 10.**(C1*X+C2)-C3+C4*((10.**(C5*X)-C6)**2.)
    ;         TMR= TMRK-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TSA_TG.For;1
    ;
    ;-        FUNCTION TSA(OS,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE TEMPERATURE TSA (CELSIUS) ON A SATURATION
    ; C   ADIABAT AT PRESSURE P (MILLIBARS). OS IS THE EQUIVALENT POTENTIAL
    ; C   TEMPERATURE OF THE PARCEL (CELSIUS). SIGN(A,B) REPLACES THE
    ; C   ALGEBRAIC SIGN OF A With THAT OF B.
    ; C   B IS AN EMPIRICAL CONSTANT APPROXIMATELY EQUAL To 0.001 OF THE LATENT
    ; C   HEAT OF VAPORIZATION For WATER DIVIDED BY THE SPECIFIC HEAT AT CONSTANT
    ; C   PRESSURE For DRY AIR.
    ;
    ;         Data B/2.6518986/
    ;         A= OS+273.15
    ;
    ; C   TQ IS THE FIRST GUESS For TSA.
    ;
    ;         TQ= 253.15
    ;
    ; C   D IS AN INITIAL VALUE USED IN THE ITERATION BELOW.
    ;
    ;         D= 120.
    ;
    ; C   ITERATE To OBTAIN SUFFICIENT ACCURACY....SEE TABLE 1, P.8
    ; C   OF STIPANUK (1973) For EQUATION USED IN ITERATION.
    ;
    ;         DO 1 I= 1,12
    ;            TQK= TQ-273.15
    ;            D= D/2.
    ;            X= A*Exp(-B*W(TQK,P)/TQ)-TQ*((1000./P)**.286)
    ;            If (Abs(X).LT.1E-7) GO To 2
    ;            TQ= TQ+Sign(D,X)
    ;  1      Continue
    ;  2      TSA= TQ-273.15
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TV_TG.For;1
    ;
    ;-        FUNCTION TV(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   THIS FUNCTION RETURNS THE VIRTUAL TEMPERATURE TV (CELSIUS) OF
    ; C   A PARCEL OF AIR AT TEMPERATURE T (CELSIUS), DEW POINT TD
    ; C   (CELSIUS), And PRESSURE P (MILLIBARS). THE EQUATION APPEARS
    ; C   IN MOST STANDARD METEOROLOGICAL TEXTS.
    ;
    ;         Data CTA,EPS/273.15,0.62197/
    ;
    ; C   CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURES.
    ; C   EPS = RATIO OF THE MEAN MOLECULAR WEIGHT OF WATER (18.016 G/MOLE)
    ; C         To THAT OF DRY AIR (28.966 G/MOLE)
    ;
    ;         TK = T+CTA
    ;
    ; C   CALCULATE THE DIMENSIONLESS MIXING RATIO.
    ;
    ;         W = .001*WMR(P,TD)
    ;         TV = TK*(1.+W/EPS)/(1.+W)-CTA
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]TW_TG.For;1
    ;
    ;-        FUNCTION TW(T,TD,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE WET-BULB TEMPERATURE TW (CELSIUS)
    ; C   GIVEN THE TEMPERATURE T (CELSIUS), DEW POINT TD (CELSIUS)
    ; C   And PRESSURE P (MB).  SEE P.13 IN STIPANUK (1973), REFERENCED
    ; C   ABOVE, For A DESCRIPTION OF THE TECHNIQUE.
    ; C
    ; C
    ; C   DETERMINE THE MIXING RATIO LINE THRU TD And P.
    ;
    ;         AW = W(TD,P)
    ; C
    ; C   DETERMINE THE DRY ADIABAT THRU T And P.
    ;
    ;         AO = O(T,P)
    ;         PI = P
    ;
    ; C   ITERATE To LOCATE PRESSURE PI AT THE INTERSECTION OF THE TWO
    ; C   CURVES .  PI HAS BEEN SET To P For THE INITIAL GUESS.
    ;
    ;         DO 4 I= 1,10
    ;            X= .02*(TMR(AW,PI)-TDA(AO,PI))
    ;            If (Abs(X).LT.0.01) GO To 5
    ;  4         PI= PI*(2.**(X))
    ;
    ; C   FIND THE TEMPERATURE ON THE DRY ADIABAT AO AT PRESSURE PI.
    ;
    ;  5      TI= TDA(AO,PI)
    ;
    ; C   THE INTERSECTION HAS BEEN LOCATED...NOW, FIND A SATURATION
    ; C   ADIABAT THRU THIS POINT. FUNCTION OS RETURNS THE EQUIVALENT
    ; C   POTENTIAL TEMPERATURE (C) OF A PARCEL SATURATED AT TEMPERATURE
    ; C   TI And PRESSURE PI.
    ;
    ;         AOS= OS(TI,PI)
    ;
    ; C   FUNCTION TSA RETURNS THE WET-BULB TEMPERATURE (C) OF A PARCEL AT
    ; C   PRESSURE P WHOSE EQUIVALENT POTENTIAL TEMPERATURE IS AOS.
    ;
    ;         TW = TSA(AOS,P)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]WMR_TG.For;1
    ;
    ;-        FUNCTION WMR(P,T)
    ;
    ; C   THIS FUNCTION APPROXIMATES THE MIXING RATIO WMR (GRAMS OF WATER
    ; C   VAPOR PER KILOGRAM OF DRY AIR) GIVEN THE PRESSURE P (MB) And THE
    ; C   TEMPERATURE T (CELSIUS). THE FORMULA USED IS GIVEN ON P. 302 OF THE
    ; C   SMITHSONIAN METEOROLOGICAL TABLES BY ROLAND List (6TH EDITION).
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C   EPS = RATIO OF THE MEAN MOLECULAR WEIGHT OF WATER (18.016 G/MOLE)
    ; C         To THAT OF DRY AIR (28.966 G/MOLE)
    ;
    ;         Data EPS/0.62197/
    ;
    ; C   THE Next TWO LINES CONTAIN A FORMULA BY HERMAN WOBUS For THE
    ; C   CORRECTION FACTOR WFW For THE DEPARTURE OF THE MIXTURE OF AIR
    ; C   And WATER VAPOR FROM THE IDEAL GAS LAW. THE FORMULA FITS VALUES
    ; C   IN TABLE 89, P. 340 OF THE SMITHSONIAN METEOROLOGICAL TABLES,
    ; C   BUT ONLY For TEMPERATURES And PRESSURES NORMALLY ENCOUNTERED IN
    ; C   IN THE ATMOSPHERE.
    ;
    ;         X = 0.02*(T-12.5+7500./P)
    ;         WFW = 1.+4.5E-06*P+1.4E-03*X*X
    ;         FWESW = WFW*ESW(T)
    ;         R = EPS*FWESW/(P-FWESW)
    ;
    ; C   CONVERT R FROM A DIMENSIONLESS RATIO To GRAMS/KILOGRAM.
    ;
    ;         WMR = 1000.*R
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]WOBF_TG.For;1
    ;
    ;-        FUNCTION WOBF(T)
    ;
    ; C   THIS FUNCTION CALCULATES THE DIFFERENCE OF THE WET-BULB POTENTIAL
    ; C   TEMPERATURES For SATURATED And DRY AIR GIVEN THE TEMPERATURE.
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       Baker, Schlatter  17-MAY-1982     Original version.
    ;
    ; C        LET WBPTS = WET-BULB POTENTIAL TEMPERATURE For SATURATED
    ; C   AIR AT TEMPERATURE T (CELSIUS). LET WBPTD = WET-BULB POTENTIAL
    ; C   TEMPERATURE For COMPLETELY DRY AIR AT THE SAME TEMPERATURE T.
    ; C   THE WOBUS FUNCTION WOBF (IN DEGREES CELSIUS) IS DEFINED BY
    ; C                      WOBF(T) = WBPTS-WBPTD.
    ; C   ALTHOUGH WBPTS And WBPTD ARE FUNCTIONS OF BOTH PRESSURE And
    ; C   TEMPERATURE, THEIR DIFFERENCE IS A FUNCTION OF TEMPERATURE ONLY.
    ;
    ; C        To UNDERSTAND WHY, CONSIDER A PARCEL OF DRY AIR AT TEMPERA-
    ; C   TURE T And PRESSURE P. THE THERMODYNAMIC STATE OF THE PARCEL IS
    ; C   REPRESENTED BY A POINT ON A PSEUDOADIABATIC CHART. THE WET-BULB
    ; C   POTENTIAL TEMPERATURE CURVE (MOIST ADIABAT) PASSING THROUGH THIS
    ; C   POINT IS WBPTS. NOW T IS THE EQUIVALENT TEMPERATURE For ANOTHER
    ; C   PARCEL SATURATED AT SOME LOWER TEMPERATURE TW, BUT AT THE SAME
    ; C   PRESSURE P.  To FIND TW, ASCEND ALONG THE DRY ADIABAT THROUGH
    ; C   (T,P). AT A GREAT HEIGHT, THE DRY ADIABAT And SOME MOIST
    ; C   ADIABAT WILL NEARLY COINCIDE. DESCEND ALONG THIS MOIST ADIABAT
    ; C   BACK To P. THE PARCEL TEMPERATURE IS NOW TW. THE WET-BULB
    ; C   POTENTIAL TEMPERATURE CURVE (MOIST ADIABAT) THROUGH (TW,P) IS WBPTD.
    ; C   THE DIFFERENCE (WBPTS-WBPTD) IS PROPORTIONAL To THE HEAT IMPARTED
    ; C   To A PARCEL SATURATED AT TEMPERATURE TW If ALL ITS WATER VAPOR
    ; C   WERE CONDENSED. SINCE THE AMOUNT OF WATER VAPOR A PARCEL CAN
    ; C   HOLD DEPENDS UPON TEMPERATURE ALONE, (WBPTD-WBPTS) MUST DEPEND
    ; C   ON TEMPERATURE ALONE.
    ;
    ; C        THE WOBUS FUNCTION IS USEFUL For EVALUATING SEVERAL THERMO-
    ; C   DYNAMIC QUANTITIES.  BY DEFINITION:
    ; C                   WOBF(T) = WBPTS-WBPTD.               (1)
    ; C   If T IS AT 1000 MB, THEN T IS A POTENTIAL TEMPERATURE PT And
    ; C   WBPTS = PT. THUS
    ; C                   WOBF(PT) = PT-WBPTD.                 (2)
    ; C   If T IS AT THE CONDENSATION LEVEL, THEN T IS THE CONDENSATION
    ; C   TEMPERATURE TC And WBPTS IS THE WET-BULB POTENTIAL TEMPERATURE
    ; C   WBPT. THUS
    ; C                   WOBF(TC) = WBPT-WBPTD.               (3)
    ; C   If WBPTD IS ELIMINATED FROM (2) And (3), THERE RESULTS
    ; C                   WBPT = PT-WOBF(PT)+WOBF(TC).
    ; C   If WBPTD IS ELIMINATED FROM (1) And (2), THERE RESULTS
    ; C                   WBPTS = PT-WOBF(PT)+WOBF(T).
    ;
    ; C        If T IS AN EQUIVALENT POTENTIAL TEMPERATURE EPT (IMPLYING
    ; C   THAT THE AIR AT 1000 MB IS COMPLETELY DRY), THEN WBPTS = EPT
    ; C   And WBPTD = WBPT. THUS
    ; C                   WOBF(EPT) = EPT-WBPT.
    ; C   THIS FORM IS THE BASIS For A POLYNOMIAL APPROXIMATION To WOBF.
    ; C   IN TABLE 78 ON PP.319-322 OF THE SMITHSONIAN METEOROLOGICAL
    ; C   TABLES BY ROLAND List (6TH REVISED EDITION), ONE FINDS WET-BULB
    ; C   POTENTIAL TEMPERATURES And THE CORRESPONDING EQUIVALENT POTENTIAL
    ; C   TEMPERATURES LISTED TOGETHER. HERMAN WOBUS, A MATHEMATICIAN For-
    ; C   MERLY AT THE NAVY WEATHER RESEARCH FACILITY, NORFOLK, VIRGINIA,
    ; C   And NOW RETIRED, COMPUTED THE COEFFICIENTS For THE POLYNOMIAL
    ; C   APPROXIMATION FROM NUMBERS IN THIS TABLE.
    ; C
    ; C                                    NOTES BY T.W. SCHLATTER
    ; C                                    NOAA/ERL/PROFS PROGRAM OFFICE
    ; C                                    AUGUST 1981
    ;
    ;         X = T-20.
    ;         If (X.GT.0.) GO To 10
    ;         POL = 1.                 +X*(-8.8416605E-03
    ;      1       +X*( 1.4714143E-04  +X*(-9.6719890E-07
    ;      2       +X*(-3.2607217E-08  +X*(-3.8598073E-10)))))
    ;         WOBF = 15.130/POL**4
    ;         Return
    ;    10   Continue
    ;         POL = 1.                 +X*( 3.6182989E-03
    ;      1       +X*(-1.3603273E-05  +X*( 4.9618922E-07
    ;      2       +X*(-6.1059365E-09  +X*( 3.9401551E-11
    ;      3       +X*(-1.2588129E-13  +X*( 1.6688280E-16)))))))
    ;         WOBF = 29.930/POL**4+0.96*X-14.8
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]W_TG.For;1
    ;
    ;-        FUNCTION W(T,P)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C  THIS FUNCTION RETURNS THE MIXING RATIO (GRAMS OF WATER VAPOR PER
    ; C  KILOGRAM OF DRY AIR) GIVEN THE DEW Point (CELSIUS) And PRESSURE
    ; C  (MILLIBARS). If THE TEMPERTURE  IS INPUT INSTEAD OF THE
    ; C  DEW POINT, THEN SATURATION MIXING RATIO (SAME UNITS) IS RETURNED.
    ; C  THE FORMULA IS FOUND IN MOST METEOROLOGICAL TEXTS.
    ;
    ;         X= ESAT(T)
    ;         W= 622.*X/(P-X)
    ;         Return
    ;         End
    ;
    ; USER_DEV:[GULIB.THERMOSRC]Z_TG.For;1
    ;
    ;-        FUNCTION Z(PT,P,T,TD,N)
    ;
    ; C       INCLUDE 'LIB_DEV:[GUDOC]EDFVAXBOX.FOR/LIST'
    ; C       G.S. Stipanuk     1973            Original version.
    ; C       Reference Stipanuk paper entitled:
    ; C            "ALGORITHMS FOR GENERATING A SKEW-T, LOG P
    ; C            DIAGRAM And COMPUTING SELECTED METEOROLOGICAL
    ; C            QUANTITIES."
    ; C            ATMOSPHERIC SCIENCES LABORATORY
    ; C            U.S. ARMY ELECTRONICS COMMAND
    ; C            WHITE SANDS MISSILE RANGE, NEW MEXICO 88002
    ; C            33 PAGES
    ; C       Baker, Schlatter  17-MAY-1982
    ;
    ; C   THIS FUNCTION RETURNS THE THICKNESS OF A LAYER BOUNDED BY PRESSURE
    ; C   P(1) AT THE BOTTOM And PRESSURE PT AT THE TOP.
    ; C   ON INPUT:
    ; C       P = PRESSURE (MB).  NOTE THAT P(I).GT.P(I+1).
    ; C       T = TEMPERATURE (CELSIUS)
    ; C       TD = DEW Point (CELSIUS)
    ; C       N = NUMBER OF LEVELS IN THE SOUNDING And THE DIMENSION OF
    ; C           P, T And TD
    ; C   ON OUTPUT:
    ; C       Z = GEOMETRIC THICKNESS OF THE LAYER (M)
    ; C   THE ALGORITHM INVOLVES NUMERICAL INTEGRATION OF THE HYDROSTATIC
    ; C   EQUATION FROM P(1) To PT. IT IS DESCRIBED ON P.15 OF STIPANUK
    ; C   (1973).
    ;
    ;         DIMENSION T(1),P(1),TD(1),TK(100)
    ;
    ; C       C1 = .001*(1./EPS-1.) WHERE EPS = .62197 IS THE RATIO OF THE
    ; C                             MOLECULAR WEIGHT OF WATER To THAT OF
    ; C                             DRY AIR. THE FACTOR 1000. CONVERTS THE
    ; C                             MIXING RATIO W FROM G/KG To A DIMENSION-
    ; C                             LESS RATIO.
    ; C       C2 = R/(2.*G) WHERE R IS THE GAS CONSTANT For DRY AIR
    ; C                     (287 KG/JOULE/DEG K) And G IS THE ACCELERATION
    ; C                     DUE To THE EARTH'S GRAVITY (9.8 M/S**2). THE
    ; C                     FACTOR OF 2 IS USED IN AVERAGING TWO VIRTUAL
    ; C                     TEMPERATURES.
    ;
    ;         Data C1/.0006078/,C2/14.64285/
    ;         DO 5 I= 1,N
    ;            TK(I)= T(I)+273.15
    ;     5   Continue
    ;         Z= 0.0
    ;         If (PT.LT.P(N)) GO To 20
    ;         I= 0
    ;    10   I= I+1
    ;         J= I+1
    ;         If (PT.GE.P(J)) GO To 15
    ;         A1= TK(J)*(1.+C1*W(TD(J),P(J)))
    ;         A2= TK(I)*(1.+C1*W(TD(I),P(I)))
    ;         Z= Z+C2*(A1+A2)*(ALOG(P(I)/P(J)))
    ;         GO To 10
    ;    15   Continue
    ;         A1= TK(J)*(1.+C1*W(TD(J),P(J)))
    ;         A2= TK(I)*(1.+C1*W(TD(I),P(I)))
    ;         Z= Z+C2*(A1+A2)*(ALOG(P(I)/PT))
    ;         Return
    ;  20     Z= -1.0
    ;         Return
    ;         End
    ;
    ;} END FORTRAN CODE

CompilerEndIf
; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 1144
; Folding = 6-----------
; Optimizer
; Executable = K:\purebasic\_projects\wallx\wallx98.exe
; CPU = 5
; CurrentDirectory = C:\software\purebasic\_projects\
; EnableCompileCount = 105
; EnableBuildCount = 2
; EnableExeConstant
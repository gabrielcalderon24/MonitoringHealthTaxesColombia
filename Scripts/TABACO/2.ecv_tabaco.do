**************************************************************************
* Estimación del consumo anual de unidades de cigarrillos según la ECV ***
**************************************************************************

glo data_ecv = "$carpetaMadre\Data\ECV" // Ruta de datos ECV 

**********************************
**** PROPORCIONES DE CONSUMO ***** 
**********************************
 
**# Para entender bien cómo se realiza la estimación, es fundamental revisar por favor el dofile 1.Preprocesamiento_ENCSP, acá se explica a detalle como se calculan las proporciones 
* de consumo en la ENCSP 2019, para completar el consumo diario en la ECV. 
 
use "$carpetaMadre\Data\Created data\encsp_2019_proporciones_para_ecv", clear 

// Calculamos ambas proporciones y guardamos en globales para usarlas en la estimación 

su proporciones if frecuencia_semanal == 2, meanonly 
global mean_fuma_algunosdias = r(mean)

su proporciones if frecuencia_semanal == 3, meanonly 
global mean_fuma_unavez = r(mean)

/* RESULTADOS:  
La proporción entre quienes fuman todos los días de la semana y quienes fuman algunos días es de 0.61. Para los que fuman menos de una vez por semana es ligeramente menor (0.54).
*/  

//////////////////////////////////////////
///// Consumo Tabaco ECV- IC al 95% /////
/////////////////////////////////////////

 
/// Bootsrap e iteraciones por año ///
capture program drop myboot
program define myboot, rclass
    preserve
	
// Población representada en la encuesta 
sum FEX_C, meanonly
local pob2016 = r(sum) 

// Obtenemos la prevalencia   
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2016=r(mean) 
scalar prev2016_scalar = `prev2016' 

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 
keep if prevalencia_semanal==1  
gen dias_semana=.
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

// Calculamos media para los que fuman diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile 
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // fuman algunos días de la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana

// Collapse para el consumo mensual promedio 
gen consumo_mensual= consumo_diario_ajustado*dias_semana*4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final  
gen consumo_total_2016= consumo_mensual * 12 * `pob2016' * `prev2016'  

// Guardamos el dato en un archivo temporal 
sum consumo_total_2016 
return scalar total2016 = r(mean)
restore 
end 

use P1706 P1706S1 P1706S1A1 FEX_C using "$data_ecv\ENCV2016\original\Salud.dta", clear

rename P1706 prevalencia_semanal 

rename P1706S1 frecuencia_semanal
 
rename P1706S1A1 consumo_diario
  
bootstrap r(total2016), reps(1000) seed(123): myboot 
estat bootstrap, all 

// Guardar los resultados en una matriz// 
matrix results2016=J(1,5,.)
matrix results2016[1,1]=2016
matrix results2016[1,2]= e(b)[1,1]
matrix results2016[1,3]= e(ci_percentile)[1,1]
matrix results2016[1,4]= e(ci_percentile)[2,1] 
matrix results2016[1,5]=  prev2016_scalar
matrix list results2016


********************
**# 2017 ***********
******************** 

/// Bootsrap e iteraciones por año ///
capture program drop myboot
program define myboot, rclass
preserve

// Obtenemos la población total 

sum FEX_C, meanonly
 	
local pob2017= r(sum)
 
// Confirmamos que la codificación para frencuencia semanal es la misma  
 
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2017=r(mean) 
scalar prev2017_scalar = `prev2017'

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 

keep if prevalencia_semanal==1  
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  


// Calculamos media para los que fuman diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile  
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Fuman algunos días de la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana

// Collapse con el consumo mensual 
gen consumo_mensual= consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final 
gen consumo_total_2017 = consumo_mensual * 12 * `pob2017' * `prev2017'
sum consumo_total_2017
 
return scalar total2017 = r(mean)
restore
end 
use P1706 P1706S1 P1706S1A1 FEX_C using "$data_ecv\ENCV2017\original\Salud.dta", clear

rename P1706 prevalencia_semanal 

rename P1706S1 frecuencia_semanal 

rename P1706S1A1 consumo_diario

bootstrap r(total2017), reps(1000) seed(123): myboot 
estat bootstrap, all

// Guardar los resultados del bootstrap en una matriz//
matrix results2017=J(1,5,.)
matrix results2017[1,1]=2017
matrix results2017[1,2]= e(b)[1,1]
matrix results2017[1,3]= e(ci_percentile)[1,1]
matrix results2017[1,4]= e(ci_percentile)[2,1] 
matrix results2017[1,5]= prev2017_scalar 
matrix list results2017


*****************
**#  2018 *******
*****************

capture program drop myboot
program define myboot, rclass
preserve

// Calculamos la población total 
sum FEX_C, meanonly 	
local pob2018 = r(sum)	

// Confirmamos que la codificación para frecuencia semanal es la misma     
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C] 
local prev2018=r(mean) 
scalar prev2018_scalar = `prev2018' 

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 
keep if prevalencia_semanal==1 
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

// Calculamos la la media para los que fuman diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile   
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Fuman algunos días de la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana

// Collapse con el consumo mensual //
gen consumo_mensual = consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final 
gen consumo_total_2018 = consumo_mensual * 12 * `pob2018' * `prev2018'
sum consumo_total_2018 
return scalar total2018 = r(mean)
restore 
end 

use P1706 P1706S1 P1706S1A1 FEX_C using "$data_ecv\ENCV2018\original\Salud.dta", clear 
rename P1706 prevalencia_semanal 
rename P1706S1 frecuencia_semanal 
rename P1706S1A1 consumo_diario 
bootstrap r(total2018), reps(1000) seed(123): myboot 
estat bootstrap, all

// Armamos las matrices y guardamos los resultados //
matrix results2018=J(1,5,.)
matrix results2018[1,1]=2018
matrix results2018[1,2]= e(b)[1,1]
matrix results2018[1,3]= e(ci_percentile)[1,1]
matrix results2018[1,4]= e(ci_percentile)[2,1] 
matrix results2018[1,5]= prev2018_scalar
matrix list results2018


**********************
******** 2019 ********
**********************

capture program drop myboot
program define myboot, rclass 
preserve

// Calculamos la población total 
sum FEX_C, meanonly 
local pob2019=r(sum)


// Confirmamos que la codificación para frecuencia semanal es la misma 
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2019=r(mean) 
scalar prev2019_scalar = `prev2019' 

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal   
keep if prevalencia_semanal==1
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  


// Calculamos la media para los que consumen diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Algunos días a la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana

// Estimar un consumo mensual //
gen consumo_mensual= consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final   
gen consumo_total_2019 = consumo_mensual * 12 * `pob2019' * `prev2019' 
sum consumo_total_2019 
return scalar total2019 = r(mean)
restore 
end 

use P3008S1 P3008S1A1 P3008S1A2 FEX_C using "$data_ecv\ENCV2019\original\Salud.dta", clear

rename P3008S1 prevalencia_semanal
 
rename P3008S1A1 frecuencia_semanal 

rename P3008S1A2 consumo_diario
 
bootstrap r(total2019), reps(1000) seed(123): myboot 
estat bootstrap, all

// Guardamos los resultados en una matriz ///
matrix results2019=J(1,5,.)
matrix results2019[1,1]=2019
matrix results2019[1,2]= e(b)[1,1]
matrix results2019[1,3]= e(ci_percentile)[1,1]
matrix results2019[1,4]= e(ci_percentile)[2,1] 
matrix results2019[1,5]= prev2019_scalar
matrix list results2019


**********************
********* 2020 *******
**********************

capture program drop myboot
program define myboot, rclass 
preserve 

// Calculamos población total 
sum FEX_C, meanonly 
local pob2020 = r(sum) 

// Confirmamos que la codificación para frecuencia semanal es la misma   
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2020=r(mean)  
scalar prev2020_scalar = `prev2020'   

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal  
keep if prevalencia_semanal==1
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

* Calculamos media para los que consumen diariamente *
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Algunos días a la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana 

// Collapse con consumo mensual 
gen consumo_mensual= consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

* Consumo total * 
gen consumo_total_2020= consumo_mensual*12*`pob2020'*`prev2020'
sum consumo_total_2020 
return scalar total2020= r(mean) 
restore 
end 
use P3008S1 P3008S1A1 P3008S1A2 FEX_C using "$data_ecv\ENCV2020\original\Salud.dta", clear

rename P3008S1 prevalencia_semanal 

rename P3008S1A1 frecuencia_semanal
 
rename P3008S1A2 consumo_diario

bootstrap r(total2020), reps(1000) seed(123): myboot 
estat bootstrap, all

// Guardamos los resultados en matrices

matrix results2020=J(1,5,.)
matrix results2020[1,1]=2020
matrix results2020[1,2]= e(b)[1,1]
matrix results2020[1,3]= e(ci_percentile)[1,1]
matrix results2020[1,4]= e(ci_percentile)[2,1] 
matrix results2020[1,5]= prev2020_scalar
matrix list results2020

****************
***** 2021 *****
****************
 
capture program drop myboot
program define myboot, rclass 
preserve

// Calculamos la población total 
sum fex_c, meanonly
local pob2021 = r(sum) 

// Confirmamos que la codificación para frecuencia semanal es la misma     
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=fex_c]
local prev2021=r(mean)  
scalar prev2021_scalar = `prev2021'  
keep if prevalencia_semanal==1  

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

// Calculamos media para los que consumen diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Algunos días a la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana 

// collapse con consumo mensual 
gen consumo_mensual = consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=fex_c]

// Estimación final  
gen consumo_total_2021= consumo_mensual * 12 * `pob2021' * `prev2021' 
sum consumo_total_2021 
return scalar total2021=r(mean) 
restore
end 

use p3008s1 p3008s1a1 p3008s1a2 fex_c using "$data_ecv\ENCV2021\original\Salud.dta", clear

rename p3008s1 prevalencia_semanal
 
rename p3008s1a1 frecuencia_semanal
 
rename p3008s1a2 consumo_diario
 
bootstrap r(total2021), reps(1000) seed(123): myboot 
estat bootstrap, all 
 
// Guardamos los resultados en matrices 
matrix results2021=J(1,5,.)
matrix results2021[1,1]=2021
matrix results2021[1,2]= e(b)[1,1]
matrix results2021[1,3]= e(ci_percentile)[1,1]
matrix results2021[1,4]= e(ci_percentile)[2,1] 
matrix results2021[1,5]= prev2021_scalar
matrix list results2021


********************
**# Año 2022   *****
********************

capture program drop myboot
program define myboot, rclass 
preserve 

// Población total 
sum FEX_C, meanonly 
local pob2022 = r(sum) 
 
// Obtenemos la prevalencia 
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2022 = r(mean)  
scalar prev2022_scalar = `prev2022'  
keep if prevalencia_semanal==1

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

// Calculamos media para los que consumen diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Algunos días a la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana 

// Collapse consumo mensual 
gen consumo_mensual= consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final  
gen consumo_total_2022 = consumo_mensual * 12 * `pob2022' * `prev2022'
sum consumo_total_2022
return scalar total2022=r(mean) 
restore 
end

use P3008S1 P3008S1A1 P3008S1A2 FEX_C using "$data_ecv\ENCV2022\original\Salud.dta", clear

rename P3008S1 prevalencia_semanal 

rename P3008S1A1 frecuencia_semanal 

rename P3008S1A2 consumo_diario
 
bootstrap r(total2022), reps(1000) seed(123): myboot 
estat bootstrap, all 

// Guardamos los resultados en matrices 
matrix results2022=J(1,5,.)
matrix results2022[1,1]=2022
matrix results2022[1,2]= e(b)[1,1]
matrix results2022[1,3]= e(ci_percentile)[1,1]
matrix results2022[1,4]= e(ci_percentile)[2,1] 
matrix results2022[1,5]= prev2022_scalar
matrix list results2022


******************
**#  2023 ********
******************

capture program drop myboot
program define myboot, rclass 
preserve 

// Población total 
sum FEX_C, meanonly 
local pob2023 = r(sum) 
 
// Obtenemos la prevalencia 
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2023 = r(mean)   
scalar prev2023_scalar = `prev2023' 
keep if prevalencia_semanal==1

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

// Calculamos media para los que consumen diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Algunos días a la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana 

// Collapse consumo mensual 
gen consumo_mensual= consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final  
gen consumo_total_2023 = consumo_mensual * 12 * `pob2023' * `prev2023'
sum consumo_total_2023
return scalar total2023=r(mean) 
restore 
end

use P3008S1 P3008S1A1 P3008S1A2 FEX_C using "$data_ecv\ENCV2023\original\Salud.dta", clear

rename P3008S1 prevalencia_semanal 

rename P3008S1A1 frecuencia_semanal 

rename P3008S1A2 consumo_diario
 
bootstrap r(total2023), reps(1000) seed(123): myboot 
estat bootstrap, all 

/// Guardamos los resultados en matrices //
matrix results2023=J(1,5,.)
matrix results2023[1,1]=2023
matrix results2023[1,2]= e(b)[1,1]
matrix results2023[1,3]= e(ci_percentile)[1,1]
matrix results2023[1,4]= e(ci_percentile)[2,1] 
matrix results2023[1,5]= prev2023_scalar
matrix list results2023


******************
**# 2024 *********
******************

capture program drop myboot
program define myboot, rclass 
preserve 

// Población total 
sum FEX_C, meanonly 
local pob2024 = r(sum) 
 
// Obtenemos la prevalencia 
replace prevalencia_semanal=0 if prevalencia_semanal==2
sum prevalencia_semanal [iw=FEX_C]
local prev2024 = r(mean)  
scalar prev2024_scalar = `prev2024'  
keep if prevalencia_semanal==1

// Aproximando con la metodología de Paraje (2023) estimamos el número de días semanal 
gen dias_semana=. 
replace dias_semana=7 if frecuencia_semanal==1 
replace dias_semana=1 if frecuencia_semanal==3
replace dias_semana= runiformint(2,6) if frecuencia_semanal==2  

// Calculamos media para los que consumen diariamente 
summarize consumo_diario if frecuencia_semanal == 1, meanonly 
local mean_fuma_diario = r(mean)

// Completamos para los demás grupos de acuerdo a las proporciones estimadas con la ENCSP 2019 al principio del dofile
gen consumo_diario_ajustado=.
replace consumo_diario_ajustado= consumo_diario if frecuencia_semanal==1
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_algunosdias if frecuencia_semanal==2 // Algunos días a la semana
replace consumo_diario_ajustado= `mean_fuma_diario' * $mean_fuma_unavez if frecuencia_semanal == 3 // Menos de una vez por semana 

// Collapse consumo mensual 
gen consumo_mensual = consumo_diario_ajustado * dias_semana * 4.25 
collapse (mean) consumo_mensual [pw=FEX_C]

// Estimación final  
gen consumo_total_2024 = consumo_mensual * 12 * `pob2024' * `prev2024'
sum consumo_total_2024
return scalar total2024 = r(mean) 
restore 
end

use P3008S1 P3008S1A1 P3008S1A2 FEX_C using "$data_ecv\ENCV2024\original\Salud.dta", clear

rename P3008S1 prevalencia_semanal 

rename P3008S1A1 frecuencia_semanal 

rename P3008S1A2 consumo_diario

bootstrap r(total2024), reps(1000) seed(123): myboot 
estat bootstrap, all
  
/// Guardamos los resultados en matrices //
matrix results2024=J(1,5,.)
matrix results2024[1,1]=2024
matrix results2024[1,2]= e(b)[1,1]
matrix results2024[1,3]= e(ci_percentile)[1,1]
matrix results2024[1,4]= e(ci_percentile)[2,1] 
matrix results2024[1,5]= prev2024_scalar
matrix list results2024


//// Juntar las matrices de todos los años ///
matrix matriz_anual= results2016\results2017\results2018\results2019\results2020\results2021\results2022\results2023\results2024 
matrix list matriz_anual 
clear
/// Guardar la matriz de los años como una base de datos y cambiar nombres de las columnas ///
svmat matriz_anual, names(col) 
rename c1 año 
rename c2 estimacion_consumo
rename c3 IC_limite_inferior 
rename c4 IC_limite_superior 
rename c5 prevalencia

// Formato /// 
format IC_limite_inferior %20.3f 
format IC_limite_superior %20.3f 
format estimacion_consumo %20.3f 
format prevalencia

save "$carpetaMadre\Data\Created data\ECV_TABACO", replace 


****************************************
* Graficar *****************************  
****************************************

use "$carpetaMadre\Data\Created data\ECV_TABACO", replace 

replace prevalencia = prevalencia*100

* Gráfico de prevalencias 
twoway (line prevalencia año, mcolor(blue) lwidth(medium)), ///
       xtitle("Año") ///
       ytitle("Prevalencia de consumo de tabaco") ///
       xlabel(2016(1)2024) ///
       ylabel(3(1)10)


* Gráfico sobre millones * 
gen UpperLimit= IC_limite_superior/1000000
gen LowerLimit= IC_limite_inferior/1000000
gen unidades_estimadas = estimacion_consumo/1000000

twoway (line unidades_estimadas año, mcolor(blue) lwidth(medium)) ///
       (line UpperLimit año, lcolor(red) lwidth(medium) lpattern(dash)) ///
       (line LowerLimit año, lcolor(green) lwidth(medium) lpattern(dash)), ///
       xtitle("Año") ///
       ytitle("Consumo de Cigarrillos (en millones)") ///
       xlabel(2016(1)2024) ///
       ylabel(4000(500)8500)


* Según Caballero et al se utiliza un factor de correción de 1.2 en la prevalencia de la ECV por problemas de subreporte * 

gen UpperL_ajuste = UpperLimit * 1.2
gen Consumo_ajuste = unidades_estimadas  * 1.2
gen LowerL_ajuste = LowerLimit * 1.2 

twoway (line Consumo_ajuste año, mcolor(blue) lwidth(medium)) ///
       (line UpperL_ajuste año, lcolor(red) lwidth(medium) lpattern(dash)) ///
       (line LowerL_ajuste año, lcolor(green) lwidth(medium) lpattern(dash)), ///
       xtitle("Año") ///
       ytitle("Consumo de Cigarrillos con ajuste de prev. (en millones)") ///
       xlabel(2016(1)2024) ///
       ylabel(5000(500)10000)

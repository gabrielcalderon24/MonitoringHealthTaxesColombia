**************************************************************************
**** Pre-procesamiento: Monitoreo de impuestos saludables en Colombia ****
**************************************************************************

// Este dofile realiza algunos preprocesamientos necesarios en la preparación de distintas bases de datos empleadas para el cálculo de indicadores de monitoreo de impuestos saludables en Colombia. Se debe ejecutar antes de continuar con los demás dofiles 

****************
** ENCSP 2019 ** 
**************** 

**# Primer preprocesamiento

// Tomamos datos raw desde el DANE y unimos para incluir FEX_C

use "$carpetaMadre\Data\ENCSP\2019_raw\e_capitulos.dta", clear

merge 1:1 DIRECTORIO using "$carpetaMadre\Data\ENCSP\2019_raw\personas_seleccionadas.dta"

keep E_05 E_06 E_07 E_09 FEX_C E_08
rename E_06 dias_mes
rename E_09 consumo_diario  
keep if consumo_diario!=99 & E_07!=9 & dias_mes!=99 & E_08!=9

// Guardamos esta base de datos ya procesada, a partir de estos datos podemos estimar el consumo anual de cigarrillos con factores de expansión (unidades).
tempfile encsp_2019 
save `encsp_2019' 


**# Segundo preprocesamiento 

use `encsp_2019', clear 

/* Una particularidad de la encuesta en el año 2019 es que en la pregunta E_09, únicamente se pregunta 
por el número de cigarrillos diarios si la persona contesta que fumó diariamente en la semana anterior 
(E_08 ==1). Por lo tanto, se deben completar estos datos de consumo diario para los grupos que fumaron algunos 
días de la semana (E_08 == 2) y menos de una vez en la semana (E_08 ==3).
*/

// Para completar aquellos que no registran consumo diario, tomamos el promedio de cigarrillos consumidos diariamente dentro de cada grupo del número de días que fuma mensual  

preserve 

rename consumo_diario consumo_diario_mean

collapse (mean) consumo_diario_mean [pw=FEX_C], by(dias_mes) 

tempfile promedios 

save `promedios', replace // Guardamos una base solo para los promedios calculados  

restore 

// Volver a juntar los promedios ponderados según el número de días con la base original 

keep if E_05==1
 
merge m:1 dias_mes using `promedios'

// completar registros de consumo diario con las medias calculadas y generar un consumo mensual promedio 

replace consumo_diario = consumo_diario_mean if missing(consumo_diario)

replace consumo_diario = round(consumo_diario)

drop consumo_diario_mean _merge

save "$carpetaMadre\Data\ENCSP\ENCSP_2019", replace // Se hace una excepción con esta base, no la guardamos en created data sino directamente en data

**# Tercer preprocesamiento 

/* En la estimación del número de cigarrillos consumidos en la ECV, es fundamental completar nuevamente las proporciones para quienes no fuman todos los días de la semana. Algo similar a lo que ya hicimos. Esto lo realizamos de acuerdo a las proporciones de consumo entre los distintos grupos de frecuencia semanal según la ENCSP 2019. Es decir, tomar el consumo promedio entre cada grupo y calcular las proporciones. Por ejemplo, quiénes fuman 1 día a la semana fuman en promedio cierta cantidad de cigarrillos en comparación a quiénes fuman 7 días a la semana. 

Estos promedios se calculan de acuerdo a la ENCSP 2019 y se usan posteriormente para completar el consumo diario en la ECV.
*/

use "$carpetaMadre\Data\ENCSP\ENCSP_2019", clear 

preserve 

keep if E_08==1 

collapse (mean) consumo_diario [pw=FEX_C], by(E_08) 

local mean_grupo1 = consumo_diario 

restore 

// Proporciones entre cada grupo de acuerdo a la pregunta de consumo semanal (E_08) 

drop if E_08 ==.

collapse (mean) consumo_diario [aw=FEX_C], by(E_08)

gen proporciones = consumo_diario/`mean_grupo1'

rename E_08 frecuencia_semanal 

save "$carpetaMadre\Data\Created data\encsp_2019_proporciones_para_ecv", replace 












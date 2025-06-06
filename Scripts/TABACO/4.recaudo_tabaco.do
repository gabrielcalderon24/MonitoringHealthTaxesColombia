// Definir nuevamente la carpeta para leer archivos de cada departamento //
local dptos "$carpetaMadre/Data/datos_CHIP"
clear all
set obs 1
gen uno=1

tempfile tempo
save `tempo', replace

// Appendeamos todos los archivos por departamento en una única base grande
local Chip : dir "`dptos'" files "*.xls"
foreach file in `Chip' {
	import excel using "`dptos'/`file'", sheet("reporte pag 1") cellrange(A10) firstrow clear
	gen nome="`file'"
	append using `tempo'
	save `tempo', replace
}
drop in 1
drop uno

// Generar los años a partir de la variable nome de cada archivo 
gen year_str=substr(nome,-6,2)
gen year = real("20" + year_str)
destring year, replace


// Para 2014, 2015 y 2016 no hay recaudo en pesos, solo en miles, cambiamos las comas por puntos y volvemos ambas variables númericas. Para 2022 son muy diferentes los rubros  
gen recaudoefectivopesos = subinstr(RECAUDOEFECTIVOPesos, ",", ".", .)
destring recaudoefectivopesos, replace
format recaudoefectivopesos %20.2f 

gen recaudoefectivomiles = subinstr(RECAUDOEFECTIVOMiles, ",", ".", .)
destring recaudoefectivomiles, replace
format recaudoefectivomiles %20.2f  

keep if inlist(CODIGO, ///
	"TI.A.1.18.1 " , ///   // IMPUESTO AL CONSUMO DE CIGARRILLOS Y TABACO, COMPONENTE ESPECÍFICO DE LIBRE INVERSIÓN.
	"TI.A.1.18.2 " 	, ///   // COMPONENTE AD VALOREM DEL IMPUESTO AL CONSUMO DE CIGARRILLOS Y TABACO ELABORADO, CON DESTINO A SALUD
	"TI.A.1.18.3 "	, ///   // IMPUESTO CON DESTINO AL DEPORTE LEY 181 DE 1995
	"TI.A.1.18.4 "	  ///	// RECAUDO  POR AUMENTO  TARIFA  IMPUESTO AL CONSUMO DE CIGARRILLOS Y TABACO PARA  ASEGURAMIENTO SALUD 
)

replace recaudoefectivomiles = recaudoefectivomiles * 1000
replace recaudoefectivopesos = recaudoefectivomiles if missing(recaudoefectivopesos)

// Guardamos un Excel para tener la contabilidad de cada rubro específico de recaudo

preserve 

collapse (sum) recaudoefectivopesos, by(year CODIGO NOMBRE) 
 
export excel using "$carpetaMadre\Data\Created data\recuados_tabaco.xlsx", firstrow(variables) replace

restore 

// En miles de millones   
gen recaudoefectivomiles_millones = recaudoefectivopesos/1000000000
drop if year == 2008 | year == 2009 

// Generamos las categorías de impuesto específico y Ad-valorem 

gen tipo = "."
replace tipo = "especifico" if CODIGO == "TI.A.1.18.1 "  
replace tipo = "advalorem"  if CODIGO == "TI.A.1.18.2 "  

drop if tipo == "."

// Colapsamos nuevamente ahora por categoria 

collapse (sum) recaudoefectivomiles_millones, by(year tipo) 

save "$carpetaMadre/Data/Created data/recaudo_tabaco_componente", replace 




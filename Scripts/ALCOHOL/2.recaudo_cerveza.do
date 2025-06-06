local dptos_c "$carpetaMadre\Data\datos_CHIP"
clear all
set obs 1
gen uno=1

tempfile tempo
save `tempo', replace

// Appendeamos todos los archivos por departamento en una única base grande
local chip_c : dir "`dptos_c'" files "*.xls"
foreach file in `chip_c' {
	import excel "`dptos_c'/`file'", sheet("reporte pag 1") cellrange(A10) firstrow clear
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

// Filtrar por códigos específicos de cerveza 

keep if CODIGO == "TI.A.1.16 " | CODIGO == "TI.A.1.17 " 

// Dejamos todo en pesos 

replace recaudoefectivomiles = recaudoefectivomiles * 1000
replace recaudoefectivopesos = recaudoefectivomiles if missing(recaudoefectivopesos)

// Guardamos un Excel para tener la contabilidad de acuerdo a cada rubro específico 

preserve 
 
collapse (sum) recaudoefectivopesos, by(year CODIGO NOMBRE) 

drop if year==2009 | year==2008

export excel using "$carpetaMadre/Data/Created data/recaudos_especificos_cerveza.xlsx", firstrow(variables) replace

restore

// Sumar para cada año específico. Es importante aclarar que se está sumando el recaudo total 
collapse (sum) recaudoefectivopesos, by(year) 

// Pasamos a billones 
gen recaudoefectivobillones=recaudoefectivopesos/1000000000000 
drop if year==2008 | year==2009 

save "$carpetaMadre\Data\Created data\recaudo_cerveza.dta", replace

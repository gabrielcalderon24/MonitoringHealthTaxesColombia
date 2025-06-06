// Procesamiento recaudo de impuestos según la ADRES. En este caso calculamos el recaudo para el alcohol 
clear
set obs 1
gen uno=1
tempfile recaudo
save `recaudo'

// Importamos distintos archivos para el registro del recado de ADRES y juntamos todo en una base 
foreach year in 2019 2020 2021 2022 2023 {
	foreach month in "01" "02" "03" "04" "05" "06" "07" "08" "09" "11" "12" {
		disp in red "`year'`month'"
		import excel "$carpetaMadre\Data\compilado_ADRES\Compilado ADRES recaudo.xlsx", sheet("`year'`month'") cellrange(A4:H36) clear
		gen year=`year'
		gen month=`month'
		append using `recaudo'
		save `recaudo', replace
	}
}

// Renonmbramos cuentas que nos interesan 
rename A departamento
rename B juegosyazar
rename C cerveza
rename D cigarrillos
rename E adValcigarrillos
rename F licores
rename G otros
rename H totales

drop if year==.
drop uno

foreach varo of varlist juegosyazar - totales {
	replace `varo'=subinstr(`varo',".","",.)
	replace `varo'=subinstr(`varo',",",".",.)
}
destring juegosyazar - totales , replace force

// Guardamos base consolidada del recaudo, estos datos limpios nos permiten calcular el recaudo total para distintos rubros colapsando por año. Este es el mismo proceso que ya se hace para calcular el recaudo del ADRES en tabaco. Se puede realizar nuevamente o llamar directamente la base.

save "$carpetaMadre\Data\Created data\recaudoADRES_consolidado.dta", replace 


// Colapsamos por año para cada rubro 

collapse (sum) juegosyazar - totales , by(year)

// Dejamos los datos en millones 

foreach varo of varlist juegosyazar - totales {
	replace `varo'= `varo'/1000
}

keep cerveza licores year
rename year FechaAño

save "$carpetaMadre\Data\Created data\recaudoADRES_alcohol.dta", replace 

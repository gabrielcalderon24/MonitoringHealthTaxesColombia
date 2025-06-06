* Paths setting 
* global carpetaMadre= ".\..\" 

global carpetaMadre= "C:\Users\gabri\Universidad del rosario\Control Tabaco Facultad Economica - Documentos\Monitoreo\Repositorio" // Main directory 

* Los códigos en el repositorio están agrupados de acuerdo al producto: Tabaco, alcohol y bebidas azucaradas. Andar por favor en el orden especificado.

**************************************
* A) Códigos correspondientes a Tabaco 

* A.0) Pre-procesamiento de la ENCSP 2019. Es importante andar este dofile primero 
do "$carpetaMadre\Scripts\TABACO\1.Pre-procesamiento_ENCSP.do"
* A.1) Procesamiento unidades de cigarrillos consumidas en la ECV y prevalencias 
do "$carpetaMadre\Scripts\TABACO\2.ecv_tabaco.do"	
* A.2) Procesamiento unidades de cigarrillos consumidas en la ENCSP  
do "$carpetaMadre\Scripts\TABACO\3.encsp_tabaco.do"
* A.3) Procesamiento recaudo CHIP  
do "$carpetaMadre\Scripts\TABACO\4.recaudo_tabaco.do"
* A.3) Procesamiento recaudo ADRES 
do "$carpetaMadre\Scripts\TABACO\5.ADRES_tabaco.do"		
* A.4) Procesamiento consumo aparente de tabaco (Producción + Imp - exp) 
do "$carpetaMadre\Scripts\TABACO\6.ConsumoAparente_tabaco.do"
* A.6) Procesamiento consumo aparente, IHH y prevalencia de vapeadores 
do "$carpetaMadre\Scripts\TABACO\7.vapeadores_ecv.do"

***************************************
* B) Códigos correspondientes a Alcohol  

* B.1) Procesamiento prevalencia y gasto de bebidas alcohólicas en la ECV 
do "$carpetaMadre\Scripts\ALCOHOL\1.alcohol_ECV.do"
* B.2) Procesamiento recaudo CHIP cerveza  
do "$carpetaMadre\Scripts\ALCOHOL\2.recaudo_cerveza.do"
* B.2.1) Procesamiento recaudo CHIP Licores y vinos 
do "$carpetaMadre\Scripts\ALCOHOL\3.recaudo_vinosLicores.do"
* B.3) Procesamiento recaudo ADRES para cerveza y vinos y licores
do "$carpetaMadre\Scripts\ALCOHOL\4.ADRES_alcohol.do"
* B.4) Procesamiento consumo aparente de alcohol (Producción + Imp - exp) 
do "$carpetaMadre\Scripts\ALCOHOL\5.ConsumoAparente_alcohol.do"	
* B.5) Procesamiento consumo aparente alcohol etílico
do "$carpetaMadre\Scripts\ALCOHOL\6.ConsumoAparente_alcoholEtilico.do"	

**************************************************
* C) Códigos correspondientes a Bebidas azucaradas y alimentos ultraprocesados

* C.1) Procesamiento prevalencia y consumo de Bebidas azucaradas ECV 
do "$carpetaMadre\Scripts\BEBIDAS AZUCARADAS\1.ecv_bebidas_azucaradas.do"	

* C.2) Procesamiento prevalencia, gasto y consumo de alimentos ultraprocesados ECV 
do "$carpetaMadre\Scripts\BEBIDAS AZUCARADAS\2.ecv_ultraprocesados.do"




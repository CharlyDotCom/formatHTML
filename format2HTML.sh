#!/bin/bash
#------------------------------------------------------------------------------*
# File   : formatHTML.sh
# Author : Carlos Almela 
# Date   : 08/03/2023 10:00 
# Version: 1.0
# Subject: script de formateo de datos CSV en una página HTML
#          bootstrap
#------------------------------------------------------------------------------*
#---- Definición de Ficheros --------------------------------------------------*
FILERESULT='informehtml.txt'
FILEOUTPUT='informe.html'
FILEPATERN='template.html'
FILERESUMEN='informehtmlresumen.txt'

#---- Funciones ---------------------------------------------------------------*
set_variable(){
  IFS=';' read -a array <<< "$line"
  machine=${array[0]}
  apli=${array[1]}
  item=${array[2]}
  proc=${array[3]}
  status=${array[4]}
}

# obtener cabecera del template y sustituir variables 
# fecha de informe por fecha actual
escribir_cabecera_html(){
  currentdate=$(date  +" %d/%m/%Y %T")
  echo $currentdate
  cat $FILEPATERN | grep "<!-- HEAD -->" |sed -e 's/<!-- HEAD -->/ /g' > $FILEOUTPUT
  echo "<p class=\"text-end\">Fecha elaboraci&oacute;n: $currentdate</p></div>"  >> $FILEOUTPUT 
}


# Obtener linea del entorno del template
# sustituir la variable entorno
# escribir_entorno_html(){ 
# }

# Escribe la cabecera del informe
#------------------------------------------------------------------------------*
escribir_machine_html(){
  get_resumen_machine  
  cat $FILEPATERN | grep "<!-- MQHEAD -->" |sed -e 's/<!-- MQHEAD -->/ /g' >> $FILEOUTPUT

  if [[ $tipoboton == "V" ]]; then
    echo "<a href=\"#$machine \" class=\"btn btn-success\" data-bs-toggle=\"collapse\">$machine</a>" >> $FILEOUTPUT
  fi 
  if [[ $tipoboton == "A" ]]; then
    echo "<a href=\"#$machine\" class=\"btn btn-warning\" data-bs-toggle=\"collapse\">$machine</a>" >> $FILEOUTPUT
  fi         
  if [[ $tipoboton == "R" ]]; then
    echo "<a href=\"#$machine\" class=\"btn btn-danger\" data-bs-toggle=\"collapse\">$machine</a>" >> $FILEOUTPUT
  fi 

  cat $FILEPATERN | grep "<!-- MQFOOT -->" |sed -e 's/<!-- MQFOOT -->/ /g' >> $FILEOUTPUT
  cat $FILEPATERN | grep "<!-- ITEMHEAD -->" |sed -e 's/<!-- ITEMHEAD -->/ /g' >> $FILEOUTPUT
  echo "<p>$itemsKO KO / $totItems Items</p>" >> $FILEOUTPUT
  echo "<table id=\"$machine\" class=\"table table-striped collapse\">" >> $FILEOUTPUT
  cat $FILEPATERN | grep "<!-- ITEMTBL -->" |sed -e 's/<!-- ITEMTBL -->/ /g' >> $FILEOUTPUT
}
#
# Obtiene información resumen de la máquina
#------------------------------------------------------------------------------*
get_resumen_machine(){
  tmpLine=`grep $machine $FILERESUMEN`
  # echo "Resumen: $tmpLine"
  IFS=';' read -a array <<< "$tmpLine"
    itemsKO=${array[1]}
    totItems=${array[2]}
    tipoboton=${array[3]}
 # echo " KOs: $itemsKO Total: $totItems Tipo Boton: $tipoboton" 
}
#
# Escribe el pie de cada máquina
#------------------------------------------------------------------------------*
escribir_pie_machine_html(){
  cat $FILEPATERN | grep "<!-- ENDMQ -->" |sed -e 's/<!-- ENDMQ -->/ /g' >> $FILEOUTPUT
}
# Escribe la cabecera de un Item de monitorización
#------------------------------------------------------------------------------*
escribir_head_item_html(){
  cat $FILEPATERN | grep "<!-- HEADITEM -->" |sed -e 's/<!-- HEADITEM -->/ /g' >> $FILEOUTPUT
}
# Escribe un item de monitorización
#------------------------------------------------------------------------------*
escribir_item_html(){
  if [[ $status == "[OK]" ]];then
    echo "<tr class=\"p-3\"><td>$apli</td><td>$item</td><td>$proc</td><td>$status</td></tr>" >> $FILEOUTPUT
  else
    echo "<tr class=\"p-3\"><td>$apli</td><td>$item</td><td>$proc</td><td class=\"bg-danger text-light\">$status</td></tr>" >> $FILEOUTPUT
  fi 
}
# Escribe pie de Item de monitorización
#------------------------------------------------------------------------------*
escribir_foot_item_html(){
  cat $FILEPATERN | grep "<!-- ENDITEM -->" |sed -e 's/<!-- ENDITEM -->/ /g' >> $FILEOUTPUT
}

# Escribe pie de página HTML
#------------------------------------------------------------------------------*
escribir_pie_html(){
  cat $FILEPATERN | grep "<!-- FOOT -->" |sed -e 's/<!-- FOOT -->/ /g' >> $FILEOUTPUT
}
#---- Inicio

# 
# Borramos la salida
rm -rf $FILEOUTPUT
#
# Escribimos cabecera informe
escribir_cabecera_html

machine_ant=''

while IFS= read -r line
do
  #
  #  Eliminamos comentarios del fichero
  #
	if [[ "${line:0:1}" != "#" ]]; then
    #
    #     
    #
    set_variable
    if [[ $machine != $machine_ant ]]; then
      if [[ $machine_ant != '' ]]; then 
        escribir_foot_item_html
        escribir_pie_machine_html        
      fi 
      escribir_machine_html
      escribir_head_item_html
      machine_ant=$machine  
    fi
    escribir_item_html
  fi
done < $FILERESULT
if [[ $machine_ant != '' ]]; then 
  escribir_foot_item_html
  escribir_pie_machine_html        
fi 
escribir_pie_html
exit 0



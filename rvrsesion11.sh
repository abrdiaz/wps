#!/bin/bash
# Parametro unico un arreglo separado por comas con el orden de salida
# ej. 3d,2i,1i,5d,9d,4d
# Ultima mitad del PIN se genera en orden predeterminado
# Esta version se detiene si encuentra un error
# MANDA TODO A STDOUT EN LUGAR DE A UN ARCHIVO PARA HACERLO MAS RAPIDO
# todo: no usar egrep
# todo: Si faltan numeros, agregarlos en orden

#set -x
function uso () {
	echo "- Reaver Session Maker v1.1 -"
	echo " - By: Abraham Diaz @adiaz - "
	echo "Usage: $(basename $0) n[i|d],m[i|d],o[i|d],... "
}

#Comprobar numero de argumentos
[ $# -ne 1 ] && { uso; exit 1; }
[ $1 = "-h" -o $1 = "--help" ] && { uso; exit 1; }

#Comprobar formato de numeros
[ $( egrep -c -x "[[:digit:]][id]?(,[[:digit:]][id]?){9}" <<< $1 ) -eq 0 ] && { echo "ERROR: Incomplete argument $1, see -h"; exit 1; } 

#Arreglos
#Primera mitad del PIN, prioridad
pri1=(0 123 1111 1234 2222 3333 4444 5555 6666 7777 8888 9999)
#Segunda mitad del PIN, prioridad
pri2=(0 456 111 567 222 333 444 555 666 777 888 999)
#Dice si el numero se encuentra poniendo 1 en la posicion
numeros=(0 0 0 0 0 0 0 0 0 0)
#Dice el orden en que se generara el archivo
declare -a orden

#Funciones
#Busca si el numero dado esta en un arreglo
#argumento1 numero a buscar
#argumento2 arreglo en string donde se buscara el argumento1
#Regresa 0 (exito o true) si no esta
function find_num () {
	local total_args=$#
	#set -x
	if [ $( egrep -c -w $1 <<< $2 ) -eq 1 ]
	then
		#echo "$1 Found, ignoring."
		return 1
	fi
	#set +x
	return 0
}


#Comprobar que existen los numeros del 0 al 9, salir si falta alguno.
num_error=1
for i in {0..9}
do
	num_pos=$(grep -o "$i" <<< $1)
	if [ ${#num_pos} -eq 0 ]
	then
		echo "ERROR: Missing $i"
		num_error=0
	elif [ ${#num_pos} -ge 2 ]
	then
		echo "ERROR: Number $i is repeated"
		num_error=0
	fi
done

if [ $num_error -eq 0 ]
then
	echo "ERROR: Invalid argument $1"
	exit 1
else
	#echo "Valid argument :)"
fi


#Llenar el arreglo orden
for (( i=0;i<10;i++ ))
do
	orden[$i]=$(cut -d, -f $(( i+1 )) <<< $1 | grep -o [[:digit:]])
done


#Imprimir las primeras 3 lineas en 0
echo 0
echo 0
echo 0
#Imprimir las prioridades primera mitad
for i in {0,123,1111,1234,2222,3333,4444,5555,6666,7777,8888,9999}
do
	printf "%.4d\n" $i
done


#Imprimir lo demas
for (( i=0;i<10;i++ ))
do
	temp1=$(cut -d, -f $(( i+1 )) <<< $1 | grep -o d)
	if [ "$temp1" != "d" ]
	then
		inicio=$(( orden[i] * 1000 ))
		fin=$(( inicio + 1000 ))
		#echo "Writing $inicio - $(( fin-1 ))"
		for (( j=inicio;j<fin;j++ ))
		do
			#Si la funcion regresa con un 0, es exito e imprime
			find_num $j "${pri1[*]}" && printf "%.4d\n" $j
		done
	else
		fin=$(( orden[i] * 1000 ))
		inicio=$(( fin + 999 ))
		#echo "Writing $inicio - $fin"
		for (( j=inicio;j>=fin;j-- ))
		do
			#Si la funcion regresa con un 0, es exito e imprime
			find_num $j "${pri1[*]}" && printf "%.4d\n" $j
		done
	fi
done
#echo "1st part: $(wc -l $1) lines. Expected: 10003 lines."


#Imprimir las prioridades segunda mitad
for i in {0..11}
do
	printf "%.3d\n" ${pri2[i]}
done


#Imprimir lo demas
for (( i=0; i<1000; i++ ))
do
	find_num $i "${pri2[*]}" && printf "%.3d\n" $i
done
#echo "2nd part: $(wc -l $1) total lines. Expected: 11003 total lines."


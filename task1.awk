#!/usr/bin/awk -f

BEGIN {

	option = ARGV[2];
	ARGV[2] = "";
}

/* Agrupar per tipus de petició, mida*/
/* i contingut descarregat*/

$6~ /.(GET|POST|PUT|DELETE|HEAD)/ && $7 ~ /^\// {
	
	split($7, parts, "?");
	url = parts[1];
    metode = substr($6, 2);
	contmetode[$1][metode][url]++;
}

/*Columna de errors, contabilitzar nombre de peticions diferents de 200*/
/*Si son peticions de tipus 500 accedir al fitxer d'errors*/
/*Filtrar per IP i nombre d'errors*/

nErrors[$1][url] = 0;

$9 != 200 {
	#Errors[ip][url];
	nErrors[$1][url]++;
	if ($9 == 500)
	{
		#enmagatzemar les ip i el timeStamp de les lineas del fitxer
		#amb errors de tipus 500
		#arrayIP_TIME[timeStamp] = ip
		gsub (/\[/,"",$4);
		gsub(/\//,"-",$4);
		gsub(/:/,"",$4);
		arrayIP_TIME[$4][$1]++;
	}

}

#funcion que lee el segundo fichero para los errores de tipo 500 y devuelve 
#el tipo de error recibido
function statsError(){
	 #obrir l'altre fitxer i comparar arrayIP_TIME amb el propi timeStamp del fitxer d'errors
 	 #imprimir la ip i el propi tipus d'error
     while(( getline line<"personal.error.log-20230928") > 0 ){

         #del nuevo fichero quiero borrar los : para que sea un código único
         #y fusionar las columnas 1 y 2 para que tengan el mismo formato que el diccionario

         gsub(/:/,"",$2);
         $1 = $1 $2;
         $2 = "";

         if ($1 ~ /^\[[0-9]{2}/)
         {
             gsub(":","",$2);
             $1 = $1 $2;
             $2 = "";

             if ($1 in arrayIP_TIME)
             {
                 #si coincide con el diccionario, se debe mostrar la ip
                 #y el tipo de error
                for(ip in arrayIP_TIME[$1]){
                    print ip
                }
             }
        }
 	}

}



END{

	if (option ~ /statsError/)
		statsError();
	if (option ~ /showIP/)


	for(ip in contmetode)
		{
		for(cnt in contmetode[ip])
		{
			for(u in contmetode[ip][cnt])
		   	{
				#contmetode[ip][url][metode];
				print  ip, cnt, contmetode[ip][cnt][u], "Errors:" nErrors[ip][u], u;
			}
		}
	}
}

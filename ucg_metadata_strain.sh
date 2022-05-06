#!/bin/bash
#
#metadata
SAMPLES=metadata.csv
#
while IFS=, read -r field1 field2  

do  
    echo RUNNING ${field1} 
    echo "label : $field1" 
    echo "strain_name : $field2" 
        
    java -jar UBCG2.jar -i ./fasta/${field1}.fasta -ucg_dir path -label ${field1} -strain_name ${field2} -hmm hmm/ubcg_v2.hmm
    echo DONE ${field1} 

done < ${SAMPLES}

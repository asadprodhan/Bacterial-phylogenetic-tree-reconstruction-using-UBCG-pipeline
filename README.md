# **Bacterial Phylogenetic Tree Reconstruction Using UBCG Pipeline** <br />


## **Introduction**
UBCG stands for ‘the Up-to-date Bacterial Core Gene’. It is a bioinformatics pipeline that collects a set of core genes from the bacterial genome sequences and produces a RAxML tree based on the collected genes (Kim et al., 2021; Na et al., 2018).
<br />
<br />
The core gene set: The core gene set consists of single-copy homologous genes that are present in most species in the Bacteria domain. The total number of genes in the core set will vary depending on the taxonomic scope from domain to species level. The UBCG version 1 has 92 genes in its core set that are single-copy and present in 95% of the 1428 bacterial species (Na et al., 2018). On the other hand, the UBCG version2 has updated the core gene set with 81 genes selected out of 3508 bacterial genomes (Kim et al., 2021, p. 2).  
<br />
<br />
## **How to run?**
<br />
<br />
<p align="center">
  <img 
    width="850"
    height="240"
    src="https://github.com/asadprodhan/Bacterial-phylogenetic-tree-reconstruction-using-UBCG-pipeline/blob/main/Workflow_v2.png"
  >
<p align = "center">
Fig. Executing UBCG pipeline
</p>
<br />
<br />




- Visit the UBCG manual, http://leb.snu.ac.kr/ubcg2/usage
- Download the UBCG2.zip file
- Install the external program as listed in the above manual. Some example commands for installing on Ubuntu 18 are presented below:

  - Prodigal [required for the 1st script]:


    ```sudo apt-get update -y```
    
    ```sudo apt-get install -y prodigal```
    
    
  - HMMER [required for the 1st script]:

    ```sudo apt-get install -y hmmer```
    
  - MAFFT [required for the 2nd script]:

    ```sudo apt-get install -y mafft```
    
  - RAxML [required for the 2nd script]:

    ```sudo apt-get install -y raxml```
    
  - Furthermore, we will need to install Java RE 8+ and FastTree 2.1.x


- Extract the UBCG2.zip file
- ‘cd’ in to ‘UBCG_ver2’ directory
- Put all the genome sequences in ‘fasta’ format in the ‘fasta’ directory. Leave the other directories as they are.
  - path: it is empty. It will be automatically filled up with the ‘ucg’ files that are generated one from each genome sequences in the ‘fasta’ directory. ‘ucg’ files contain the core genes and their metadata
  - hmm: leave it as it is. It contains the hmm profile of extracted genes
  - output: Empty. Leave it as it is. It will automatically be filled up. It will contain the directory labelled as specied in the ‘run_id’ flag. This directory contains the tree files in ‘newick’ format that can be visualised in Geneious or FigTree.
  - ProgramPath: contains the paths of the external program. If the external programs are installed in their default locations, then the ‘programPath’ doesn’t require any modification. 	Just keep a copy of this text file in ‘UBCG_ver2’ and one copy in one directory up.
  - ucg: no usage of this folder




- Make a csv file as follows that will contain the metadata (details about the genomes)





<p align="center">
  <img 
    width="740"
    height="380"
    src="https://github.com/asadprodhan/Bacterial-phylogenetic-tree-reconstruction-using-UBCG-pipeline/blob/main/metadata.PNG"
  >
<p align = "center">
Fig. An example of metadata file (csv)
</p>


- Run the following script as follows: ./ucg_metadata_strain.sh


```
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
```

 **What the script does:**
  
    - Prodigal predicts CDSs in each genome      
    - HMMSearch identifies the core genes in each genome      
    - Generates one UCG (Updated Core Genes) file per gemone 
    - We can add more metadata to the 'metadata.csv' file and specify them in the script (see below)
    - The supplied metadata will be recoded to the UCG files and can be used to label the tree branches
    
    

### **Including more metadata:**




```
 #!/bin/bash
#
#metadata
SAMPLES=metadata.csv
#
while IFS=, read -r field1 field2 field3 field4 field5 field6 field7 

do  
    echo RUNNING ${field1} 
    echo "label : $field1" 
    echo "taxon_name : $field2" 
    echo "strain_name : $field3"
    echo "type : $field4"
    echo "accession : $field5"
    echo "taxonomy : $field6"
    echo "ncbi_name : $field7"   
    
    java -jar UBCG2.jar -i ./fasta/${field1}.fasta -ucg_dir path -label ${field1} -taxon_name ${field2} -strain_name ${field3} -type ${field4} -acc ${field5} -taxonomy ${field6} -ncbi_name ${field7} -hmm hmm/ubcg_v2.hmm
    echo DONE ${field1} 

done < ${SAMPLES}
```


 
- Check that the ‘path’ directory has content now. 

- Then run the following script as ./output.sh


```
#!/bin/bash

java -jar UBCGtree.jar align -ucg_dir ./path -run_id mytest1 -leaf label,strain 
```

**What it does:**


    - MAFFT performs multiple sequence alignment for each gene across all the genomes
    - Concatenates the alignments
    - Filters positions from the multiple alignment that show variations across the genomes
    - Reconstructs RAxML phylogenetic tree using the filtered positions
    - Calculates Gene Support Indices (GSIs) for the tree branches
    - Put the trees in the ‘output’ directory
    - The final tree file will be named as ‘concatenated_gsi(81).nwk’ with probably different gene numbers than 81 here 
    - The tree can be visualised using ‘FigTree’ 

> The final tree marked with GSI will be written to 'output/mytest1/concatenated_gsi(68).nwk
> Note that the core gene set here has only 68 genes. It will vary according to the taxonomic scope of the included species as mentioned above.


- To change the branch labels of the tree, run the following script:

```
#!/bin/bash
java -jar UBCGtree.jar replace ./output/mytest1/mytest1.trm UBCG -strain
```

**What it does:**


    - Changes the tree branch labels from ID to strain name
    - Any given metadata can be used as labels by modifying this script for the corresponding metadata 
    - The tree file 'replaced.UBCG.nwk' with replaced labels will be written and kept in the ‘UBCG_ver2’ directory
    
>The phylogenetic tree branches can be labelled using uid (unique id generated by UBCG pipeline), acc (accession number), label (full label of the strain/genome), taxon, strain, type or taxonomy. To do so, these metadata must be included in 'metadata.csv' file and specified in the script (see the script above: including more metadata) during generating the ‘ucg’ files from the genome sequences.
>
    
 
The metadata are recorded under the 'genome_info' section of the 'ucg' files. See an example below:



<p align="center">
  <img 
    width="850"
    height="500"
    src="https://github.com/asadprodhan/Bacterial-phylogenetic-tree-reconstruction-using-UBCG-pipeline/blob/main/ucg_genome_info.png"
  >
<p align = "center">
Fig. An example of UCG file with metadata
</p>




## **How to reconstruct MrBayes phylogenetic tree using the UBCG core genes**


**Step 1: Collect the concatenated alignment of the core genes (aligned_concatenated.fasta) from the UBCG output directory**


**Step 2: Convert it to nexus file**


**Step 3: Then prepare an input file as follows and save it with ‘mrbayes’ extension**



```

#NEXUS
BEGIN DATA;
dimensions ntax=5 nchar=17804;
format datatype=dna missing=? gap=-;
	matrix
	sample_A	ATGAATAAATGATTATATTCTACTAAT …….	
sample_B           ATGAATAAATGATTATATTCTACTAATCACAA …..

;
end;
BEGIN mrbayes;
lset nst=6 rates=invgamma; 
propset ExtTBR$prob=0; 
mcmc ngen=50000000 printfreq=100 samplefreq=1000 diagnfreq=1000 nchains=4 savebrlens=yes;
sumt burnin=12500;
sump burnin=12500;
END;

```


## **Notes:**


> sumt or sump is calculated as  = (number of generations/sample frequency)/4 


> ‘4’ represents 25%


> Though the file has Windows file ending, MrBayes program doesn’t require dos2linux conversion


- “lset nst=6 rates=invgamma” sets a nucleotide substitution model called “GTR + I + G” 
The usage of maximum likelihood method in phylogenetic analysis requires a nucleotide substitution model such as “GTR + I + G”. “GTR + I + G” is a widely used General Time Reversible (GTR) nucleotide substitution model with gamma-distributed rate variation across sites (G) and a proportion of invariable sites (I).  The invariable sites account for the static, unchanging sites in a dataset. 



- “ngen” is the number of generations for which the analysis will be run


- “printfreq” controls the frequency with which brief info about the analysis is printed to screen. The default value is 1,000


- “samplefreq” determines how often the chain is sampled; the default is every 500 generations


- diagnostics calculated every “diagnfreq” generation


- By default, MrBayes uses Metropolis coupling to improve the MCMC sampling of the target distribution. The Swapfreq, Nswaps, Nchains, and Temp settings together control the Metropolis coupling behavior. When Nchains is set to 1, no heating is used. When Nchains is set to a value n larger than 1, then n−1 heated chains are used. By default, Nchains is set to 4, meaning that MrBayes will use 3 heated chains and one “cold” chain


- “sumt” summarises statistics and creates five additional files


- “sump” summarises the parameter values


- Every time the diagnostics are calculated, either a fixed number of samples (burnin) or a percentage of samples (burninfrac) from the beginning of the chain is discarded



**Step 4: Write a simialr bash script as follows to run MrBayes on a HPC cluster:**


```
#!/bin/bash
#SBATCH --account=XXXX
#SBATCH --partition=workq
#SBATCH --time=24:00:00
#SBATCH --nodes=4
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=12
#SBATCH --export=NONE
. /etc/bash.bashrc

module unload PrgEnv-cray
module unload cray-mpich2
module load PrgEnv-gnu
module load cray-mpich

module list

export OMP_NUM_THREADS=1

# Input file location
cd /xxx/xxx/xxx/TreeTesting

# Command line
srun -n 8 /path_to_MrBayes/bin/mb InputFile.mrbayes

```



> In the above command line, purple is the location of the software executable; green is the input file that is keep in “in the /xxx/xxx/xxx/TreeTesting”


**Step 5: sbatch the above bash script**


**Step 6: Once the MrBayes run completed, it generates the following output files:**



<br />
<p align="center">
  <img 
    src="https://github.com/asadprodhan/Bacterial-phylogenetic-tree-reconstruction-using-UBCG-pipeline/blob/main/MrBayes_output_files.png"
  >
</p>
<p align = "center">
Fig. MrBayes ourput files.
</p>





- The output file with ‘.p’ extension is called a tracer file and can be visualised in ‘Tracer’ 1


- The output file with ‘.con.tre’ extension is the file to be used to construct the tree. ‘FigTree’ can process this file, construct the tree and label the nodes with the probability values



## **What if your run gets timeout?**



If run time ends before completing the phylogenetic tree, then:


- Add “append=yes” as follows in your input file:


```
mcmc ngen=50000000 append=yes printfreq=100 samplefreq=1000 diagnfreq=1000 nchains=4 savebrlens=yes;
```


- sbatch the above bash script again



<br />
<p align="center">
  <img 
    src="https://github.com/asadprodhan/Bacterial-phylogenetic-tree-reconstruction-using-UBCG-pipeline/blob/main/WhatHappensWhenAppend_v2.PNG"
  >
</p>
<p align = "center">
Fig. What happens when you append 'yes'.
</p>




## **What happens if you put “append=yes” in the initial run:**



You get the following error messages: 


- Could not open file "XXXXX.ckp"


- Could not find the checkpoint file XXXXX.mrbayes.ckp'.


- Make sure it is in the working directory.


- Error in command "Mcmc"


- There was an error on at least one processor


- The error occurred when reading char. 100-100 on line 65 in the file 'Tree51_97_Edit.mrbayes' 



## **References**

1.	Na, S.-I. et al. UBCG: Up-to-date bacterial core gene set and pipeline for phylogenomic tree reconstruction. J Microbiol. 56, 280–285 (2018).
2.	Kim, J., Na, S.-I., Kim, D. & Chun, J. UBCG2: Up-to-date bacterial core genes and pipeline for phylogenomic analysis. J Microbiol. 59, 609–615 (2021).





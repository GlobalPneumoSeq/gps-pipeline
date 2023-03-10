# GPS Unified Pipeline <!-- omit in toc -->

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-22.10.4-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

The GPS Unified Pipeline is a Nextflow pipeline designed for processing raw reads (FASTQ files) of *Streptococcus pneumoniae* samples. The pipeline assesses the quality of the reads based on assembly, mapping, and taxonomy. If the sample passes all quality controls (QC), the pipeline also provides the sample's serotype, multi-locus sequence typing (MLST), lineage (based on the [Global Pneumococcal Sequence Cluster (GPSC)](https://www.pneumogen.net/gps/GPSC_lineages.html)), and antimicrobial resistance (AMR) against multiple antimicrobials.

The pipeline is designed to be easy to set up and use, and is suitable for use on local machines. It is also offline-capable, making it an ideal option for cases where the FASTQ files being analysed should not leave the local machine. Additionally, the pipeline only downloads essential files to enable the analysis, and no data is uploaded from the local machine. After initialisation or the first successful complete run, the pipeline can be used offline unless any pipeline option is changed.

The development of this pipeline is part of the GPS Project ([Global Pneumococcal Sequencing Project](https://www.pneumogen.net/gps/)). 

&nbsp;
# Table of contents <!-- omit in toc -->
- [Workflow](#workflow)
- [Usage](#usage)
  - [Requirement](#requirement)
  - [Accepted Inputs](#accepted-inputs)
  - [Setup](#setup)
  - [Run](#run)
  - [Resume](#resume)
  - [Clean Up](#clean-up)
- [Pipeline Options](#pipeline-options)
  - [Alternative Workflows](#alternative-workflows)
  - [Input and Ouput](#input-and-ouput)
  - [QC Parameters](#qc-parameters)
  - [Assembly](#assembly)
  - [Mapping](#mapping)
  - [Taxonomy](#taxonomy)
  - [Serotype](#serotype)
  - [Lineage](#lineage)
- [Output](#output)
  - [Output Content](#output-content)
  - [Details of `summary.csv`](#details-of-summarycsv)
- [Credits](#credits)


&nbsp;
# Workflow
![Workflow](doc/workflow.drawio.svg)

&nbsp;
# Usage
## Requirement
- A POSIX-compatible system (e.g. Linux, macOS, Windows with [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux))
- Java 11 or later (up to 18) ([OpenJDK](https://openjdk.org/)/[Oracle Java](https://www.oracle.com/java/))
- [Docker](https://www.docker.com/)
- It is recommended to have at least 16GB of RAM and 100GB of free storage
## Accepted Inputs
- Currently, only Illumina paired-end short reads are supported
- Each sample is expected to be a pair of raw reads following this file name pattern: 
  - `*_{,R}{1,2}{,_001}.{fq,fastq}{,.gz}` 
    - example 1: `SampleName_R1_001.fastq.gz`, `SampleName_R2_001.fastq.gz`
    - example 2: `SampleName_1.fastq.gz`, `SampleName_2.fastq.gz`
    - example 3: `SampleName_R1.fq`, `SampleName_R2.fq`
## Setup 
1. Clone the repository (if Git is installed on your system)
    ```
    git clone https://github.com/HarryHung/gps-unified-pipeline.git
    ```
    or 
    
    Download and unzip the [repository](https://github.com/HarryHung/gps-unified-pipeline/archive/refs/heads/master.zip)
2. Go into the local copy of the repository
    ```
    cd gps-unified-pipeline
    ```
3. (Optional) You could perform an initialisation to download all required additional files and Docker images, so the pipeline can be used at any time with or without the Internet afterward.
   > ⚠️ Docker Desktop / Engine must be running, and an Internet connection is required.
    ```
    ./run_pipeline --init
    ```

## Run
> ⚠️ Docker Desktop / Engine must be running. An Internet connection is required for the first run (if initialisation was not performed).
- You can run the pipeline without options. It will attempt to get the raw reads from the default location (`input` directory inside the `gps-unified-pipeline` local repository)
  ```
  ./run_pipeline
  ```
- You can also specify the location of the raw reads by adding the `--reads` option
  ```
  ./run_pipeline --reads /path/to/raw-reads-directory
  ```
- For a test run, you could use the included test reads in the `test_input` directory
  ```
  ./run_pipeline --reads test_input
  ```
  - `9870_5#52` will fail the Taxonomy QC and hence Overall QC, therefore without analysis results
  - `17175_7#59` and `21127_1#156` should pass Overall QC, therefore with analysis results

## Resume
- If the pipeline is interrupted mid-run, Nextflow's built-in `-resume` option can be used to resume the pipeline execution instead of starting from scratch again
- You should use the same command of the original run, only add `-resume` at the end (i.e. all pipeline options should be identical) 
  > ℹ️ Nextflow options only have one leading `-`, instead of `--` of pipeline options
  ```
  # original command
  ./run_pipeline --reads /path/to/raw-reads-directory

  # command to resume the pipeline execution
  ./run_pipeline --reads /path/to/raw-reads-directory -resume
  ```

## Clean Up
- During the run of the pipeline, Nextflow generates a considerable amount of intermediate files
- If the run has been completed and you do not intend to use the `-resume` option, you can remove the intermediate files by one of following two ways:
  - Manual removal - remove the `work` directory within the `gps-unified-pipeline` local repository
    ```
    rm -rf work
    ```
  - `nextflow clean` command - use this built-in command to clean up cache and work directories  (default: the latest run only)
    ```
    ./nextflow clean
    ```
    For options of `nextflow clean`, refer to the [Nextflow documentation](https://www.nextflow.io/docs/latest/cli.html#clean)
    
&nbsp;
# Pipeline Options
- The tables below contains the available options that can be used when you run the pipeline
- Usage:
  ```
  ./run_pipeline [option] [value]
  ```
- To permanently change the value of an option, edit the `nextflow.config` file inside the `gps-unified-pipeline` local repository.
> ℹ️ `$projectDir` is the directory where the `gps-unified-pipeline` local repository is stored, it is a [Nextflow built-in implicit variables](https://www.nextflow.io/docs/latest/script.html?highlight=projectdir#implicit-variables).

## Alternative Workflows
  | Option | Values | Description |
  | --- | ---| --- |
  | `--init` | `true` or `false`<br />(Default: `false`) | Use alternative workflow for initialisation.<br />Can be enabled by including `--init` without value. |
  | `--version` | `true` or `false`<br />(Default: `false`)| Use alternative workflow for getting versions of pipeline, tools and databases.<br />Can be enabled by including `--version` without value. |
  | `--help` | `true` or `false`<br />(Default: `false`)| Show help message.<br />Can be enabled by including `--help` without value. |

## Input and Ouput
  | Option | Values | Description |
  | --- | ---| --- |
  | `--reads` | Any valid path<br />(Default: `"$projectDir/input"`) | Path to the input directory that contains the reads to be processed. |
  | `--output` | Any valid path<br />(Default: `"$projectDir/output"`)| Path to the output directory that save the results. |

## QC Parameters
  | Option | Values | Description |
  | --- | ---| --- |
  | `--spneumo_percentage` | Any integer or float value<br />(Default: `60.00`) | Minimum *S. pneumoniae* percentage in reads to pass Taxonomy QC. |
  | `--ref_coverage` | Any integer or float value<br />(Default: `60.00`) | Minimum reference coverage percentage by the reads to pass Mapping QC. |
  | `--het_snp_site` | Any integer value<br />(Default: `220`) | Maximum non-cluster heterozygous SNP (Het-SNP) site count to pass Mapping QC. |
  | `--contigs` | Any integer value<br />(Default: `500`) | Maximum contig count in assembly to pass Assembly QC. |
  | `--length_low` | Any integer value<br />(Default: `1900000`) | Minimum assembly length to pass Assembly QC. |
  | `--length_high` | Any integer value<br />(Default: `2300000`) | Maximum assembly length to pass Assembly QC. |
  | `--depth` | Any integer or float value<br />(Default: `20.00`) | Minimum sequencing depth to pass Assembly QC. |
  
## Assembly
  | Option | Values | Description |
  | --- | ---| --- |
  | `--assembler` | `"shovill"` or `"unicycler"`<br />(Default: `"shovill"`)| SPAdes Assembler to assembly the reads. |

## Mapping
  | Option | Values | Description |
  | --- | ---| --- |
  | `--ref_genome` | Any valid path to a `.fa` or `.fasta` file<br />(Default: `"$projectDir/data/ATCC_700669_v1.fa"`) | Path to the reference genome for mapping. |
  | `--ref_genome_bwa_db_local` | Any valid path<br />(Default: `"$projectDir/bin/bwa_ref_db"`) | Path to the directory where the reference genome FM-index database for BWA should be saved to. |

## Taxonomy 
  | Option | Values | Description |
  | --- | ---| --- |
  | `--kraken2_db_remote` | Any valid URL to a Kraken2 database in `.tar.gz` format<br />(Default: [Kraken 2 RefSeq Index Standard-8 (2022-09-12)](https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20220926.tar.gz)) | URL to a Kraken2 database. |
  | `--kraken2_db_local` | Any valid path<br />(Default: `"$projectDir/bin/kraken"`) | Path to the directory where the remote Kraken2 database should be saved to. |
  | `--kraken2_memory_mapping` | `true` or `false`<br />(Default: `true`) | Using the memory mapping option of Kraken2 or not.<br />`true` means not loading the database into RAM, suitable for memory-limited or fast storage environments. |

## Serotype
  | Option | Values | Description |
  | --- | ---| --- |
  | `--seroba_remote` | Any valid URL to a Git remote repository<br />(Default: [SeroBA GitHub Repo](https://github.com/sanger-pathogens/seroba.git))| URL to a SeroBA Git remote repository. |
  | `--seroba_local` | Any valid path<br />(Default: `"$projectDir/bin/seroba"`) | Path to the directory where SeroBA local repository should be saved to. |
  | `--seroba_kmer` | Any integer value<br />(Default: `71`) | Kmer size for creating the KMC database of SeroBA. |

## Lineage
  | Option | Values | Description |
  | --- | ---| --- |
  | `--poppunk_db_remote` | Any valid URL to a PopPUNK database in `.tar.gz` format<br />(Default: [GPS v6](https://gps-project.cog.sanger.ac.uk/GPS_v6.tar.gz)) | URL to a PopPUNK database. |
  | `--poppunk_ext_remote` | Any valid URL to a PopPUNK external clusters file in `.csv` format<br />(Default: [GPS v6 GPSC Designation](https://www.pneumogen.net/gps/GPS_v6_external_clusters.csv)) | URL to a PopPUNK external clusters file. |
  | `--poppunk_local` | Any valid path<br />(Default: `"$projectDir/bin/poppunk"`) | Path to the directory where the remote PopPUNK database and external clusters file should be saved to. |


&nbsp;
# Output
- By default, the pipeline outputs the results into the `output` directory inside the `gps-unified-pipeline` local repository
- It can be changed by adding the option `--output`
  ```
  ./run_pipeline --output /path/to/output-directory
  ```
## Output Content  
- The following directories and files are output into the output directory
  | Directory / File | Description |
  | --- | ---|
  | `assemblies` | This directory contains all assemblies (`.fasta`) generated by the pipeline |
  | `summary.csv` | This file contains all the information generated by the pipeline on each sample |
  | `info.txt` | This file contains information regarding the pipeline and parameters of the run |

## Details of `summary.csv`
- The following fields can be found in the output `summary.csv`
  | Field | Type | Description |
  | --- | --- | --- |
  | `Sample_ID` | Identification | Sample ID based on the raw reads file name |
  | `Contigs#` | Assembly | Number of contigs in the assembly; < 500 to pass QC |
  | `Assembly_Length` | Assembly | Total length of the assembly; 1.9 - 2.3 Mb to pass QC |
  | `Seq_Depth` | Assembly | Sequencing depth of the assembly; ≥ 20x to pass QC |
  | `Assembly_QC` | QC | Assembly quality control result |
  | `Ref_Cov_%` | Mapping | Percentage of reference covered by reads; > 60% to pass QC |
  | `Het-SNP#` | Mapping | Non-cluster heterozygous SNP (Het-SNP) site count; < 220 to pass QC |
  | `Mapping_QC` | QC | Mapping quality control result |
  | `S.Pneumo_%` | Taxonomy | Percentage of reads assigned to *Streptococcus pneumoniae*; > 60% to pass QC |
  | `Taxonomy_QC` | QC | Taxonomy quality control result  |
  | `Overall_QC` | QC | Overall quality control result; Based on `Assembly_QC`, `Mapping_QC` and `Taxonomy_QC` |
  | `GPSC` | Lineage | GPSC Lineage |
  | `Serotype` | Serotype | Serotype |
  | `SeroBA_Comment` | Serotype | (if any) SeroBA comment on serotype assignment |
  | `ST` | MLST | Sequence Type (ST) |
  | `aroE` | MLST | Allele ID of aroE |
  | `gdh` | MLST | Allele ID of gdh |
  | `gki` | MLST | Allele ID of gki |
  | `recP` | MLST | Allele ID of recP |
  | `spi` | MLST | Allele ID of spi |
  | `xpt` | MLST | Allele ID of xpt |
  | `ddl` | MLST | Allele ID of ddl |
  | `pbp1a` | PBP AMR | Allele ID of pbp1a |
  | `pbp2b` | PBP AMR | Allele ID of pbp2b |
  | `pbp2x` | PBP AMR | Allele ID of pbp2x |
  | `AMX_MIC` | PBP AMR | Estimated minimum inhibitory concentration (MIC) of amoxicillin (AMX) |
  | `AMX_Res` | PBP AMR | Resistance phenotype against AMX |
  | `CRO_MIC` | PBP AMR | Estimated MIC of ceftriaxone (CRO) |
  | `CRO_Res(Non-meningital)` | PBP AMR | Resistance phenotype against CRO in non-meningital form |
  | `CRO_Res(Meningital)` | PBP AMR | Resistance phenotype against CRO in meningital form |
  | `CTX_MIC` | PBP AMR | Estimated MIC of cefotaxime (CTX) |
  | `CTX_Res(Non-meningital)` | PBP AMR | Resistance phenotype against CTX in non-meningital form |
  | `CTX_Res(Meningital)` | PBP AMR | Resistance phenotype against CTX in meningital form |
  | `CXM_MIC` | PBP AMR | Estimated MIC of cefuroxime (CXM) |
  | `CXM_Res` | PBP AMR | Resistance phenotype against CXM |
  | `MEM_MIC` | PBP AMR | Estimated MIC of meropenem (MEM) |
  | `MEM_Res` | PBP AMR | Resistance phenotype against MEM |
  | `PEN_MIC` | PBP AMR | Estimated MIC of penicillin (PEN) |
  | `PEN_Res(Non-meningital)` | PBP AMR | Resistance phenotype against PEN in non-meningital form |
  | `PEN_Res(Meningital)` | PBP AMR | Resistance phenotype against PEN in meningital form |
  | `CHL_Res` | Other AMR | Inferred resistance against Chloramphenicol (CHL) |
  | `CHL_Determinant` | Other AMR | Known determinants that inferred the CHL resistance |
  | `CLI_Res` | Other AMR | Inferred resistance against Clindamycin (CLI) |
  | `CLI_Determinant` | Other AMR | Known determinants that inferred the CLI resistance |
  | `ERY_Res` | Other AMR | Inferred resistance against Erythromycin (ERY) |
  | `ERY_Determinant` | Other AMR | Known determinants that inferred the ERY resistance |
  | `FLQ_Res` | Other AMR | Inferred resistance against Fluoroquinolones (FLQ) |
  | `FLQ_Determinant` | Other AMR | Known determinants that inferred the FLQ resistance |
  | `KAN_Res` | Other AMR | Inferred resistance against Kanamycin (KAN) |
  | `KAN_Determinant` | Other AMR | Known determinants that inferred the KAN resistance |
  | `LNZ_Res` | Other AMR | Inferred resistance against Linezolid (LNZ) |
  | `LNZ_Determinant` | Other AMR | Known determinants that inferred the LNZ resistance |
  | `TCY_Res` | Other AMR | Inferred resistance against Tetracycline (TCY) |
  | `TCY_Determinant` | Other AMR | Known determinants that inferred the TCY resistance |
  | `TMP_Res` | Other AMR | Inferred resistance against Trimethoprim (TMP) |
  | `TMP_Determinant` | Other AMR | Known determinants that inferred the TMP resistance |
  | `SSS_Res` | Other AMR | Inferred resistance against Sulfamethoxazole (SSS) |
  | `SSS_Determinant` | Other AMR | Known determinants that inferred the SSS resistance |
  | `SXT_Res` | Other AMR | Inferred resistance against Co-Trimoxazole (SXT) |
  | `SXT_Determinant` | Other AMR | Known determinants that inferred the SXT resistance |

&nbsp;
# Credits
This project uses open-source components. You can find the homepage or source code of their open-source projects along with license information below. I acknowledge and am grateful to these developers for their contributions to open source.

[AMRsearch](https://github.com/pathogenwatch-oss/amr-search)
- [Pathogenwatch](https://pathogen.watch/) ([@pathogenwatch-oss](https://github.com/pathogenwatch-oss))
- License (MIT): https://github.com/pathogenwatch-oss/amr-search/blob/main/LICENSE
- This project uses a Docker image built from a [custom fork](https://github.com/HarryHung/amr-search)
  - The fork changes the Docker image from a Docker executable image to a Docker environment for Nextflow integration
  - The Docker image provides the containerised environment for `OTHER_RESISTANCE` process of the `amr.nf` module 

[BCFtools](https://samtools.github.io/bcftools/) and [SAMtools](https://www.htslib.org/)
- Twelve years of SAMtools and BCFtools. Petr Danecek, James K Bonfield, Jennifer Liddle, John Marshall, Valeriu Ohan, Martin O Pollard, Andrew Whitwham, Thomas Keane, Shane A McCarthy, Robert M Davies, Heng Li. **GigaScience**, Volume 10, Issue 2, February 2021, giab008, https://doi.org/10.1093/gigascience/giab008
- Licenses
  - BCFtools (MIT/Expat or GPL-3.0): https://github.com/samtools/bcftools/blob/develop/LICENSE
  - SAMtools (MIT/Expat): https://github.com/samtools/samtools/blob/develop/LICENSE
- These tools are used in `SAM_TO_SORTED_BAM`, `REF_COVERAGE` and `SNP_CALL` processes of the `mapping.nf` module

[BWA](https://github.com/lh3/bwa)
- Li H. (2013) Aligning sequence reads, clone sequences and assembly contigs with BWA-MEM. [arXiv:1303.3997v2](http://arxiv.org/abs/1303.3997) [q-bio.GN]
- License (GPL-3.0): https://github.com/lh3/bwa/blob/master/COPYING
- This tool is used in `GET_REF_GENOME_BWA_DB_PREFIX` and `MAPPING` processes of the `mapping.nf` module

[Docker Images](https://hub.docker.com/u/staphb) of [BCFtools](https://hub.docker.com/r/staphb/bcftools), [BWA](https://hub.docker.com/r/staphb/bwa), [fastp](https://hub.docker.com/r/staphb/fastp), [Kraken 2](https://hub.docker.com/r/staphb/kraken2), [mlst](https://hub.docker.com/r/staphb/mlst), [PopPUNK](https://hub.docker.com/r/staphb/poppunk), [QUAST](https://hub.docker.com/r/staphb/quast), [SAMtools](https://hub.docker.com/r/staphb/samtools), [SeroBA](https://hub.docker.com/r/staphb/seroba), [Shovill](https://hub.docker.com/r/staphb/shovill), [Unicycler](https://hub.docker.com/r/staphb/unicycler) 
- [State Public Health Bioinformatics Workgroup](https://staphb.org/) ([@StaPH-B](https://github.com/StaPH-B))
- License (GPL-3.0): https://github.com/StaPH-B/docker-builds/blob/master/LICENSE
- These Docker images provide containerised environments for processes of multiple modules 

[Docker Image of Git](https://hub.docker.com/r/bitnami/git)
- [Bitnami](https://bitnami.com/) ([@Bitnami](https://github.com/bitnami))
- License (Apache 2.0): https://github.com/bitnami/containers/blob/main/LICENSE.md
- This Docker image provides the containerised environment for `GET_SEROBA_DB` process of the `serotype.nf` module

[Docker Image of network-multitool](https://hub.docker.com/r/wbitt/network-multitool)
- [Wbitt - We Bring In Tomorrow's Technolgies](https://wbitt.com/) ([@WBITT](https://github.com/wbitt))
- License (MIT): https://github.com/wbitt/Network-MultiTool/blob/master/LICENSE
- This Docker image provides the containerised environment for processes of multiple modules 

[Docker Image of Python](https://hub.docker.com/_/python)
- The Docker Community ([@docker-library](https://github.com/docker-library))
- License (MIT): https://github.com/docker-library/python/blob/master/LICENSE
- This Docker image provides the containerised environment for `HET_SNP_COUNT` process of the `mapping.nf` module 

[fastp](https://github.com/OpenGene/fastp)
- Shifu Chen, Yanqing Zhou, Yaru Chen, Jia Gu; fastp: an ultra-fast all-in-one FASTQ preprocessor, Bioinformatics, Volume 34, Issue 17, 1 September 2018, Pages i884–i890, https://doi.org/10.1093/bioinformatics/bty560
- License (MIT): https://github.com/OpenGene/fastp/blob/master/LICENSE
- This tool is used in `PREPROCESS` process of the `preprocess.nf` module

[GPSC_pipeline_nf](https://github.com/sanger-bentley-group/GPSC_pipeline_nf)
- Victoria Carr ([@blue-moon22](https://github.com/blue-moon22))
- License (GPL-3.0): https://github.com/sanger-bentley-group/GPSC_pipeline_nf/blob/master/LICENSE
- Code adapted into `LINEAGE` process of the `lineage.nf` module

[Kraken 2](https://ccb.jhu.edu/software/kraken2/)
- Wood, D.E., Lu, J. & Langmead, B. Improved metagenomic analysis with Kraken 2. Genome Biol 20, 257 (2019). https://doi.org/10.1186/s13059-019-1891-0
- License (MIT): https://github.com/DerrickWood/kraken2/blob/master/LICENSE
- This tool is used in `TAXONOMY` process of the `taxonomy.nf` module

[mecA-HetSites-calculator](https://github.com/kumarnaren/mecA-HetSites-calculator) 
- Narender Kumar ([@kumarnaren](https://github.com/kumarnaren))
- License (GPL-3.0): https://github.com/kumarnaren/mecA-HetSites-calculator/blob/master/LICENSE
- Code was rewritten into `HET_SNP_COUNT` process of the `mapping.nf` module

[mlst](https://github.com/tseemann/mlst)
- Torsten Seemann ([@tseemann](https://github.com/tseemann))
- License (GPL-2.0): https://github.com/tseemann/mlst/blob/master/LICENSE
- Incorporates components of the [PubMLST database](https://pubmlst.org/terms-conditions)
- This tool is used in `MLST` process of the `mlst.nf` module

[Nextflow](https://www.nextflow.io/)
- P. Di Tommaso, et al. Nextflow enables reproducible computational workflows. Nature Biotechnology 35, 316–319 (2017) doi:[10.1038/nbt.3820](http://www.nature.com/nbt/journal/v35/n4/full/nbt.3820.html)
- License (Apache 2.0): https://github.com/nextflow-io/nextflow/blob/master/COPYING
- This project is a Nextflow pipeline; Nextflow executable `nextflow` is included in this repository

[PopPUNK](https://poppunk.readthedocs.io/)
- Lees JA, Harris SR, Tonkin-Hill G, Gladstone RA, Lo SW, Weiser JN, Corander J, Bentley SD, Croucher NJ. Fast and flexible bacterial genomic epidemiology with PopPUNK. *Genome Research* **29**:1-13 (2019). doi:[10.1101/gr.241455.118](https://dx.doi.org/10.1101/gr.241455.118)
- License (Apache 2.0): https://github.com/bacpop/PopPUNK/blob/master/LICENSE
- This tool is used in `LINEAGE` process of the `lineage.nf` module

[QUAST](https://quast.sourceforge.net/)
- Alla Mikheenko, Andrey Prjibelski, Vladislav Saveliev, Dmitry Antipov, Alexey Gurevich, Versatile genome assembly evaluation with QUAST-LG, *Bioinformatics* (2018) 34 (13): i142-i150. doi: [10.1093/bioinformatics/bty266](https://doi.org/10.1093/bioinformatics/bty266). First published online: June 27, 2018
- License (GPL-2.0): https://github.com/ablab/quast/blob/master/LICENSE.txt
- This tool is used in `ASSEMBLY_ASSESS` process of the `assembly.nf` module

[SeroBA](https://sanger-pathogens.github.io/seroba/)
- **SeroBA: rapid high-throughput serotyping of Streptococcus pneumoniae from whole genome sequence data**. Epping L, van Tonder, AJ, Gladstone RA, GPS Consortium, Bentley SD, Page AJ, Keane JA, Microbial Genomics 2018, doi: [10.1099/mgen.0.000186](http://mgen.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000186)
- License (GPL-3.0): https://github.com/sanger-pathogens/seroba/blob/master/LICENSE
- This tool is used in `CREATE_SEROBA_DB` and `SEROTYPE` processes of the `serotype.nf` module

[Shovill](https://github.com/tseemann/shovill)
- Torsten Seemann ([@tseemann](https://github.com/tseemann))
- License (GPL-3.0): https://github.com/tseemann/shovill/blob/master/LICENSE
- This tool is used in `ASSEMBLY_SHOVILL` process of the `assembly.nf` module

[SPN-PBP-AMR](https://cgps.gitbook.io/pathogenwatch/technical-descriptions/antimicrobial-resistance-prediction/spn-pbp-amr)
- [Pathogenwatch](https://pathogen.watch/) ([@pathogenwatch-oss](https://github.com/pathogenwatch-oss))
- License (MIT): https://github.com/pathogenwatch-oss/spn-resistance-pbp/blob/main/LICENSE
- This is a modified version of [AMR predictor](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference) by Ben Metcalf ([@BenJamesMetcalf](https://github.com/BenJamesMetcalf)) at the Centre for Disease Control (CDC)
- This project uses a Docker image built from a [custom fork](https://github.com/HarryHung/spn-resistance-pbp)
  - The fork changes the Docker image from a Docker executable image to a Docker environment for Nextflow integration
  - The Docker image provides the containerised environment for `PBP_RESISTANCE` process of the `amr.nf` module 

[Unicycler](https://github.com/rrwick/Unicycler)
- **Wick RR, Judd LM, Gorrie CL, Holt KE**. Unicycler: resolving bacterial genome assemblies from short and long sequencing reads. *PLoS Comput Biol* 2017.
- License (GPL-3.0): https://github.com/rrwick/Unicycler/blob/main/LICENSE
- This tool is used in `ASSEMBLY_UNICYCLER` process of the `assembly.nf` module
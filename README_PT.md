
<!-- README.md is generated from README.Rmd. Please edit that file -->
microdadosBrasil
================

Trabalho em andamento
---------------------

### NOVIDADES:

-   Censo 2010
-   RAIS
-   CAGED
-   PME

-   Não usa R? Veja: [using the package from Stata and Python](https://github.com/lucasmation/microdadosBrasil/blob/master/vignettes/Running_from_other_software.Rmd)

### EM BREVE:

-   Suporte para leitura de dados fora da memória RAM
-   Harmonização do nome de variáveis ao longo dos anos

DESCRIÇÃO
---------

this package contains functions to read most commonly used Brazilian microdata easily and quickly. Importing Brazilian microdata can be tedious. Most data is provided in fixed width files (fwf) with import instructions only for SAS and SPSS. Data usually comes subdivided by state (UF) or macro regions (regiões). Also, filenames can vary, for the same dataset overtime. `microdadoBrasil` handles all these idiosyncrasies for you. In the background the package is running `readr` for fwf data and `data.table` for .csv data. Therefore reading is reasonably fast.

Esse pacote disponibiliza funções para importar as bases brasileiras de microdados mais comuns. Importar microdados brasileiros pode ser tedioso. A maior parte dos dados é disponibilizada em fixed width files(.fwf) e contém, geralmente, scripts para importação somente para SAS e SPSS. Os dados vem, usualmente, divididos por UF ou Região. Além disso, nomes de arquivos e variáveis variam com frequência ao longo do tempo. `microdadoBrasil` cuida desses detalhes pra você. Internamente o pacote está rodando `readr` para fixed width files e `data.table` para dados separados por delimitadores e armazenados em .csv. Assim, a importação é rápida.

Currently the package includes import functions for:

Atualmente, o pacote inclui funções de importação para as seguintes bases de dados:

| Fonte | Dataset                 | Função                      | Período      | Subdataset                |
|:------|:------------------------|:----------------------------|:-------------|:--------------------------|
| IBGE  | PNAD                    | read\_PNAD                  | 2001 to 2014 | domicilios, pessoas       |
| IBGE  | Censo Demográfico       | read\_CENSO                 | 2000 e 2010  | domicilios, pessoas       |
| IBGE  | POF                     | read\_POF                   | 2008         | several, see details      |
| INEP  | Censo Escolar           | read\_CensoEscolar          | 1995 to 2014 | escolas, ..., see detials |
| INEP  | Censo da Educ. Superior | read\_CensoEducacaoSuperior | 1995 to 2014 | see details               |

The package includes internally a list of import dictionaries for each dataset-subdataset-year. These were constructed with the `import_SASdictionary` function, which users can use to import dictionaries from datasets not included here. Import dictionaries for the datasets included in the package can be accessed with the `get_import_dictionary` function.

O pacote inclui dicionários para cada base de dados. Esses dicionários foram criados com a função `import_SASdictionary()`, que pode ser utilizado pelo usuário para construir, a partir de um dicionário SAS, dicionários não incluídos no pacote. Dicionário incluídos no pacote podem ser acessados com a função `get_import_dictionary`.

The package also harmonizes folder names, folder structure and file name that change overtime through a metadata table.It also unifies data that comes subdivides by regional subgroups (UF or região) into a single data file.

O pacote também harmoniza nomes de arquivos e a estrutura das pastas ao longo tempo, através de uma tabela de metadatas, tornando possível a importação de bases de dados que usualmente vem dividadas em subgroupos regionais em um único objeto(?). \#\# INSTALAÇÃO

``` r
install.packages("devtools")
install.packages("stringi") 
devtools::install_github("lucasmation/microdadosBrasil")
library('microdadosBrasil')
```

UTILIZAÇÃO
----------

``` r
# Censo Demográfico 2000
#Depois de ter baixado e descompactado os arquivos em seu diretório de trabalho , rode:
d <- read_CENSO('domicilios',2000)
d <- read_CENSO('pessoas',2000)

#Para importar os dados a partir de uma pasta diferente de seu atual diretório de trabalho, use :
d <- read_CENSO('domicilios',2000, root_path ="C:/....")
#Para restringir a importação para apenas uma UF, use:
d <- read_CENSO('pessoas',2000, UF = "DF")

# PNAD 2002
download_sourceData("PNAD", 2002, unzip = T)
d  <- read_PNAD("domicilios", 2002)
d2 <- read_PNAD("pessoas", 2002)

# Censo Escolar
download_sourceData('CensoEscolar', 2005, unzip=T)
d <- read_CensoEscolar('escola',2005)
d <- read_CensoEscolar('escola',2005,harmonize_varnames=T)
```

ESFORÇOS RELACIONADOS
---------------------

This package is highly influenced by similar efforts, which are great time savers, vastly used and often unrecognized:

Esse pacote foi altamente influenciado por esforços similares, que são grande poupadores de tempo, muito utilizados e, algumas vezes, não reconhecidos:

-   Anthony Damico's [scripts to read most IBGE surveys](http://www.asdfree.com/). Great if you your data does not fit into memory and you want speed when working with complex survey design data.
-   [Data Zoom](http://www.econ.puc-rio.br/datazoom/) by Gustavo Gonzaga, Cláudio Ferraz and Juliano Assunção. Similar ease of use and harmonization of Brazilian microdada for Stata.
-   [dicionariosIBGE](https://cran.r-project.org/web/packages/dicionariosIBGE/index.html), by Alexandre Rademaker. A set of data.frames containing the information from SAS import dictionaries for IBGE datasets.
-   [IPUMS](https://international.ipums.org/international/). Harmonization of Census data from several countries, including Brasil. Import functions for R, Stata, SAS and SPSS.

`microdadosBrasil` differs from those packages in that it:

-   updates import functions to more recent years
-   includes non-IBGE data, such as INEP Education Census and MTE RAIS (de-identified)
-   separates import code from dataset specific metadata, as explained bellow.

`microdadosBrasil` Se diferencia de outros pacotes por:

-   Trazer opções de importação para períodos mais recentes
-   Incluir dados de outras fontes, além do IBGE, como o Censo Escolar do INEP
-   Separar código pra importação e os metadados específicos de cada base de dados, como exeplicado abaixo:

COMO O PACOTE FUNCIONA
----------------------

### Traditional Import Workflow

Nowadays packages are normally provided on-line (or in a physical CD for the older IBGE publications) as .zip files with the following structure:

Atualmente, mircrodados são normalmente disponibilizados on-line(Ou em CDs, no caso das publicações mais antigas do IBGE) com arquivos compactados em .zip, seguindo a seguinte estrutura:

dataset\_year.zip

-   dataset\_year
    -   DICTIONARIES
        -   import\_dictionary\_subdatasetA.SAS
    -   DATA
        -   subdatasetA\_state1.txt
        -   subdatasetA\_state2.txt
        -   ...
        -   subdatasetA\_stateN.txt
    -   ADITIONAL DOCUMENTATION
        -   subdatasetA\_variables\_and\_cathegories\_dictionary.xls

Users then normally manually reconstruct the import dictionaries in R by hand. Then, using this dictionary, run the import function, pointing to the DATA folder. Larger datasets (such as CENSUS or RAIS) come subdivided by state (or region), so the function must be repeated for all states. Then if the user needs more than one year of the dataset, the user repeats all the above, adjuting for changes fine and folder names.

Usuários então reconstrõem dicipnários de importação no R manualmente, e roda a função de importação apontando para o local onde os arquivos .txt estão salvos. Base de dados maior (como CENSO e RAIS) vem divididas por estado, então o procedimento tem de ser repetido para todos os estados. E ainda, se o usuário precisa de dados para mais de um ano, o processo acima tem de ser repetido ajustando para mudança nos nomes dos arquivos, dicionários e estrutura da pasta.

### microdadosBrasil aproach

(soon)

#### Design principles

The main design principle was separating details of each dataset in each year - such as folder structure, data files and import dictionaries of the of original data - into metadata tables (saved as csv files at the `extdata` folder). The elements in these tables, along with list of import dictionaries extracted from the SAS import instructions from the data provider, serve as parameters to import a dataset for a specific year. This separation of dataset specific details from the actual code makes code short and easier to extend to new packages.

O principal princípio utilizado na construção do pacote foi separar os detalhes de cada base de dados, como a estrutura de pastas e nome de arquivos em tabelas de metadados(salvos como arquivos .csv na pasta `extdata`). O conteúdo dessas tabelas, assim como uma lista contendo os dicionários de importação extraídos dos dicionários oficiais em formato SAS, seve como parâmetro para a importação dos microdados para cada ano. Essa separação entre detalhes específicos de cada base de dados e código torna o código mais simples e generalizável, facilitando a extensão para novas base de dados.

ergonomics over speed (develop)
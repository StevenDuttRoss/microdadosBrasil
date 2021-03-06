# This file contains the main import functions

#' @export
read_metadata <- function(dataset){
  read.csv2(system.file("extdata",
                        paste0(dataset,'_files_metadata_harmonization.csv'),
                        package = "microdadosBrasil"),
            stringsAsFactors = FALSE)

}

#' @export
read_var_translator <- function(dataset, ft){
  read.csv2(system.file("extdata",
                        paste0(dataset,'_',ft,'_varname_harmonization.csv'),
                        package = "microdadosBrasil"), stringsAsFactors = FALSE)
}




#' Reads fixed-width file (fwf) file based on dictionary.
#'
#' @param f A fixed-width file (fwf) (normally a .txt file).
#' @param dic A data.frame, containing the import dictionary, including the variables: var_name, int_pos, fin_pos, decima_places (optional)
#' @return a data.frame containing the imported data.
#'
#' @examples
#' \dontrun{aux_read_fwf(filename.txt,dicionary_name)}
#'
#' @import readr
#' @export
aux_read_fwf <- function(f,dic){
  print(f)
  f %>% read_fwf(fwf_positions(start=dic$int_pos,end=dic$fin_pos,col_names=dic$var_name),
                 col_types=paste(dic$col_type,collapse ='')) -> d
#   for(i in names(d)){
#     if(dic[dic$var_name==i,"col_type"] != 'c'){
#       print(i)
#     }
#   }
  return(d)
}





#' Reads files (fwf or csv).
#'
#' Main import function. Parses metadata and import diciontaries (in case of fwf files) to obtain import parameters for the desired subdataset and period. Then imports based on those parameters. Should not be aceessed directly, unless you are trying to extend the package, but rather though the wrapper funtions (read_CENSO, read_PNAD, etc).
#' @param dataset .
#' @param ft file type. Indicates the subdataset within the dataset. For example: "pessoa" (person) or "domicílio" (household) data from the "CENSO" (Census). For a list of available ft for the period just type an invalid ft (Ex: ft = 'aasfasf')
#' @param i period. Normally period in YYY format.
#' @param var_translator (optional) a data.frame containing a subdataset (ft) specific renaming dictionary. Rows indicate the variable and the columuns the periods.
#' @param root_path (optional) a path to the directory where dataset was downloaded
#'
#' @examples
#' \dontrun{
#' CSV data:
#' read_data('escola',2014,CensoEscolar_metadata)
#' read_data('escola',2014,CensoEscolar_metadata,CensoEscolar_escola_varname_harmonization)
#'
#' FWF data: dictionary is mandatory
#' read_data('escola',2013,CensoEscolar_metadata,CensoEscolar_dics)}

#' @import dplyr
#' @importFrom data.table data.table setnames rbindlist
#' @export
read_data <- function(dataset,ft,i, metadata = NULL,var_translator=NULL,root_path=NULL, file=NULL){

    #Check for inconsistency in parameters
    if(!is.null(root_path) & !is.null(file)){
      status = 0
      stop(paste0("\nPlease, do not specify both the 'root_path' and 'file' parameters to the function. You can:\n",
              "1) Specify neither the 'root_path' nor the 'file' argument, in this case we will assume that data is in your working directory and the files are named exactly as  they have been downloaded from the source.\n",
              "2) Specify only the 'root_path' argument, in this case we will assume that data is in the directory specified and it is exactly as it have been downloaded from the source.\n"),
              "3) Specify only the 'file' argument, in this case we will assume that data is in a .txt or .csv file stored in the adress specified by the 'file' parameter.")


    }else{
      if(is.null(root_path) & is.null(file)){
        status = 1
        message(paste0("You haven't specified neither the 'root_path' nor ther 'file' parameters to the function. in this case we will assume that data is in your working directory and the files are named exactly as  they have been downloaded from the source.\n"))


      }else{
      if(is.null(file)){
        status = 2
        message(paste0("You have specified only the 'root_path' argument, in this case we will assume that data is in the directory specified and it is exactly as it have been downloaded from the source.\n"))


      }else{
        status = 3

        message(paste0("You have specified only the 'file' argument, in this case we will assume that data is in a .txt or .csv file stored in the adress specified by the 'file' parameter.\n"))
        if (!file.exists(file)) { stop("Data not found. Check if you have provided a valid adress in the 'file' parameter" )  }
      }
      }
    }


print(i)
  #Extracting Parameters
    if(is.null(metadata)){metadata<- read_metadata(dataset)}
    i_min    <- min(metadata$period)
    i_max    <- max(metadata$period)
    ft2      <- paste0("ft_",ft)
    ft_list  <- names(metadata)[grep("ft_", names(metadata))]
    ft_list2 <- gsub("ft_","",names(metadata)[grep("ft_", names(metadata))])
    var_list <- names(metadata)[ !(names(metadata) %in% ft_list)]
    #Checking if parameters are valid
    if (!(i %in% metadata$period)) { stop(paste0("period must be between ", i_min," and ", i_max )) }
    if (!(ft %in% ft_list2 ))    { stop(paste0('ft (file type) must be one of these: ',paste(ft_list2, collapse=", "),
                                               '. See table of valid file types for each period at XXX'))  }

    #subseting metadata and var_translator
    md <- metadata %>% select_(.dots =c(var_list,ft2)) %>% filter(period==i) %>% rename_(.dots=setNames(ft2,ft))
    if (!is.null(var_translator)) {
      vt <- var_translator %>% rename_( old_varname = as.name(paste0('varname',i))) %>%
        select(std_varname ,old_varname ) %>% filter(!is.na(old_varname))
print(str(vt))
    }

    a <- md %>% select_(.dots = ft) %>% collect %>% .[[ft]]
    file_name <- unlist(strsplit(a, split='&'))[2]
    delim <- unlist(strsplit(a, split='&'))[1]  # for csv files
    format <- md %>% select_(.dots = 'format') %>% collect %>% .[['format']]
    missing_symbol <- md %>% select_(.dots = 'missing_symbols') %>% collect %>% .[['missing_symbols']] %>% ifelse(test = is.na(.), no = strsplit(x = .,split = "&")) %>% unlist
    # data_path <- paste0(root_path,"/",md$path,'/',md$data_folder)
    data_path <-  paste(c(root_path,md$path,md$data_folder) %>% .[!is.na(.)],collapse = "/") %>% ifelse(. == "", getwd(),.)

print(file_name)
print(data_path)
    files <- paste0(data_path,'/',list.files(path=data_path,pattern = file_name, ignore.case=T,recursive = TRUE))
print(files)

  #Checking if parameters are valid
    if (!(i %in% metadata$period)) { stop(paste0("period must be between ", i_min," and ", i_max )) }
    if (!(ft %in% ft_list2 ))    { stop(paste0('ft (file type) must be one of these: ',paste(ft_list2, collapse=", "),
                                          '. See table of valid file types for each period at XXX'))  }
    if (!file.exists(files) & status != 3) { stop("Data not found. Check if you have unziped the data" )  }


  #Importing
  if(status == 3){
    files = file
  }
    print(format)
    t0 <- Sys.time()
    if(format=='fwf'){

      dic <- get_import_dictionary(dataset, i, ft)

      lapply(files,aux_read_fwf, dic=dic) %>% bind_rows -> d
    }
    if(format=='csv'){
      print('b')
      lapply(files,data.table::fread, sep = delim, na.strings = c("NA",missing_symbol)) %>% rbindlist(use.names=T) -> d
      #     lapply(files,read_delim, delim = delim) -> d2
      #     d2 %>% bind_rows -> d
      # d <- (csv_file, )
    }
    t1 <- Sys.time()
    print(t1-t0)
    print(object.size(d), units = "Gb")

  #adjusting var names
    if (!is.null(var_translator)) {

      # d <- d %>% rename_(.dots = one_of(as.character(vt$old_varname), vt$new_varname))
      #names(d)[names(d) %in% vt$old_varname] <- vt$std_varname
      #d <- d %>% data.table::setnames(old = vt$old_varname, new = vt$new_varname)
      old_vars<- names(d) %in% vt$old_varname
      names(d)[old_vars]<- vt$std_varname
    }

  return(d)
}












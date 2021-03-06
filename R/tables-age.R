make.input.age.data.table <- function(model,
                                      fleet = 1,
                                      start.yr,
                                      end.yr,
                                      csv.dir = "out-csv",
                                      xcaption = "default",
                                      xlabel = "default",
                                      font.size = 9,
                                      space.size = 10,
                                      placement = "htbp",
                                      decimals = 2){
  ## Returns an xtable in the proper format for the main tables section for
  ##  combined fishery or survey age data
  ##
  ## fleet - 1 = Fishery, 2 = Survey
  ## start.yr - start the table on this year
  ## end.yr - end the table on this year
  ## xcaption - caption to appear in the calling document
  ## xlabel - the label used to reference the table in latex
  ## font.size - size of the font for the table
  ## space.size - size of the vertical spaces for the table
  ## placement - latex code for placement of table
  ## decimals - number of decimals in the numbers in the table

  if(!dir.exists(csv.dir)){
    dir.create(csv.dir)
  }

  ## Get ages from header names
  age.df <- model$dat$agecomp
  nm <- colnames(age.df)
  yr <- age.df$Yr
  flt <- age.df$FltSvy
  n.samp <- age.df$Nsamp
  ## Get ages from column names
  ages.ind <- grep("^a[[:digit:]]+$", nm)
  ages.num <- gsub("^a([[:digit:]]+)$", "\\1", nm[ages.ind])
  ages.num[length(ages.num)] <- paste0(ages.num[length(ages.num)], "+")
  ## Make all bold

  ages <- latex.bold(ages.num)
  ## Put ampersands in between each item and add newline to end
  ages.tex <-latex.paste(ages)

  ## Construct age data frame
  age.df <- age.df[,ages.ind]
  age.df <- t(apply(age.df,
                    1,
                    function(x){
                      as.numeric(x) / sum(as.numeric(x))
                    }))
  age.headers <- paste0(latex.mcol(1, "c", ages), latex.amp())
  age.df <- cbind(yr, n.samp, flt, age.df)

  ## Fishery or survey?
  age.df <- age.df[age.df[,"flt"] == fleet,]
  ## Remove fleet information from data frame
  age.df <- age.df[,-3]
  ## Extract years
  age.df <- age.df[age.df[,"yr"] >= start.yr & age.df[,"yr"] <= end.yr,]

  ## Make number of samples pretty
  age.df[,2] <- f(as.numeric(age.df[,2]))
  ## Make percentages for age proportions
  age.df[,-c(1,2)] <- as.numeric(age.df[,-c(1,2)]) * 100
  age.df[,-c(1,2)] <- f(as.numeric(age.df[,-c(1,2)]), decimals)
  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1

  addtorow$command <-
    paste0(latex.hline,
           latex.bold("Year"),
           latex.amp(),
           latex.mlc(c("Number",
                       "of samples")),
           latex.amp(),
           latex.mcol(length(ages),
                      "c",
                      latex.bold("Age (\\% of total for each year)")),
           latex.nline,
           latex.amp(2),
           ages.tex,
           latex.nline,
           latex.hline)

  addtorow$command <- paste0(addtorow$command,
                             latex_continue(ncol(age.df), addtorow$command))

  size.string <- latex.size.str(font.size, space.size)
  ## Write the CSV
  cnames <- colnames(age.df)
  cnames[3:length(cnames)] <- ages.num
  ## Add + for plus group
  cnames[length(cnames)] <- paste0(cnames[length(cnames)], "+")
  colnames(age.df) <- cnames
  write.csv(age.df,
            file.path(csv.dir,
                      ifelse(fleet == 1,
                             "fishery-input-age-proportions.csv",
                             "survey-input-age-proportions.csv")),
            na = "")

  print(xtable(age.df,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(age.df))),
        caption.placement = "top",
        include.rownames = FALSE,
        include.colnames = FALSE,
        sanitize.text.function = function(x){x},
        size = size.string,
        add.to.row = addtorow,
        table.placement = placement,
        tabular.environment = "longtable",
        hline.after = NULL)
}

make.can.age.data.table <- function(dat,
                                    fleet = 1,
                                    start.yr,
                                    end.yr,
                                    xcaption = "default",
                                    xlabel = "default",
                                    font.size = 9,
                                    space.size = 10,
                                    placement = "H",
                                    decimals = 2){
  ## Returns an xtable in the proper format for the main tables section for
  ##  Canadian age data.
  ##
  ## fleet - 1 = Can-Shoreside, 2 = Can-FT, 3 = Can-JV
  ## start.yr - start the table on this year
  ## end.yr - end the table on this year
  ## xcaption - caption to appear in the calling document
  ## xlabel - the label used to reference the table in latex
  ## font.size - size of the font for the table
  ## space.size - size of the vertical spaces for the table
  ## placement - latex code for placement of table
  ## decimals - number of decimals in the numbers in the table

  ages.df <- dat[[fleet]]
  n.trip.haul <- as.numeric(dat[[fleet + 3]])
  ages.df <- cbind(n.trip.haul, ages.df)
  dat <- cbind(as.numeric(rownames(ages.df)), ages.df)
  dat <- dat[dat[,1] >= start.yr & dat[,1] <= end.yr,]

  dat[,2] <- as.numeric(f(dat[,2]))
  ## Make percentages
  dat[,-c(1,2)] <- dat[,-c(1,2)] * 100
  dat[,-c(1,2)] <- f(dat[,-c(1,2)], decimals)
  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  age.headers <- colnames(dat)[grep("^[[:digit:]].*", colnames(dat))]
  ages <- 1:length(age.headers)
  ages[length(ages)] <- paste0(ages[length(ages)], "+")
  ages.tex <- latex.paste(latex.bold(ages))

  if(fleet == 2 | fleet == 3){
    mlc <- latex.mlc(c("Number",
                       "of hauls"))
  }else{
    mlc <- latex.mlc(c("Number",
                       "of trips"))
  }
  addtorow$command <-
    paste0(latex.hline,
           latex.bold("Year"),
           latex.amp(),
           mlc,
           latex.amp(),
           latex.mcol(length(age.headers),
                      "c",
                      latex.bold("Age (\\% of total for each year)")),
           latex.nline,
           latex.amp(2),
           ages.tex,
           latex.nline,
           latex.hline)

  addtorow$command <- paste0(addtorow$command,
                             latex_continue(ncol(dat), addtorow$command))

  size.string <- latex.size.str(font.size, space.size)
  print(xtable(dat,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(dat))),
        caption.placement = "top",
        include.rownames = FALSE,
        include.colnames = FALSE,
        sanitize.text.function = function(x){x},
        size = size.string,
        add.to.row = addtorow,
        table.placement = placement,
        tabular.environment = "longtable",
        hline.after = NULL)
}

make.us.age.data.table <- function(dat,
                                   fleet = 1,
                                   start.yr,
                                   end.yr,
                                   xcaption = "default",
                                   xlabel = "default",
                                   font.size = 9,
                                   space.size = 10,
                                   placement = "H",
                                   decimals = 2){

  ## Returns an xtable in the proper format for the main tables section for US
  ##  age data.
  ##
  ## fleet - 1=US-CP, 2=US-MS, 3=US-Shoreside
  ## start.yr - start the table on this year
  ## end.yr - end the table on this year
  ## xcaption - caption to appear in the calling document
  ## xlabel - the label used to reference the table in latex
  ## font.size - size of the font for the table
  ## space.size - size of the vertical spaces for the table
  ## placement - latex code for placement of table
  ## decimals - number of decimals in the numbers in the table
  ncolumns <- grep("n\\.", colnames(dat))
  dat[, ncolumns] <- f(dat[, ncolumns])
  dat[, -c(1, ncolumns)] <- f(dat[, -c(1, ncolumns)]* 100, decimals)
  dat <- dat[dat[,1] >= start.yr & dat[,1] <= end.yr,]

  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  age.headers <- colnames(dat)[grep("^a.*", colnames(dat))]
  ages <- 1:length(age.headers)
  ages[length(ages)] <- paste0(ages[length(ages)], "+")
  ages.tex <- latex.paste(latex.bold(ages))

  if(fleet == 1 | fleet == 2){
    mlc <- latex.mlc(c("Number",
                       "of hauls"))
  }else{
    mlc <- latex.mlc(c("Number",
                       "of trips"))
  }
  addtorow$command <-
    paste0(latex.hline,
           latex.bold("Year"),
           latex.amp(),
           latex.mlc(c("Number", "of fish")),
           latex.amp(),
           mlc,
           latex.amp(),
           latex.mcol(length(age.headers),
                      "c",
                      latex.bold("Age (\\% of total for each year)")),
           latex.nline,
           latex.amp(3),
           ages.tex,
           latex.nline,
           latex.hline)

  addtorow$command <- paste0(addtorow$command,
                             latex_continue(ncol(dat), addtorow$command))

  size.string <- latex.size.str(font.size, space.size)
  print(xtable(dat,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(dat))),
        caption.placement = "top",
        include.rownames = FALSE,
        include.colnames = FALSE,
        sanitize.text.function = function(x){x},
        size = size.string,
        add.to.row = addtorow,
        table.placement = placement,
        tabular.environment = "longtable",
        hline.after = NULL)
}

#' Makes a table of the estimated -at-age values for 5 different values:
#' Numbers-at-age, Catch-at-age, Biomass-at-age, Exploitation-at-age,
#' and Catch-at-age-biomass
#'
#' @param model A model in this project
#' @param start_yr Start year for the table
#' @param end_yr End year for the table
#' @param table_type 1 = Numbers-at-age, 2 = Exploitation-rate-at-age, 3 = Catch-at-age-number
#' 4 = Catch-at-age-biomass, 5 = Biomass-at-age
#' @param digits Number of decimal points
#' @param csv_dir Directory for CSV output
#' @param xcaption Table caption
#' @param xlabel The label used to reference the table in latex
#' @param font_size Size of the font for the table
#' @param space_size Size of the vertical spaces for the table
#'
#' @return An [xtable::xtable()]
#' @export
atage_table <- function(model,
                        start_yr = NA,
                        end_yr = NA,
                        table_type = 1,
                        digits = 0,
                        csv_dir = "out-csv",
                        xcaption = "default",
                        xlabel   = "default",
                        font_size = 9,
                        space_size = 10){

  if(!dir.exists(csv_dir)){
    dir.create(csv_dir)
  }

  tbl <- switch (table_type,
                 model$extra.mcmc$natage_median,
                 model$extra.mcmc$expatage_median,
                 model$extra.mcmc$catage_median,
                 model$extra.mcmc$catage_biomass_median,
                 model$extra.mcmc$batage_median)
  fn <- switch (table_type,
                file.path(csv_dir, out.est.naa.file),
                file.path(csv_dir, out.est.eaa.file),
                file.path(csv_dir, out.est.caa.file),
                file.path(csv_dir, out.est.caa.bio.file),
                file.path(csv_dir, out.est.baa.file))

  yrs_in_table <- sort(unique(tbl$Yr))
  min_yr <- min(yrs_in_table)
  max_yr <- max(yrs_in_table)
  start_yr <- ifelse(is.na(start_yr), min_yr, start_yr)
  end_yr <- ifelse(is.na(end_yr), max_yr, end_yr)
  if(start_yr > end_yr){
    start_yr <- min_yr
    end_yr <- max_yr
  }
  start_yr <- ifelse(start_yr < min_yr, min_yr, start_yr)
  end_yr <- ifelse(end_yr > max_yr, max_yr, end_yr)
  yrs <- start_yr:end_yr

  dat <- tbl %>%
    filter(Yr %in% yrs) %>%
    rename(Year = Yr) %>%
    mutate(Year = as.character(Year))
  write_csv(dat, fn)
  dat <- dat %>%
    mutate_at(.vars = vars(-Year), ~{f(.x, digits)})
  names(dat)[length(names(dat))] <- paste0(names(dat)[length(names(dat))], "+")

  # Add latex headers
  ages <- colnames(dat)[-1]
  ages_tex <- map_chr(ages, latex.bold)
  ages_tex <- paste0(latex.paste(ages_tex), latex.nline)

  # Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1

  addtorow$command <-
    paste0(latex.hline,
           latex.bold("Year"),
           latex.amp(),
           latex.mcol(ncol(dat) - 1,
                      "c",
                      latex.bold("Age")),
           latex.nline,
           latex.amp(),
           ages_tex,
           latex.hline)

  addtorow$command <- paste0(addtorow$command,
                             latex_continue(ncol(dat), addtorow$command))

  # Make the size string for font and space size
  size_string <- latex.size.str(font_size, space_size)
  return(print(xtable(dat,
                      caption = xcaption,
                      label = xlabel,
                      align = get.align(ncol(dat))),
               caption.placement = "top",
               include.rownames = FALSE,
               include.colnames = FALSE,
               sanitize.text.function = function(x){x},
               size = size_string,
               add.to.row = addtorow,
               table.placement = "H",
               tabular.environment = "longtable",
               #latex.environments = "center",
               hline.after = NULL))

}

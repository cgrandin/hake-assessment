#' Load a CSV file with landings and TACS and create a nice [tibble::tibbble]
#' containing output
#'
#' @param fn The name of the landings/TAC CSV file
#'
#' @return A [tibble::tibble] with the formatted output. names ending in '_xx' are not to
#' be shown in the landings/TAC table.
#' @export
load_catches <- function(fn = NA){

  stopifnot(!is.na(fn))

  d <- read_csv(fn, col_types = cols())
  d <- as_tibble(d)
  d %>%
    transmute(year = Year,
              us_catch = Ustotal,
              can_catch = CANtotal,
              tot_catch = TOTAL,
              us_prop_tot_catch = us_catch / tot_catch * 100,
              can_prop_tot_catch = can_catch / tot_catch * 100,
              us_tac = TACUSA,
              can_tac = TACCAN,
              tot_tac = TAC,
              us_attain = us_catch / us_tac * 100,
              can_attain = can_catch / can_tac * 100,
              tot_attain = tot_catch / tot_tac * 100,
              us_research_xx = USresearch,
              us_cp_xx = atSea_US_CP,
              us_ms_xx = atSea_US_MS,
              us_shore_xx = US_shore,
              us_foreign_xx = US_foreign,
              us_jv_xx = US_JV,
              can_foreign_xx =  CAN_forgn,
              can_jv_xx = CAN_JV,
              can_shore_xx = CAN_Shoreside,
              can_freeze_xx = CAN_FreezeTrawl)
}

#' Make summary of catch for given country
#'
#' @param ct Output from [load_catches()]
#' @param country 1 for Canada, 2 for US, anything else for both
#' @param start_yr Start year in table
#' @param end_yr End year in table
#' @param xcaption Latex caption
#' @param xlabel Latex label
#' @param font_size Font size
#' @param space_size Between-letter space size
#'
#' @return An [xtable::xtable()]
#' @export
make_catch_table <- function(ct,
                             country = 3,
                             start_yr,
                             end_yr,
                             xcaption = "default",
                             xlabel   = "default",
                             font_size = 9,
                             space_size = 10){

  ct <- as_tibble(ct)
  yrs <- ct$year
  start_yr <- ifelse(start_yr < min(yrs), min(yrs), start_yr)
  end_yr <- ifelse(end_yr > max(yrs) | end_yr < start_yr, max(yrs), end_yr)
  yrs <- start_yr:end_yr

  if(country == 1){
    ct <- ct %>%
      select(year, can_foreign_xx, can_jv_xx, can_shore_xx, can_freeze_xx, can_catch)
    ct_names <- c(latex.bold("Year"),
                  latex.bold("Foreign"),
                  latex.bold("JV"),
                  latex.bold("Shoreside"),
                  latex.bold("Freezer-Trawler"),
                  latex.bold("Total"))
  }else if(country == 2){
    ct <- ct %>%
      select(year, us_foreign_xx, us_jv_xx, us_ms_xx, us_cp_xx, us_shore_xx, us_research_xx, us_catch)
    ct_names <- c(latex.bold("Year"),
                  latex.bold("Foreign"),
                  latex.bold("JV"),
                  latex.bold("Mothership"),
                  latex.bold("Catcher-Processor"),
                  latex.bold("Shore-based"),
                  latex.bold("Research"),
                  latex.bold("Total"))
  }else{
    ct <- ct %>%
      select(year, us_ms_xx, us_cp_xx, us_shore_xx, us_research_xx, us_catch,
             can_jv_xx, can_shore_xx, can_freeze_xx, can_catch, tot_catch)
    ct_names <- c(latex.bold("Year"),
                  latex.mlc(c("US",
                              "Mother-",
                              "ship")),
                  latex.mlc(c("US",
                              "Catcher-",
                              "Processor")),
                  latex.mlc(c("US",
                              "Shore-",
                              "Based")),
                  latex.mlc(c("US",
                              "Research")),
                  latex.mlc(c("US",
                              "Total")),
                  latex.mlc(c("CAN",
                              "Joint-",
                              "Venture")),
                  latex.mlc(c("CAN",
                              "Shoreside")),
                  latex.mlc(c("CAN",
                              "Freezer-",
                              "Trawler")),
                  latex.mlc(c("CAN",
                              "Total")),
                  latex.bold("Total"))
  }

  ct <- ct %>%
    filter(year %in% yrs) %>%
    mutate(year = as.character(year)) %>%
    mutate_at(.vars = vars(-year), ~{f(.x, 0)})

  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1

  addtorow$command <-
    paste0(latex.hline,
           paste(ct_names, collapse = latex.amp()),
           latex.nline,
           latex.hline)

  addtorow$command <- paste0(addtorow$command,
                             latex_continue(ncol(ct), addtorow$command))

  size_string <- latex.size.str(font_size, space_size)
  print(xtable(ct,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(ct))),
        caption.placement = "top",
        include.rownames = FALSE,
        include.colnames = FALSE,
        add.to.row = addtorow,
        table.placement = "H",
        tabular.environment = "longtable",
        sanitize.text.function = function(x){x},
        size = size_string,
        hline.after = NULL)
}

#' Make a summary table of landings and TACS
#'
#' @param d Data frame as output from [load_catches()]
#' @param start_yr Start year for the table
#' @param end_yr End year for the table. If past data range, the last year in `d` will be used
#' @param xcaption Caption for the table
#' @param xlabel Latex label to use
#' @param font.size Size of the font
#' @param space.size Size of spaces between letters
#' @param placement Latex table placement character
#'
#' @return
#' @export
#'
#' @examples
make_landings_tac_table <- function(d,
                                    start_yr,
                                    end_yr,
                                    xcaption = "default",
                                    xlabel   = "default",
                                    font_size = 9,
                                    space_size = 10,
                                    placement = "H"){

  tab <- as_tibble(d)
  yrs <- tab$year
  start_yr <- ifelse(start_yr < min(yrs), min(yrs), start_yr)
  end_yr <- ifelse(end_yr > max(yrs) | end_yr < start_yr, max(yrs), end_yr)
  yrs <- start_yr:end_yr

  prop_cols <- grep("prop|attain", names(tab))
  xx_cols <- grep("_xx", names(tab))

  tab <- tab %>%
    select(-all_of(xx_cols)) %>%
    filter(year %in% yrs) %>%
    mutate(year = as.character(year)) %>%
    mutate_at(.vars = vars(all_of(prop_cols)), ~{paste0(f(.x, 1), "\\%")}) %>%
    mutate_at(.vars = vars(-c(year, all_of(prop_cols))), ~{f(.x, 0)}) %>%
    mutate_all(~{str_replace_all(., "NA", "")}) %>%
    mutate_all(~{str_replace_all(., " \\\\%", "")}) %>%
    mutate_all(~{str_replace_all(., "^ +$", "--")})

  names(tab) <- c(latex.bold("Year"),
                  latex.mlc(c("U.S.",
                              "landings (t)")),
                  latex.mlc(c("Canada",
                              "landings (t)")),
                  latex.mlc(c("Total",
                              "landings (t)")),
                  latex.mlc(c("U.S.",
                              "proportion",
                              "of total",
                              "catch")),
                  latex.mlc(c("Canada",
                              "proportion",
                              "of total",
                              "catch")),
                  latex.mlc(c("U.S.",
                              "catch",
                              "target (t)")),
                  latex.mlc(c("Canada",
                              "catch",
                              "target (t)")),
                  latex.mlc(c("Coast-wide",
                              "catch",
                              "target (t)")),
                  latex.mlc(c("U.S.",
                              "proportion",
                              "of catch",
                              "target",
                              "removed")),
                  latex.mlc(c("Canada",
                              "proportion",
                              "of catch",
                              "target",
                              "removed")),
                  latex.mlc(c("Total",
                              "proportion",
                              "of catch",
                              "target",
                              "removed")))

  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1

  addtorow$command <-
    paste0(latex.hline,
           paste(names(tab), collapse = latex.amp()),
           latex.nline,
           latex.hline)

  addtorow$command <- paste0(addtorow$command,
                             latex_continue(ncol(tab), addtorow$command))

  size_string <- latex.size.str(font_size, space_size)
  print(xtable(tab,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(tab),
                                 first.left = FALSE,
                                 just = "c")),
               #digits = c(0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1)),
        caption.placement = "top",
        include.rownames = FALSE,
        include.colnames = FALSE,
        add.to.row = addtorow,
        table.placement = placement,   # think longtable ignores this anyway,
                                       # gives warning
        tabular.environment = "longtable",
        sanitize.text.function = function(x){x},
        size = size_string,
        hline.after = NULL)
}

further.tac.details <- function(fn){
  ## Reads in the further.tac.details file and returns it as a data.frame
  ##
  ## fn - the filename with relative path
  read.csv(fn, header = TRUE, sep = ",", comment.char = "#")
}

make.catches.table.us.ap <- function(catches,
                                     xcaption = "default",
                                     xlabel   = "default",
                                     font.size = 9,
                                     space.size = 10,
                                     placement = "H"){
  ## Returns an xtable for the US AP appendix
  ##
  ## catches - data frame of catches in the format of data/us-ap-catch.csv
  ## xcaption - caption to appear in the calling document
  ## xlabel - the label used to reference the table in latex
  ## font.size - size of the font for the table
  ## space.size - size of the vertical spaces for the table
  ## placement - latex code for the placement of the table in the document

  make.true.NA <- function(x){
    ## Change <NA> to NA
    if(is.character(x) || is.factor(x)){
      is.na(x) <- x %in% c("NA", "<NA>")
      x
    }else{
      as.numeric(x)
    }
  }

  colnames(catches)[1] <- ""
  nr <- nrow(catches)
  nc <- ncol(catches)
  ## Make value cells be comma-separated
  catches[!grepl("\\%", catches[, 1]), -1] <- apply(
    catches[!grepl("\\%", catches[, 1]), -1], 1:2,
    function(x) format(as.numeric(x), big.mark = ","))

  ## Change factorized version <NA> to NA
  catches <- apply(catches, c(1,2), make.true.NA)
  catches <- apply(catches, c(1,2), function(x){gsub("NA", NA, x)})
  ## Replace NA with --
  catches[is.na(catches)] <- ""

  ## Make percent cells have percent signs
  catches <- apply(catches, 1:2, function(x) gsub("\\%", "\\\\%", x))
  ## Fix Total for Util Init. Alloc cell
  catches[
    grep("Init", catches[, 1], ignore.case = TRUE),
    grep("total", colnames(catches), ignore.case = TRUE)] <- ""

  ## Make column and row headers bold
  catches[,1] <- latex.bold(catches[,1])
  colnames(catches) <- gsub("\\.{2}", " ", colnames(catches))
  colnames(catches) <- gsub(" (\\D+)\\.$", " \\(\\1\\)", colnames(catches))
  colnames(catches) <- gsub("US |U.S ", "U.S. ", colnames(catches))
  colnames(catches) <- gsub("([[:lower:]])\\.([[:upper:]])", "\\1 \\2", colnames(catches))
  colnames(catches)[-1] <- latex.bold(colnames(catches)[-1])
  ## Make it so that the first row heading doesn't appear.
  ##  This must be a space and not the null string
  colnames(catches)[1] <- " "

  size.string <- latex.size.str(font.size, space.size)
  print(xtable(catches,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(catches))),
        caption.placement = "top",
        include.rownames = FALSE,
        table.placement = placement,
        sanitize.text.function = function(x){x},
        size = size.string)
}

make.catches.plot <- function(ct,
                              mar = c(4, 4, 6, 2) + 0.1,
                              leg.y.loc = 430,
                              leg.cex = 1){
  ## Plot the catches in a stacked-barplot with legend
  ##
  ## leg.y.loc - y-based location to place the legend
  ## leg.cex - text size for legend

  yrs <- ct$year
  ct <- ct %>%
    select(can_foreign_xx,
           can_jv_xx,
           can_shore_xx,
           can_freeze_xx,
           us_foreign_xx,
           us_jv_xx,
           us_ms_xx,
           us_cp_xx,
           us_shore_xx)

  cols <- c(rgb(0, 0.8, 0),
            rgb(0, 0.6, 0),
            rgb(0.8, 0, 0),
            rgb(0.4, 0, 0),
            rgb(0, 0.2, 0),
            rgb(0, 0.4, 0),
            rgb(0, 0, 0.7),
            rgb(0, 0, 0.4),
            rgb(0, 0, 1))

  legOrder <- c(6, 5, 2, 1, 4, 3, NA, NA, 9, 8, 7)

  oldpar <- par()
  on.exit(par(oldpar))

  par(las = 1,
      mar = mar,
      cex.axis = 0.9)

  # Gives x-values for tick marks (since years not in ct)
  tmp <- barplot(t(as.matrix(ct)) / 1000,
                 beside = FALSE,
                 names = ct$year,
                 col = cols,
                 xlab = "Year",
                 ylab = "",
                 cex.lab = 1,
                 xaxt = "n",
                 xaxs = "i",
                 mgp = c(2.2, 1, 0),
                 ylim = c(0, 475))

  grid(NA, NULL, lty = 1, lwd = 1)
  mtext("Catch (thousand t)",
        side = 2,
        line = 2.8,
        las = 0,
        cex = 1.3)
  barplot(t(as.matrix(ct)) / 1000,
          beside = FALSE,
          names = ct$year,
          col = cols,
          xlab = "Year",
          ylab = "",
          cex.lab = 1,
          xaxt = "n",
          xaxs = "i",
          add = TRUE,
          mgp = c(2.2, 1, 0))
  # Big tick every five years:
  axis(1,
       at = tmp[(yrs %% 5) == 0],
       lab = yrs[(yrs %% 5) == 0])
  axis(1,
       at = tmp,
       lab = rep("",length(tmp)), tcl = -0.3)

  legend(x = 0, y = leg.y.loc,
         c("Canada Foreign",
           "Canada Joint-Venture",
           "Canada Shoreside",
           "Canada Freezer-Trawler",
           "U.S. Foreign",
           "U.S. Joint-Venture",
           "U.S. Mothership",
           "U.S. Catcher-Processor",
           "U.S. Shore-Based")[legOrder],
         bg = "white",
         horiz = FALSE,
         xpd = NA,
         cex = leg.cex,
         ncol = 3,
         fill = cols[legOrder],
         border = cols[legOrder],
         bty = "n")
}

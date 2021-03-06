#' Format x to have supplied number of decimal points
#'
#' @details Make thousands separated by commas and the number of decimal points given by `dec.points`
#'
#' @param x The number
#' @param dec.points The number of decimal points to use
#'
#' @return A formatted string representing the number
#' @export
f <- function(x, dec.points = 0){
  format(round(x,dec.points), big.mark = ",", nsmall = dec.points)
}

#' Take a data frame that has at least two columns called year and fdep, convert to meters and
#' calculate boxplot stats on each year write a csv file to current directory
#'
#' @details Use spatial data frame (Canada) output to this function
#'
#' @param x The data frame
#' @param fleet
#'
#' @return [base::invis]
#' @export
#'
#' @examples
#' export.depth(d.ft, "freezer-trawlers")
#' export.depth(d.ss, "shoreside")
export.depth <- function(x, fleet = ""){

  x %>%
    transmute(year = as.factor(year), depth = fdep * 1.8288) %>%
    group_by(year) %>%
    do(as.data.frame(t(boxplot.stats(.$depth)$`stats`))) %>%
    ungroup() %>%
    transmute(year,
              lower95 = V1,
              lowerhinge = V2,
              median = V3,
              upperhinge = V4,
              upper95 = V5) %>%
    write.csv(file.path(here::here(),
                        "data",
                        paste0("depth-can-",
                               fleet,
                               ".csv")),
              row.names = FALSE)
}

# Functions to make table generation easier -----------------------------------
# Latex newline
latex.nline <- " \\\\ "
# Horizontal line
latex.hline <- " \\hline "

#' Create a string with `n` ampersands separated by spaces
#'
#' @details The string will have one leading and one trailing space
#'
#' @param n
#'
#' @return A string with `n` ampersands seperated by spaces
#' @export
latex.amp <- function(n = 1){
  paste0(rep(" &", n), " ", collapse = "")
}

#' Create a string comprised of each element in the vector `vec` with an ampersand in between
#'
#' @details The string will have one leading and one trailing space
#'
#' @param vec A vector of characters
#'
#' @return A string comprised of each element in the vector `vec` with an ampersand in between
#' @export
latex.paste <- function(vec){
  paste(" ", vec, " ", collapse = " & ")
}

#' Wrap the given text with the latex \\textbf{} macro around it
#'
#' @param txt The text
#'
#' @return The given text with the latex \\textbf{} macro around it
#' @export
latex.bold <- function(txt){
  paste0("\\textbf{", txt, "}")
}

#' Wrap the given text with the latex \\emph{} macro around it
#'
#' @param txt The text
#'
#' @return The given text with the latex \\emph{} macro around it
#' @export
latex.italics <- function(txt){
  paste0("\\emph{", txt, "}")
}

#' Wrap the given text with the latex \\underline{} macro around it
#'
#' @param txt The text
#'
#' @return The given text with the latex \\underline{} macro around it
#' @export
latex.under <- function(txt){
  paste0("\\underline{", txt, "}")
}

#' Returns a string which has been glued together using multi-line-cell macro for latex
#'
#' @param latex.vec A vector of the strings to glue together
#' @param make.bold Logical. If TRUE, make the text bold by inserting a \textbf{} macro
#'
#' @return
#' @export
latex.mlc <- function(latex.vec, make.bold = TRUE){
  if(make.bold){
    latex.vec <- sapply(latex.vec, latex.bold)
  }
  latex.str <- paste(latex.vec, collapse = latex.nline)
  paste0("\\mlc{", latex.str, "}")
}

#' Wrap the given text with the latex \\multicolumnn{} macro around it
#'
#' @param ncol The number of columns
#' @param just Justification, e.g. "l", "c", or "r" for left, center, right
#' @param txt The text
#'
#' @return The given text with the latex \\multicolumn{} macro around it
#' @export
latex.mcol <- function(ncol, just, txt){
  paste0("\\multicolumn{", ncol, "}{", just, "}{", txt, "}")
}

#' Wrap the given text with the latex \\multirow{} macro around it
#'
#' @param ncol The number of columns
#' @param just Justification, e.g. "l", "c", or "r" for left, center, right
#' @param txt The text
#'
#' @return The given text with the latex \\multirow{} macro around it
#' @export
latex.mrow <- function(nrow, just, txt){
  paste0("\\multirow{", nrow, "}{", just, "}{", txt, "}")
}

#' Creates a string which has the given font size and space size applied
#'
#' @param fnt.size The font size
#' @param spc.size The space size (between text size)
#'
#' @return A string which has the given font size and space size applied
#' @export
latex.size.str <- function(fnt.size, spc.size){
  paste0("\\fontsize{", fnt.size, "}{", spc.size, "}\\selectfont")
}

#' Provide latex code to draw a horizontal line across the columns specified
#'
#' @param cols A string in this format: "1-3" which means the line should go across columns 1 to 3
#'
#' @return A string of latex code to draw a horizontal line across the columns specified
#' @export
#'
#' @examples
latex.cline <- function(cols){
  paste0("\\cline{", cols, "}")
}

#' Provide latex code to draw a horizontal line across the columns specified
#'
#' @param cols A string in this format: "1-3" which means the line should go across columns 1 to 3
#' @param trim Can be l, r, or lr and tells it to trim the line a bit so that if there are two lines they don't
#' touch in the middle. See [booktabs]
#'
#' @return As string of latex code to draw a horizontal line across the columns specified
#' @export
latex.cmidr <- function(cols, trim = "r"){
  paste0("\\cmidrule(", trim, "){", cols, "}")
}

#' Creates a latex string with `main.txt` subscripted by `subscr.txt`
#'
#' @param main.txt The main text to subscript
#' @param subscr.txt The subscript text
#'
#' @return A latex string with `main.txt` subscripted by `subscr.txt`
#' @export
latex.subscr <- function(main.txt, subscr.txt){
  paste0(main.txt, "\\subscr{", subscr.txt, "}")
}

#' Creates a latex string with `main.txt` superscripted by `supscr.txt`
#'
#' @param main.txt The main text to superscript
#' @param supscr.txt The superscript text
#'
#' @return A latex string with `main.txt` superscripted by `supscr.txt`
#' @export
latex.supscr <- function(main.txt, supscr.txt){
  paste0(main.txt, "\\supscr{", supscr.txt, "}")
}

#' Return the necessary latex to repeat longtable headers for continuing pages
#'
#' @return vector of strings needed to repeat the header of a longtable
#' and a footer which says 'Continued on next page ...'
#' @export
latex_continue <- function(n_col = 1, header = "Default"){
  paste0("\\endfirsthead \n",
         "\\multicolumn{", n_col, "}{l}{\\textit{... Continued from previous page}} \n",
         latex.nline,
         header,
         "\\endhead \n",
         latex.nline,
         latex.hline,
         "\\multicolumn{", n_col, "}{l}{\\textit{Continued on next page ...}} \n",
         "\\endfoot \n",
         "\\endlastfoot \n")
}

#' Extract priors information from `prior.str``
#'
#' @param prior.str A string with the format *Lognormal(2.0,1.01)*
#' @param dec.points The number of decimal points to use
#' @param first.to.lower Make the first letter of the prior name lower case
#'
#' @return A vector of length 3 with the following format: *c("Lognormal", 2.0, 1.01)*
#' @export
split.prior.info <- function(prior.str,
                             dec.points = 1,
                             first.to.lower = FALSE){
  p <- strsplit(prior.str, "\\(")[[1]]
  if(first.to.lower){
    ## Make the name of the prior lower case
    p[1] <- paste0(tolower(substr(p[1], 1, 1)),
                   substr(p[1],
                          2,
                          nchar(p[1])))
  }
  p.type <- p[1]
  p <- strsplit(p[2], ",")[[1]]
  p.mean <- f(as.numeric(p[1]), dec.points)
  p.sd <- f(as.numeric(gsub(")", "", p[2])), dec.points)
  c(p.type, p.mean, p.sd)
}

#' Calculate the total catch taken for a given cohort
#'
#' @param model The model to extract from
#' @param cohort The year the cohort was born
#' @param ages The ages to include in the summation calculation
#' @param trim.end.year Remove all years after this including this year
#'
#' @return The total catch for a given cohort
#' @export
cohort.catch <- function(model, cohort, ages = 0:20, trim.end.year = NA) {

  catage <- model$catage
  w <- model$wtatage
  cohort.yrs <- cohort + ages
  caa <- as.matrix(catage[catage$Yr %in% cohort.yrs, as.character(ages)])
  waa <- w[w$Fleet == 1 & w$Yr %in% cohort.yrs, ]
  waa <- waa[, names(waa) %in% ages]
  catch.waa <- as.matrix(caa * waa)

  ind <- 1:(nrow(caa) + 1)
  if(length(ind) > length(ages)){
    ind <- 1:nrow(caa)
  }
  cohort.catch <- diag(catch.waa[,ind])
  names(cohort.catch) <- cohort.yrs[1:(nrow(caa))]
  if(!is.na(trim.end.year)){
    cohort.catch <- cohort.catch[names(cohort.catch) < trim.end.year]
  }
  cohort.catch
}

#' Create text describing the top `num.cohorts` cohorts by year and percentage as a sentence
#'
#' @details top.coh(base.model, 2018, 2) produces:
##  "The 2018 cohort was the largest (29\\%), followed by the 2010 cohort (27\\%)"
#'
#' @param model The model as returned from [load_ss_files()]
#' @param yr The year the cohort was born
#' @param num.cohorts The number of cohorts to include in the sentence
#' @param decimals The number of decimal points to use
#' @param cap Logical. Capitalize the first word in the sentence?
#' @param spec.yr If supplied, the percentage of catch that this cohort made to the
#' `yr` catch will be returned
#' @param use.catage If TRUE, use the *model$catage* object which are the estimates \. If FALSE,
#' use the *model$dat$agecomp* object which are the input data
#' @param fleet A integer value allowing the selection of a given fleet, where
#' for Pacific hake, \code{fleet = 1}, the default, selects the fishery data.
#'
#' @return Text describing the top `num.cohorts` cohorts by year and percentage as a sentence
#' @export
top.coh <- function(model = NULL,
                    yr = NA,
                    num.cohorts = 3,
                    decimals = 0,
                    cap = TRUE,
                    spec.yr = NA,
                    use.catage = FALSE,
                    fleet = 1){

  stopifnot(!is.null(model),
            !is.na(yr))
  stopifnot(length(fleet) == 1)

  if(num.cohorts < 1){
    num.cohorts = 1
  }
  if(use.catage){
    tmp <- model$catage[, -c(1, 3, 4, 5, 6)] %>%
      dplyr::filter(Fleet %in% fleet) %>%
      select(-c(Fleet, Seas, XX, Era, 0))
    tmp <- tmp[-1,]
  }else{
    tmp <- model$dat$agecomp[, -c(2, 4, 5, 6, 7, 8, 9)] %>%
      dplyr::filter(FltSvy %in% fleet) %>%
      select(-FltSvy) %>%
      mutate_all(list(as.numeric))
    names(tmp) <- gsub("^a", "", names(tmp))
  }
  row.sums <- rowSums(select(tmp, -Yr))
  x <- tmp %>%
    select(-Yr) %>%
    mutate_all(~ ./row.sums)
  x <- cbind(Yr = tmp$Yr, x) %>%
    dplyr::filter(Yr == yr) %>%
    select(-Yr) %>%
    sort() %>%
    rev()
  # The following stops xtfrm.data.frame(x) : cannot xtfrm data frames
  # from being print
  # todo: change after more through checking
  # x <- cbind(Yr = tmp$Yr, x) %>%
  #   dplyr::filter(Yr == yr) %>% pivot_longer(cols = -Yr) %>%
  #   arrange(desc(value)) %>% pivot_wider() %>%
  #   select(-Yr)
  txt <- paste0(ifelse(cap, "The ", "the "),
                yr - as.numeric(names(x)[1]),
                " cohort was the largest (",
                f(x[1] * 100, decimals),
                "\\%)")
  if(num.cohorts > 1){
    for(i in 2:num.cohorts){
      txt <- paste0(txt,
                    ifelse(i == 2, ", followed by the ", ", then the "),
                    yr - as.numeric(names(x)[i]),
                    " cohort (",
                    f(x[i] * 100, decimals),
                    "\\%)")
    }
  }
  if(!is.na(spec.yr)){
    return(f(as.numeric(x[names(x) == yr - spec.yr]) * 100, decimals))
  }
  txt
}

#' Create the age prop and the age itself for the ranking of age proportions
#'
#' @details Think of the question "Which is the second-highest number in this vector and what is
#' its index in the vector?" This function returns a vector of those two numbers.
#'
#' @param vec A vector of age proportions
#' @param ranking 1 = max, 2 = second highest, etc.
#'
#' @return The age proportion and the age itself for the ranking of age proportion
#' @export
get.age.prop <- function(vec, ranking = 1){
  prop <- rev(sort(vec))
  prop <- prop[ranking]
  age <- as.numeric(names(vec[vec == prop]))
  c(age, prop)
}

#' Create an RGB string of the specified color and opacity
#'
#' @details Format of returned string is #RRGGBBAA where
#' RR = red, a 2-hexadecimal-digit string
#' GG = green, a 2-hexadecimal-digit string
#' BB = blue, a 2-hexadecimal-digit string
#' AA = opacity, 2-digit string
#'
#' @param color A vector of R color strings or numbers
#' @param opacity A number between 0 and 99
#'
#' @returnn An RGB string of the specified color and opacity
#' @export
get.shade <- function(color, opacity){

  stopifnot(opacity > 0 & opacity < 100)

  colorDEC <- col2rgb(color)
  if(is.matrix(colorDEC)){
    colorHEX <- matrix(nrow = 3, ncol = ncol(colorDEC))
    shade <- NULL
    for(col in 1:ncol(colorDEC)){
      for(row in 1:nrow(colorDEC)){
        colorHEX[row, col] <- sprintf("%X", colorDEC[row,col])
        if(nchar(colorHEX[row,col]) == 1){
          colorHEX[row, col] <- paste0("0", colorHEX[row,col])
        }
      }
      shade[col] <- paste0("#", colorHEX[1, col], colorHEX[2, col], colorHEX[3, col], opacity)
    }
  }else{
    colorHEX <- sprintf("%X", colorDEC)
    for(i in 1:length(colorHEX)){
      if(nchar(colorHEX[i]) == 1){
        colorHEX[i] <- paste0("0", colorHEX[i])
      }
    }
    shade <- paste0("#", colorHEX[1], colorHEX[2], colorHEX[3], opacity)
  }
  shade
}

#' Pad the beginning of a number with zeroes
#'
#' @param num A vector of the numbers to pad
#' @param digits The number of characters that the resulting strings should have
#'
#' @return A vector of strings of the padded numbers
#' @export
pad.num <- function(num, digits = 1){
  stopifnot(digits >= 1, !any(nchar(num) > digits))
  sapply(num, function(x){paste0(paste0(rep("0", digits - nchar(as.character(x))), collapse = ""), as.character(x))})
}

t.pn <- function(){
  ## test pad.num
  cat("pad.num(0, 1) = ", pad.num(0, 1), "\n")
  cat("pad.num(1, 2) = ", pad.num(1, 2), "\n")
  cat("pad.num(10, 2) = ", pad.num(10, 2), "\n")
  cat("pad.num(10, 3) = ", pad.num(10, 3), "\n")
  cat("pad.num(10, 0) = ", pad.num(10, 0), "\n")
}

#' Change a number into an English word
#'
#' @details See https://github.com/ateucher/useful_code/blob/master/R/numbers2words.r
#' See Function by John Fox found here: http://tolstoy.newcastle.edu.au/R/help/05/04/2715.html
#' @param x The number to convert
#' @param th Logical. If TRUE the *th* versions will be returned, e.g. 4 = fourth
#' @param cap.first Logical. Capitalize the first letter of the returned string?
#'
#' @return The English word representing the number
#' @export
#'
#' @examples
#' number.to.word(c(1000,2,3,10000001), th = TRUE, cap.first = TRUE)
number.to.word <- function(x = NA, th = FALSE, cap.first = FALSE){

    stopifnot(!is.na(x))

    helper <- function(x){
    digits <- rev(strsplit(as.character(x), "")[[1]])
    nDigits <- length(digits)
    if(nDigits == 1) as.vector(ones[digits])
    else if(nDigits == 2)
      if(x <= 19) as.vector(teens[digits[1]])
      else trim(paste(tens[digits[2]],
                      Recall(as.numeric(digits[1]))))
    else if (nDigits == 3) trim(paste(ones[digits[3]], "hundred and",
                                      Recall(makeNumber(digits[2:1]))))
    else {
      nSuffix <- ((nDigits + 2) %/% 3) - 1
      if (nSuffix > length(suffixes)) stop(paste(x, "is too large!"), call. = FALSE)
      trim(paste(Recall(makeNumber(digits[
        nDigits:(3 * nSuffix + 1)])),
        suffixes[nSuffix],"," ,
        Recall(makeNumber(digits[(3 * nSuffix):1]))))
    }
  }
  trim <- function(text){
    ## Tidy leading/trailing whitespace, space before comma
    text=gsub("^\ ", "", gsub("\ *$", "", gsub("\ ,",",",text)))
    ## Clear any trailing " and"
    text=gsub(" and$","",text)
    ##Clear any trailing comma
    gsub("\ *,$","",text)
  }
  makeNumber <- function(...) as.numeric(paste(..., collapse=""))
  ## Disable scientific notation
  opts <- options(scipen=100)
  on.exit(options(opts))
  ones <- c("", "one", "two", "three", "four", "five", "six", "seven",
            "eight", "nine")
  names(ones) <- 0:9
  teens <- c("ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
             "sixteen", " seventeen", "eighteen", "nineteen")
  names(teens) <- 0:9
  tens <- c("twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty",
            "ninety")
  names(tens) <- 2:9
  x <- round(x)
  suffixes <- c("thousand", "million", "billion", "trillion")
  if (!th & length(x) > 1) return(trim(sapply(x, helper)))
  j <- sapply(x, helper)
  if(th){
    j <- sapply(j, function(x){
      tmp <- strsplit(x, " ")[[1]]
      first <- tmp[-length(tmp)]
      last <- tmp[length(tmp)]
      if(last == "one"){
        last <- "first"
      }else if(last == "two"){
        last <- "second"
      }else if(last == "three"){
        last <- "third"
      }else if(last == "five"){
        last <- "fifth"
      }else if(last == "eight"){
        last <- "eighth"
      }else if(last == "nine"){
        last <- "ninth"
      }else if(last == "twelve"){
        last <- "twelfth"
      }else if(last == "twenty"){
        last <- "twentieth"
      }else if(last == "thirty"){
        last <- "thirtieth"
      }else if(last == "forty"){
        last <- "fortieth"
      }else if(last == "fifty"){
        last <- "fiftieth"
      }else if(last == "sixty"){
        last <- "sixtieth"
      }else if(last == "seventy"){
        last <- "seventieth"
      }else if(last == "eighty"){
        last <- "eightieth"
      }else if(last == "ninety"){
        last <- "ninetieth"
      }else{
        last <- paste0(last, "th")
      }
      tmp <- paste(c(first, last), collapse = " ")
      if(cap.first){
        tmp <- paste0(toupper(substr(tmp, 1, 1)), substr(tmp, 2, nchar(tmp)))
      }
      tmp
    })
  }
  j
}

#' Remove values from a named vector based on names
#'
#' @param vec A named vector
#' @param names A vector of names to remove from the vector `vec`
#'
#' @return The vector `vec` with items removed
#' @export
strip.columns <- function(vec, names){
  return(vec[!names(vec) %in% names])
}

#' Create a character vector used in the align argument of the [xtable::xtable()] command
#'
#' @details e.g. posterior output tables, reference point tables. Most tables really
#'
#' @param num The number of columns in the table
#' @param first.left Logical. Keep the first column left-justified. If FALSE, it will be justified
#' according to the `just` argument
#' @param just The justification to use for the columns, i.e. "r", "l", or "c"
#'
#' @return A character vector used in the align argument of the [xtable::xtable()] command
#' @export
get.align <- function(num,
                      first.left = TRUE,
                      just = "r"){

  if(first.left){
    align <- c("l", "l")
  }else{
    align <- c(just, just)
  }
  for(i in 1:(num-1)){
    align <- c(align, just)
  }
  return(align)
}

#' Create rich colors as RGB strings
#'
#' @param n The number of colors
#' @param alpha The transparency for all colors
#'
#' @return A vector of RGB strings representing rich colors
#' @export
#'
#' @examples
#' rich.colors.short(10)
rich.colors.short <- function(n, alpha = 1){

  x <- seq(0, 1, length = n)
  r <- 1/(1 + exp(20 - 35 * x))
  g <- pmin(pmax(0, -0.8 + 6 * x - 5 * x ^ 2), 1)
  b <- dnorm(x, 0.25, 0.15)/max(dnorm(x, 0.25, 0.15))
  rgb.m <- matrix(c(r, g, b), ncol = 3)
  apply(rgb.m, 1, function(v) rgb(v[1], v[2], v[3], alpha = alpha))
}

#' Plot bars
#'
#' @param x The x axis values (i.e., years)
#' @param y A data frame with columns:
#' value: estimate (point) to plot
#' lo: lower CI
#' hi: higher CI
#' @param gap
#' @param add
#' @param ciCol
#' @param ciLty
#' @param ciLwd
#' @param ...
#'
#' @return [base::invisible()]
#' @export
plotBars.fn <- function(x,
                        y,
                        scale = 1,
                        gap = 0,
                        add = FALSE,
                        ciCol = "black",
                        ciLty = 1,
                        ciLwd = 1,
                        ...) {

  y$value <- y$value / scale
  y$lo <- y$lo / scale
  y$hi <- y$hi / scale

  if(!add) plot(x, y$value, ...)
  if(add) points(x, y$value, ...)
  segments(x, y$lo, x, y$value - gap, col = ciCol, lty = ciLty, lwd = ciLwd)
  segments(x, y$hi, x, y$value + gap, col = ciCol, lty = ciLty, lwd = ciLwd)
  invisible()
}

#' Add a letter to the plot
#'
#' @param letter The letter to add
#'
#' @return [base::invisible()]
#' @export
panel.letter <- function(letter){

  usr <- par("usr")
  inset.x <- 0.05 * (usr[2] - usr[1])
  inset.y <- 0.05 * (usr[4] - usr[3])
  text(usr[1] + inset.x,
       usr[4] - inset.y,
       paste0("(", letter, ")"), cex = 1.0, font = 1)
}

#' Add a polygon to a plot
#'
#' @param yrvec A vector of years
#' @param lower A vector of lower CI values
#' @param upper A vector of upper CI values
#' @param color The color to make the polygon lines
#' @param shade.col The shade color to fill in the polygon with
#'
#' @return [base::invisible()]
#' @export
addpoly <- function(yrvec,
                    lower,
                    upper,
                    color = 1,
                    shade.col = NA){

  # max of value or 0
  lower[lower < 0] <- 0
  if(is.na(shade.col)){
    shade.col <- rgb(t(col2rgb(color)), alpha = 0.2 * 255, maxColorValue = 255)
  }
  polygon(x = c(yrvec, rev(yrvec)),
          y = c(lower, rev(upper)),
          border = NA,
          col = shade.col)
  lines(yrvec, lower, lty = 3, col = color)
  lines(yrvec, upper, lty = 3, col = color)
  invisible()
}

#' Calculates the selectivity from the random walk parameters in SS (option 17)
#'
#' @details -1000 means to set equal to 0. Assumes that this is all pars from age 0 to max age
#'
#' @param pars
#' @param devs
#' @param Phi
#' @param transform
#' @param bounds
#'
#' @return The selectivity
#' @export
randWalkSelex.fn <- function(pars,
                             devs = NULL,
                             Phi = 1.4,
                             transform = FALSE,
                             bounds = NULL) {

  logS <- rep(NA, length(pars))
  # first value is never estimated (age 0)
  logS[1] <- 0
  if(!is.null(devs)) {
    # transform parameters based on bounds
    for(a in 2:length(pars)) {
      if(!is.na(devs[a])) {
        # transformation was present in 2014-2017 models but no longer used in 2018
        if(transform){
          tmp <- log((bounds[2] - bounds[1] + 0.0000002) / (pars[a] - bounds[1] + 0.0000001) - 1) / (-2)
          tmp <- tmp + devs[a]
          pars[a] <- bounds[1] + (bounds[2] - bounds[1]) / (1 + exp(-2 * tmp))
        }else{
          ## in 3.30, there's no transformation, but the devs are scaled by the SE (Phi)
          pars[a] <- pars[a] + Phi * devs[a]
        }
      }
    }
  }
  for(a in 2:length(pars)) {
    ifelse(pars[a] == -1000, logS[a] <- 0, logS[a] <- logS[a - 1] + pars[a])
  }

  selex <- exp(logS - max(logS))
  selex[pars == -1000] <- 0
  selex
}

#' Get selectivity for a given year from all MCMC samples
#'
#' @param x
#' @param yr
#' @param bnds
#'
#' @return The selectivity
#' @export
selexYear.fn <- function(x, yr, bnds = c(-5, 9)) {

  # define mostly-empty matrix to store selectivity parameters for each mcmc sample
  selexPars <- matrix(c(-1000, 0, NA, NA, NA, NA, NA, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                      nrow = nrow(x), ncol = 16, byrow = TRUE)
  # define matrix to store deviation parameters for given year from each mcmc
  devsPars  <- matrix(NA, ncol = ncol(selexPars), nrow = nrow(x))

  ## columns of MCMC output which match names for base parameters
  tmp <- grep("AgeSel_P[1-9]_Fishery.1.", names(x))
  ## columns of MCMC output which match names for deviation parameters
  devsInd <- grep("AgeSel_P[1-9]_Fishery.1._DEVadd_[1-9]+", names(x))
  ## get all deviation parameters
  allDevsPars <- x[,devsInd]
  ## fill in matrix of selectivity parameters
  selexPars[,3:7] <- as.matrix(x[,tmp[!(tmp %in% devsInd)]])
  ## get column indices associated with deviation parameters
  devsInd <- grep(as.character(yr), names(x)[devsInd])
  if(length(devsInd) == 0){
    ## if year not found in names of deviation parameters, return NULL
    return(NULL)
  }
  devsPars[,3:7] <- as.matrix(allDevsPars[,devsInd])

  ## define empty matrix to store resulting selectivity
  selex <- matrix(NA, ncol = ncol(selexPars), nrow = nrow(x))
  ## for each year, combine base selectivity parameters and deviations to get selex
  for(i in 1:nrow(selexPars)) {
    selex[i,] <- randWalkSelex.fn(selexPars[i,], devsPars[i,], bounds = bnds)
  }
  selex
}

#' get.args
#'
#' @return a list of the argument values used in a function call
#'
#' @examples
#' eg <- function(a = 1, b = 2, c = 5){
#'   get.args()
#' }
#' eg()
#' eg(10, c = 20)
get.args <- function(){
    def.call <- sys.call(-1)
    def <- get(as.character(def.call[[1]]), mode="function", sys.frame(-2))
    act.call <- match.call(definition = def, call = def.call)
    def <- as.list(def)
    def <- def[-length(def)]
    act <- as.list(act.call)[-1]

    def.nm <- names(def)
    act.nm <- names(act)
    inds <- def.nm %in% act.nm
    out <- def
    out[inds] <- act
    out
}

#' Get a vector of the active parameter names for a model
#'
#' @param model A model object as returned from [load.ss.files()]
#'
#' @return A vector of the active parameter names for a model
#' @export
#'
#' @examples
#' get_active_parameter_names(base.model)
get_active_parameter_names <- function(model){
  params <- model$parameters
  params$Label[!is.na(params$Active_Cnt)]
}

#' Get the posterior values for the given regular expressions of parameter names
#'
#' @param model The SS model output as loaded by [load_ss_files()]
#' @param param_regex A vector of regular expressions used to extract data for parameter names.
#' If there are no matches, or more than one for any regular expression, the program will stop
#'
#' @return A list of posterior vectors, one for each of the regular expressions in `param_regex`
#' @export
#' @examples
#' get_posterior_data(base.model, "BH_steep")
#' get_posterior_data(base.model, "e")
#' get_posterior_data(base.model, "asdfg")
#' get_posterior_data(base.model, c("NatM", "SR_LN", "SR_BH_steep", "Q_extraSD"))
get_posterior_data <- function(model, param_regex){

  mcmc <- model$mcmc
  if(length(mcmc) == 1 && is.na(mcmc)){
    return(NA)
  }

  params <- model$parameters
  posts_list <- list()

  for(i in seq_along(param_regex)){
    parind <- grep(param_regex[i], params$Label)
    if(length(parind) < 1){
      stop("The regular expression ", param_regex[i], " matched no parameter names", call. = FALSE)
    }
    if(length(parind) > 1){
      stop("The regular expression ", param_regex[i], " matched more than one (", length(parind),
           ") parameter names", call. = FALSE)
    }
    postparname <- params[parind, ]$Label
    message("The regular expression matched ", postparname)

    # Figure out which column of the mcmc output contains the parameter
    jpar <- grep(param_regex[i], names(mcmc))
    if(length(jpar) == 1){
      posts_list[[i]] <- mcmc[ ,jpar]
    }else{
      warning("Parameter ", postparname, " not found in posteriors")
      posts_list[[i]] <- NA
    }
  }

  #if(length(posts_list) == 1){
  #  posts_list <- posts_list[[1]]
  #}
  posts_list
}

#' Get the prior and MLE values for the given regular expressions of parameter names
#'
#' @param model The SS model output as loaded by [load_ss_files()]
#' @param param_regex A vector of regular expressions used to extract data for parameter names.
#' If there are no matches, or more than one for any regular expression, the program will stop
#'
#' @return A list of prior and MLE data, one for each of the regular expressions in `param_regex`
#' @export
#' @examples
#' get_prior_data(base.model, "BH_steep")
#' get_prior_data(base.model, "e")
#' get_prior_data(base.model, "asdfg")
#' get_prior_data(base.model, c("NatM", "SR_LN", "SR_BH_steep", "Q_extraSD"))
get_prior_data <- function(model, param_regex){

  stopifnot(class(param_regex) == "character")

  params <- model$parameters
  priors_list <- list()
  Pconst <- 0.0001

  for(i in seq_along(param_regex)){
    parind <- grep(param_regex[i], params$Label)
    if(length(parind) < 1){
      stop("The regular expression ", param_regex[i], " matched no parameter names", call. = FALSE)
    }
    if(length(parind) > 1){
      stop("The regular expression ", param_regex[i], " matched more than one (", length(parind),
           ") parameter names", call. = FALSE)
    }
    parline <- params[parind, ]
    message("The regular expression matched ", parline$Label)
    initval <- parline$Init
    finalval <- parline$Value
    parsd <- parline$Parm_StDev

    Pmin <- parline$Min
    Pmax <- parline$Max

    Ptype <- ifelse(is.na(parline$Pr_type), "Normal", parline$Pr_type)
    Psd <- parline$Pr_SD
    Pr <- parline$Prior
    Pval <- seq(Pmin, Pmax, length = nrow(model$mcmc))

    if(Ptype == "Log_Norm"){
      Prior_Like <- 0.5 * ((log(Pval) - Pr) / Psd) ^ 2
    }else if(Ptype == "Full_Beta"){
      mu <- (Pr - Pmin) / (Pmax - Pmin);  # CASAL's v
      tau <- (Pr - Pmin) * (Pmax - Pr) / (Psd ^ 2) - 1.0
      Aprior <- tau * (1 - mu)  # CASAL's m and n
      Bprior <- tau * mu
      if(Aprior <= 1.0 | Bprior <= 1.0) {
        warning("Bad Beta prior for parameter ", parline$Label)
      }
      Prior_Like <- (1.0 - Bprior) * log(Pconst + Pval - Pmin) +
        (1.0 - Aprior) * log(Pconst + Pmax - Pval) -
        (1.0 - Bprior) * log(Pconst + Pr - Pmin) -
        (1.0 - Aprior) * log(Pconst + Pmax - Pr)
    }else if(Ptype == "No_prior"){
      Prior_Like <- rep(0.0, length(Pval))
    }else if(Ptype == "Normal"){
      Prior_Like <- 0.5*((Pval - Pr) / Psd) ^ 2
    }else{
      warning("No prior found for parameter ", parline$Label)
      Prior_Like <- NA
    }

    prior <- NA
    if(!is.na(Prior_Like[1])){
      prior <- exp(-1 * Prior_Like)
    }

    if(!is.na(parsd) && parsd > 0){
      mle <- dnorm(Pval, finalval, parsd)
      mlescale <- 1 / (sum(mle) * mean(diff(Pval)))
      mle <- mle * mlescale
    }

    priors_list[[i]] <- list(initval = initval,
                             finalval = finalval,
                             parsd = parsd,
                             Pmin = Pmin,
                             Pmax = Pmax,
                             Ptype = Ptype,
                             Psd = Psd,
                             Pr = Pr,
                             Pval = Pval,
                             prior = prior,
                             mle = mle)

  }
  # if(length(priors_list) == 1){
  #   priors_list <- priors_list[[1]]
  # }
  priors_list
}

#' Split the posteriors data frame in a list of N data frames based on `from_to`
#'
#' @param df A data frame containing rows to split
#' @param from_to A data frame with the columns `from` and `to` which indicat the
#' rows from and to for each data frame
#'
#' @return Aa list of data frames of the same length as the number of rows in `from_to`
#' @export
#'
#' @examples
#' split_df(base.model, tibble(from = c(1, 100), to = c(101, 200)))
split_df <- function(df, from_to){
  stopifnot(nrow(df) >= max(from_to))
  pmap(from_to, ~{df[.x:.y,]})
}

#' Calculate and insert columns containing arbitrary quantiles for a particular column
#'
#' @description Calculate and insert columns containing arbitrary quantiles for a particular column
#'
#' @param df A [data.frame]
#' @param col A column name on which to perform the calculations. Must be in `df` or an error
#' will be thrown
#' @param probs A vector of quantile probabilities to pass to [stats::quantile()]
#' @param include_mean If TRUE, include the mean in the output
#'
#' @return A [data.frame] with a new column for each value in the `probs` vector
#' @importFrom purrr set_names
#' @export
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(purrr)
#' pq <- tribble(
#'   ~year, ~grp, ~val,
#'   2000,    1,  2.1,
#'   2001,    1,  3.4,
#'   2002,    1,  4.5,
#'   2003,    1,  5.6,
#'   2004,    1,  6.7,
#'   2000,    2,  3.1,
#'   2001,    2,  4.4,
#'   2002,    2,  5.5,
#'   2003,    2,  6.6,
#'   2004,    2,  8.7,
#'   2000,    3, 13.1,
#'   2001,    3, 14.4,
#'   2002,    3, 15.5,
#'   2003,    3, 16.6,
#'   2004,    3, 18.7)
#'
#' probs <- c(0.05, 0.25, 0.5, 0.75, 0.95)
#'
#' yrs <- sort(unique(pq$year))
#' df <- pq %>%
#'   group_by(year) %>%
#'   group_map(~ calc_quantiles(.x, col = "val", probs = probs)) %>%
#'   map_df(~{.x}) %>%
#'   mutate(year = yrs) %>%
#'   select(year, everything())
calc_quantiles <- function(df = NULL,
                           col = NULL,
                           probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
                           include_mean = TRUE){
  
  stopifnot(col %in% names(df))
  stopifnot(class(df[[col]]) == "numeric")
  col_sym <- sym(col)
  out <- summarize_at(df,
                      vars(!!col_sym),
                      map(probs,
                          ~partial(quantile, probs = .x, na.rm = TRUE)) %>%
                        set_names(probs))
  
  if(include_mean){
    out <- out %>%
      mutate(avg = mean(df[[col]]))
  }
  out
}

#' Calculate quantiles across groups for a given column
#'
#' @description Calculate quantiles across groups for a given column
#'
#' @rdname calc_quantiles
#'
#' @param df A [data.frame] with columns with names given by `grp_col` and `col`
#' @param grp_col The column name to use for grouping the data
#' @param col The column name to use as values to calculate quantiles for
#' @param probs A vector of quantiles to pass to [stats::quantile()]
#' @param include_mean If TRUE, include the mean in the output
#' @param grp_names The column name to use for labeling the grouped column. By default it is the same as the
#' grouping column (`grp_col`).
#'
#' @return A [data.frame] containing the quantile values with one row per group represented by `grp_col`
#' @importFrom rlang sym
#' @export
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(purrr)
#' pq <- tribble(
#'   ~year, ~grp, ~val,
#'   2000,    1,  2.1,
#'   2001,    1,  3.4,
#'   2002,    1,  4.5,
#'   2003,    1,  5.6,
#'   2004,    1,  6.7,
#'   2000,    2,  3.1,
#'   2001,    2,  4.4,
#'   2002,    2,  5.5,
#'   2003,    2,  6.6,
#'   2004,    2,  8.7,
#'   2000,    3, 13.1,
#'   2001,    3, 14.4,
#'   2002,    3, 15.5,
#'   2003,    3, 16.6,
#'   2004,    3, 18.7)
#'
#' probs <- c(0.05, 0.25, 0.5, 0.75, 0.95)
#'
#' j <- calc_quantiles_by_group(pq,
#'                              grp_col = "year",
#'                              col = "val",
#'                              probs = probs)
calc_quantiles_by_group <- function(df = NULL,
                                    grp_col = NULL,
                                    col = NULL,
                                    grp_names = grp_col,
                                    probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
                                    include_mean = TRUE){
  
  stopifnot(grp_col %in% names(df))
  stopifnot(col %in% names(df))
  
  grp_col_sym <- sym(grp_col)
  grp_names_sym <- sym(grp_names)
  col_sym <- sym(col)
  grp_vals <- unique(df[[grp_names]])
  
  df %>%
    group_by(!!grp_col_sym) %>%
    group_map(~ calc_quantiles(.x, col = col, probs = probs, include_mean = include_mean)) %>%
    map_df(~{.x}) %>%
    mutate(!!grp_names_sym := grp_vals) %>%
    select(!!grp_names_sym, everything()) %>%
    ungroup()
}

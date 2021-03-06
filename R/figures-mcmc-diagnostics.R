#' Make a Posterior plot with optional prior, MLE, and initial value
#'
#' @param prior_mle Output from [get_prior_data()]
#' @param posterior Output from [get_posterior_data()]
#' @param show_prior Logical. Show the prior on the plot
#' @param show_init Logical. Show the initial value on the plot
#' @param show_mle Logical. Show the MLE on the plot
#' @param show_legend Logical. Show the legend on the plot
#' @param title_text Title over the plot
#' @param hist_breaks The length of the breaks vector for making the histogram
#' (Number of bins)
#'
#'
#' @return Nothing
#' @export
#'
#' @examples
#' prior_mle <- get_prior_data(model, "BH_steep")
#' post <- get_posterior_data(model, "BH_steep")
#' make_mcmc_priors_vs_posts_plot(prior_mle, post)
make_mcmc_priors_vs_posts_plot <- function(prior_mle,
                                           posterior,
                                           show_prior = TRUE,
                                           show_init = TRUE,
                                           show_mle = TRUE,
                                           show_legend = FALSE,
                                           title_text = "",
                                           hist_breaks = 50){

  dat <- posterior %>%
    enframe() %>%
    mutate(prior = prior_mle$prior) %>%
    rename(post = value)

  breakvec <- seq(prior_mle$Pmin, prior_mle$Pmax, length = hist_breaks)
  if(min(breakvec) > min(dat$post)) breakvec <- c(min(dat$post), breakvec)
  if(max(breakvec) < max(dat$post)) breakvec <- c(breakvec, max(dat$post))
  posthist <- hist(dat$post, plot = FALSE, breaks = breakvec)
  postmedian <- median(dat$post)

  ymax <- max(posthist$density)
  xmin <- min(posthist$mids)
  xmax <- max(posthist$mids)

  prior <- prior_mle$prior / (sum(prior_mle$prior) * mean(diff(prior_mle$Pval)))
  ymax <- ifelse(show_prior, max(prior, ymax), ymax)
  if(show_prior){
    if(prior_mle$Ptype == "Normal"){
      # This is a hack. The DM prior was set from -5 to 20 but are centered around 0
      xmin <- prior_mle$Pmin
      xmax <- abs(prior_mle$Pmin)
    }else{
      xmin <- min(prior_mle$Pval, xmin)
      xmax <- max(prior_mle$Pval, xmin)
    }
  }

  ymax <- ifelse(show_mle, max(prior_mle$mle, ymax), ymax)
  xmin <- ifelse(show_mle, min(qnorm(0.001, prior_mle$finalval, prior_mle$parsd), xmin), min(prior_mle$finalval, xmin))
  xmax <- ifelse(show_mle, max(qnorm(0.999, prior_mle$finalval, prior_mle$parsd), xmax), max(prior_mle$finalval, xmax))

  xmin <- ifelse(show_init, min(prior_mle$initval, xmin), xmin)
  xmax <- ifelse(show_init, max(prior_mle$initval, xmax), xmax)

  plot(0,
       type = "n",
       xlim = c(xmin, xmax),
       ylim = c(0, 1.1 * ymax),
       xaxs = "i",
       yaxs = "i",
       xlab = "",
       ylab = "",
       main = title_text,
       cex.main = 1,
       axes = FALSE)
  axis(1)

  colvec <- c("blue", "red", "black", "gray60", rgb(0, 0, 0, 0.5))
  ltyvec <- c(1, 1, 3, 4)

  plot(posthist,
       add = TRUE,
       freq = FALSE,
       col = colvec[4],
       border = colvec[4])
  abline(v = postmedian,
         col = colvec[5],
         lwd = 2,
         lty = ltyvec[3])

  if(show_prior){
    lines(prior_mle$Pval,
          prior,
          lwd = 2,
          lty = ltyvec[2])
  }

  if(show_mle){
    if(!is.na(prior_mle$parsd) && prior_mle$parsd > 0){
      mle <- dnorm(prior_mle$Pval,
                   prior_mle$finalval,
                   prior_mle$parsd)
      mlescale <- 1 / (sum(mle) * mean(diff(prior_mle$Pval)))
      mle <- mle * mlescale
      ymax <- max(ymax, max(mle))
      lines(prior_mle$Pval,
            mle,
            col = colvec[1],
            lwd = 1,
            lty = ltyvec[1])
      lines(rep(prior_mle$finalval, 2),
            c(0,
              dnorm(prior_mle$finalval,
                    prior_mle$finalval,
                    prior_mle$parsd) * mlescale),
            col = colvec[1],
            lty = ltyvec[1])
    }
  }

  if(show_init){
    par(xpd = NA) # stop clipping
    points(prior_mle$initval, -0.02 * ymax, col = colvec[2], pch = 17, cex = 1.2)
    par(xpd = FALSE)
  }

  box()

  if(show_legend){
    showvec <- c(show_prior, show_mle, show_init)
    legend("topleft",
           cex = 1.2,
           bty = "n",
           pch = c(NA, NA, 15, NA, 17)[showvec],
           lty = c(ltyvec[2],
                   ltyvec[1],
                   NA,
                   ltyvec[3],
                   NA)[showvec],
           lwd = c(2, 1, NA, 2, NA)[showvec],
           col = c(colvec[3],
                   colvec[1],
                   colvec[4],
                   colvec[5],
                   colvec[2])[showvec],
           pt.cex = c(1, 1, 2, 1, 1)[showvec],
           legend = c("prior",
                      "max. likelihood",
                      "posterior",
                      "posterior median",
                      "initial value")[showvec])
  }
}

#' Make a grid of key posterior plots
#'
#' @param model The SS model output as loaded by [load_ss_files()]
#' @param posterior_regex A vector of regular expressions which can be matched to parameter names. Use
#' [get_active_parameter_names()] to see all active parameter names
#' @param ncol Number of columns for the grid of plots
#' @param nrow Number of rows for the grid of plots
#' @param byrow Logical. If TRUE, order the plots by row, then column
#' @param show_legend Logical. Show the legend on the plot
#' @param legend_panel Which panel to show the legend on if `show_legend` is TRUE
#' @param titles A vector of titles for the plots
#' @param ... Parameters to be passed to [make_mcmc_priors_vs_posts_plot()]
#'
#' @return Nothing
#' @export
#'
#' @examples
#' make_key_posteriors_mcmc_priors_vs_posts_plot(base.model,
#'                                               key.posteriors,
#'                                               ncol = 2,
#'                                               nrow = 2,
#'                                               show_legend = TRUE,
#'                                               legend_panel = 3,
#'                                               titles = key.posteriors.titles)
make_key_posteriors_mcmc_priors_vs_posts_plot <- function(model,
                                                          posterior_regex,
                                                          hist_breaks = rep(50, length(posterior_regex)),
                                                          ncol = 1,
                                                          nrow = 1,
                                                          byrow = TRUE,
                                                          show_legend = FALSE,
                                                          legend_panel = 1,
                                                          titles = NULL,
                                                          ...){
  stopifnot(length(hist_breaks) == length(posterior_regex))
  if(ncol * nrow != length(posterior_regex)){
    stop("The length of the posterior_regex vector (", length(posterior_regex),
         ") is not equal to nrow (", nrow, ") * ncol (", ncol, ")", call. = FALSE)
  }
  oldpar <- par("mar", "mfrow")
  on.exit(par(oldpar))

  priors_mle <- get_prior_data(model, posterior_regex)
  posts <- get_posterior_data(model, posterior_regex)

  par(mfrow = c(nrow, ncol), mar = c(3, 3, 1, 1))
  for(i in seq_along(posterior_regex)){
    make_mcmc_priors_vs_posts_plot(priors_mle[[i]],
                                   posts[[i]],
                                   show_legend = ifelse(i == legend_panel, TRUE, FALSE),
                                   title_text = ifelse(is.null(titles), "", titles[i]),
                                   hist_breaks = hist_breaks[i],
                                   ...)
  }
}

#' Plot MCMC diagnostics
#'
#' @details Top left panel is traces of posteriors across iterations, top right is
#' cumulative running mean with 5th and 95th percentiles, bottom left is
#' autocorrelation present in the chain at different lag times (i.e., distance between samples in
#' the chain), and bottom right is distribution of the values in the chain (i.e., the marginal
#' density from a smoothed histogram of values in the trace plot).
#'
#' @param model A model object as output by [load_ss_models()]
#' @param posterior.regex  A regular experession represting a parameter as it appears in the SS output column
#' @param posterior.name  A name to show for the poosterior on the plot
#'
#' @return A 4-panel plot of MCMC diagnostics
#' @export
#' @importFrom coda traceplot
#' @importFrom gtools running
make.mcmc.diag.plot <- function(model,
                                posterior.regex = NULL,
                                posterior.name = NULL){
  stopifnot(!is.null(posterior.regex),
            !is.null(posterior.name),
            length(posterior.regex) == length(posterior.name == 1))
  oldpar <- par("ann", "mar", "oma", "mfrow")
  on.exit(par(oldpar))

  m <- model$mcmc

  mc_obj <- mcmc(select(m, matches(posterior.regex)) %>% as_tibble())
  label <- posterior.name
  par(mar = c(5, 3.5, 0, 0.5),
      oma = c(0, 3.0, 0.2, 0),
      mfrow = c(2, 2),
      ann = TRUE)

  ## Top left
  coda::traceplot(mc_obj, smooth = TRUE, main = "")
  mtext("Value", side = 2, line = 3, font = 1, cex = 0.8)
  ## Top right
  lowest <- min(mc_obj)
  highest <- max(mc_obj)
  draws <- length(mc_obj)
  plot(c(seq(1, draws, by = 1)),
       c(lowest, rep(c(highest),
                     (draws - 1))),
       xlab = "Iterations",
       ylab = "",
       yaxt = "n",
       type = "n")
  lines(running(mc_obj,
                fun = median,
                allow.fewer = TRUE,
                width = draws))
  fun <- function(x, prob){
    quantile(x, probs = prob, names = FALSE)
  }
  lines(running(mc_obj,
                fun = fun,
                prob = 0.05,
                allow.fewer = TRUE,
                width = draws),
        col = "GREY")
  lines(running(mc_obj,
                fun = fun,
                prob = 0.95,
                allow.fewer = TRUE,
                width = draws),
        col = "GREY")
  ## Bottom left
  par(ann = FALSE)
  attr(mc_obj, "dimnames")[[2]] <- ""
  autocorr.plot(mc_obj,
                auto.layout = FALSE,
                lag.max = 20,
                ask = FALSE)
  mtext("Autocorrelation", side = 2, line = 3, font = 1, cex = 0.8)
  mtext("Lag", side = 1, line = 3, font = 1, cex = 0.8)
  lines(seq(1, 20, by = 1), rep(0.1, 20), col = "GREY")
  lines(seq(1, 20, by = 1), rep(-0.1, 20), col = "GREY")
  ## Bottom right
  densplot(mc_obj, show.obs = TRUE)
  mtext("Density", side = 2, line = 2, font = 1, cex = 0.8)
  mtext("Value", side = 1, line = 3, font = 1, cex = 0.8)


  mtext(label, side = 2, outer = TRUE, line = 1.3, cex = 1.1)
}



##' Wrapper to call `make.mcmc.diag.plot()` but first check if parameter is estimated
##'
##' Needed in `adnuts-diagnostics-one-model.rnw` to not generate an error when
##' the file is applied to a model for which `.posterior.name` is not estimated
##' (e.g. for the sensitivities in which steepness is fixed, obviously steepness
##' is not estimated).
##'
##' @param .model A model object as output by [load_ss_models()]
##' @param .posterior.regex  A regular experession represting a parameter as it appears in the SS output column
##' @param .posterior.name  A name to show for the poosterior on the plot
##'
##' @return Either NULL if the parameter is not estimated, or the 4-panel
##'   plot of MCMC diagnostics from `make.mcmc.diag.plot()`
##' @export
##' @author Andrew Edwards
##' @examples
##' @donttest{
##' # See adnuts-diagnostics-one-model.rnw
##' }
make.mcmc.diag.plot.if.exists <- function(.model,
                                          .posterior.regex,
                                          .posterior.name){
  posterior_check <- select(.model$mcmc,
                            matches(.posterior.regex))
  if(ncol(posterior_check) == 0){
    return()
  }

  # Can have two matches, have to manually decide here
  if(ncol(posterior_check) > 1){
    if("Q_extraSD_Age1_Survey(3)" %in% names(posterior_check)){
      .posterior.regex <- "Q_extraSD_Age1_Survey"
      .posterior.name <- "Age-1 survey extra SD"
    } else {
      stop(paste0("Need to decide which posterior to show in
             make.mcmc.diag.plot.if.exists() for model run ",
             .model$path))
    }
  }

  make.mcmc.diag.plot(model = .model,
                      posterior.regex = .posterior.regex,
                      posterior.name = .posterior.name)
}

panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...){
  ## From ?pairs, to add correlation values to pairs plot, AME changing final
  ##  term from r to sqrt(r):
  usr <- par("usr")
  on.exit(par(usr))

  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste0(prefix, txt)
  if(missing(cex.cor)) cex.cor <- 0.8 / strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * sqrt(r))
}

#' Plot pairs for MCMC posteriors
#'
#' @param model A model object as output by [load_ss_models()]
#' @param inc.key.params If TRUE, use the arguments `key.posteriors.regex` and `key.posteriors.names`
#' @param key.posteriors.regex  A vector of regular experessions represting key posteriors
#' @param key.posteriors.names  A vector of names to show for the key posteriors
#' @param recr A vector of recruitment deviation years to include if `inc.key.params` is FALSE
#' @param bratio A vector of Bratio years to include if `inc.key.params` is FALSE
#' @param forecatch A vector of forecast catch years to include if `inc.key.params` is FALSE
#'
#' @return A pairs plot
#' @export
make.mcmc.diag.pairs.plot <- function(model,
                                      inc.key.params = TRUE,
                                      key.posteriors.regex = NULL,
                                      key.posteriors.names = NULL,
                                      recr = NULL,
                                      bratio = NULL,
                                      forecatch = NULL){

  m <- model$mcmc

  if(inc.key.params){
    lst <- lapply(seq_along(key.posteriors.regex), function(x){
      select(m, matches(key.posteriors.regex[x]))
    })
    par_estimated <- vector()    # check which key.posteriors are estimated
    par_estimated_number <- vector()    # check which key.posteriors end up with
                                        # two columns due to regex
    for(i in 1:length(key.posteriors.regex)){
      par_estimated[i] <- ncol(lst[[i]]) > 0
      par_estimated_number[i] <- ncol(lst[[i]])
    }

    # Manually fix the two columns issue when including Age1 Survey
    if(max(par_estimated_number) > 1){
      dupl <- which.max(par_estimated_number)   # which list containts duplicates
      if(sum(par_estimated_number == dupl)){
        stop("Multiple repeated column names, need to manually decide which to include.")
      }

      if("Q_extraSD_Age1_Survey(3)" %in%
         names(lst[[dupl]])){
        key.posteriors.names <- c(key.posteriors.names[1:dupl],
                                  "Age-1 survey extra SD",
                                  key.posteriors.names[(dupl+1):length(key.posteriors.names)])
      } else {
        stop(paste0("Need to decide which variables to show in
             make.mcmc.diag.pairs.plot() for model run ",
             model$path))
      }
    }

    obj_func_col <- select(m, contains("Objective_function"))
    df <- bind_cols(obj_func_col, lst)
    labels <- c("Objective\nFunction", key.posteriors.names[par_estimated])
    if(length(names(df)) != length(labels)){
      stop("Number of parameters estimated from key posteriors is wrong.")
    }
  }else{
    if(is.null(recr)){
      stop("If inc.key.params is FALSE, recr must not be null.",
           call. = FALSE)
    }
    rnames <- rownames(model$recruitpars) %>%
      enframe(name = NULL)
    recs <- bind_cols(rnames, as_tibble(model$recruitpars)) %>%
      filter(Yr %in% recr) %>%
      rename(Name = value)
    lst <- lapply(seq_along(recs$Name), function(x){
      select(m, contains(recs$Name[x]))
    })
    df <- bind_cols(select(m, contains("R0")), lst)
    labels <- c("Equilibrium\nrecruitment\nlog(R0)",
                paste("Recruit\ndev.", recr))
  }
  if(!is.null(recr) & inc.key.params){
    str <- paste0("Recr_", recr)
    lst <- lapply(seq_along(str), function(x){
      select(m, contains(str[x]))
    })
    df <- bind_cols(df, lst)
    labels <- c(labels, paste0("Recruitment\n", recr))
  }
  if(!is.null(bratio) & inc.key.params){
    str <- paste0("Bratio_", bratio)
    lst <- lapply(seq_along(str), function(x){
      select(m, contains(str[x]))
    })
    df <- bind_cols(df, lst)
    labels <- c(labels, paste0("Relative\nspawning\nbiomass\n", bratio))
  }
  if(!is.null(forecatch) & inc.key.params){
    str <- paste0("ForeCatch_", forecatch)
    lst <- lapply(seq_along(str), function(x){
      select(m, contains(str[x]))
    })
    df <- bind_cols(df, lst)
    labels <- c(labels, paste0("Default\nharvest\nin ", forecatch))
  }
  labels <- gsub(" +", "\n", labels)
  labels <- gsub("-", "-\n", labels)
  pairs(df,
        labels = labels,
        pch = ".",
        cex.labels = 1.2,
        xaxt = "n",
        yaxt = "n",
        las = 1,
        gap = 0.5,
        oma = c(0,0,0,0),
        lower.panel = panel.cor)
}

make.mcmc.survey.fit.plot <- function(model,         ## model is a model with an mcmc run which has the output of the
                                                     ##  r4ss package's function SSgetMCMC and has the extra.mcmc member
                                      start.yr,      ## Year to start the plot
                                      end.yr,        ## Year to end the plot
                                      surv.yrs,      ## Years in which the survey took place
                                      probs = c(0.025, 0.975), ## Confidence interval values lower and upper
                                      y.max = 5.5e6, ## maximum value for the y-axis
                                      samples = 1000, ## how many lines to show
                                      leg.cex = 1    ## Legend tect size
                                      ){
  ## Plot the fit of the model to the acoustic survey with 95% C.I.
  oldpar <- par()
  par(las = 1, mar = c(5, 4, 1, 1) + 0.1, cex.axis = 0.9)
  plot(0,
       type = 'n',
       xlim = c(start.yr-0.5, end.yr+0.5),
       xaxs = 'i',
       ylim = c(0, y.max),
       yaxs = 'i',
       axes = FALSE,
       xlab = "Year",
       ylab = "Biomass index (million t)")
  dat <- model$dat
  cpue <- dat$CPUE[dat$CPUE$index > 0,]
  segments(x0 = as.numeric(cpue$year),
           y0 = qlnorm(probs[1], meanlog = log(as.numeric(cpue$obs)), sdlog = as.numeric(cpue$se_log)),
           y1 = qlnorm(probs[2], meanlog = log(as.numeric(cpue$obs)), sdlog = as.numeric(cpue$se_log)),
           lwd = 3,
           lend = 1)

  # subsamble to help the lines be more visible
  nsamp <- ncol(model$extra.mcmc$cpue.table) # total samples
  subsample <- floor(seq(1, nsamp, length.out=samples)) # subset (floor to get integers)

  # lines showing expected survey values include in-between years
  # where no survey took place and therefore are not included in surv.yrs
  matplot(x = start.yr:end.yr,
          y = model$extra.mcmc$cpue.table[1:length(start.yr:end.yr), subsample],
          col = rgb(0, 0, 1, 0.03),
          type = 'l',
          add=TRUE,
          lty = 1)
  lines(x = start.yr:end.yr,
        y = model$extra.mcmc$cpue.median[1:length(start.yr:end.yr)],
        col = rgb(0, 0, 0.5, 0.7),
        lty = 1,
        lwd = 3)
  legend('topleft',
         legend = c("Observed survey biomass with\ninput (wide) and estimated (narrow) 95% intervals",
                    "Median MCMC estimate of expected survey biomass",
                    paste0("A subset (", samples, ") of the MCMC estimates of expected survey biomass")),
         lwd = c(NA,3,1),
         pch = c(21, NA, NA),
         bg = 'white',
         text.col = gray(0.6),
         col = c(1,
                 rgb(0, 0, 0.5, 0.7),
                 rgb(0, 0, 1, 0.4)),
         cex = leg.cex,
         bty = 'n')
  # Estimated interval with added uncertainty
  addedSE <- model$mcmc %>%
    summarise(across(starts_with("Q_extraSD"), ~median(.x)))
  arrows(
    x0 = as.numeric(cpue$year),
    x1 = as.numeric(cpue$year),
    y0 = qlnorm(probs[1], meanlog = log(as.numeric(cpue$obs)), sdlog = as.numeric(cpue$se_log) + addedSE[1,1]),
    y1 = qlnorm(probs[2], meanlog = log(as.numeric(cpue$obs)), sdlog = as.numeric(cpue$se_log) + addedSE[1,1]),
   length = 0.03, angle = 90, code = 3, col = "black"
  )
  # Observed points
  points(col = "black",
    x = model$cpue$Yr[model$cpue$Use==1],
    y = model$cpue$Obs[model$cpue$Use == 1],
    pch = 1)
  axis(1, at = model$cpue$Yr[model$cpue$Use==1], cex.axis = 0.8, tcl = -0.6)
  axis(1,
       at = (start.yr-4):(end.yr+7),
       lab = rep("", length((start.yr-4):(end.yr+7))),
       cex.axis = 0.8,
       tcl = -0.3)
  box()
  axis(2, at = (0:5)*1e6, lab = 0:5, las = 1)
  par <- oldpar
}

make.mcmc.catchability.plot <- function(model,
                                        model2 = NULL,
                                        hist_color = "grey60",
                                        hist_alpha = 0.5,
                                        med_color = "royalblue",
                                        mle_color = "royalblue",
                                        model2_med_color = "red",
                                        model2_mle_color = "red"){
  hist_color <- get.shade(hist_color, (1 - hist_alpha) * 100)
  par(mar = c(3, 3, 1, 1))
  hist(model$extra.mcmc$Q_vector,
       breaks = seq(0, 1.1 * max(model$extra.mcmc$Q_vector), 0.05),
       xlab = "Acoustic survey catchability (Q)",
       col = hist_color,
       border = hist_color,
       xaxs = 'i',
       yaxs = 'i',
       main = "")
  abline(v = median(model$extra.mcmc$Q_vector),
         col = med_color,
         lwd = 2,
         lty = 1)
  #abline(v = model$cpue$Calc_Q[1],
  #       col = mle_color,
  #       lwd = 2,
  #       lty = 2)
  if(!is.null(model2)){
    abline(v = median(model2$extra.mcmc$Q_vector),
           col = model2_med_color,
           lwd = 2,
           lty = 1)
    #abline(v = model2$cpue$Calc_Q[1],
    #       col = model2_mle_color,
    #       lwd = 2,
    #       lty = 2)
  }
  abline(h = 0)
}


## adapting from make.mcmc.survey.fit.plot:
## Plot of MCMC samples for projection years, to help understand Issue #747,
## just running as: make.mcmc.depletion.plot(base.model) and manually saving .png.
make.mcmc.depletion.plot <- function(model,         ## model is a model with an mcmc run which has the output of the
                                                    ##  r4ss package's function SSgetMCMC and has the extra.mcmc member
                                     start.yr = 2020,      ## Year to start the plot
                                                    ##  (currently will only plot 2020 to 2023)
                                     end.yr = 2023,        ## Year to end the plot
                                     y.max = 3,   ## maximum value for the y-axis
                                     samples = 1000,## how many lines to show
                                     leg.cex = 1    ## Legend tect size
                                     ){

  oldpar <- par()
  par(las = 1, mar = c(5, 4, 1, 1) + 0.1, cex.axis = 0.9)

  dat <- base.model$forecasts$`2021`$`01-0`$outputs[, c("Bratio_2020", "Bratio_2021", "Bratio_2022", "Bratio_2023")]

  if(is.null(y.max)){
    y.max <- max(max(dat))
  }

  plot(0,
       type = 'n',
       xlim = c(start.yr-0.5, end.yr+0.5),
       ylim = c(0, y.max),
       axes = FALSE,
       xlab = "Year",
       ylab = "Relative spawning biomass")

  # subsamble to help the lines be more visible
  nsamp <- nrow(dat)    # total samples
  subsample <- floor(seq(1, nsamp, length.out=samples)) # subset (floor to get integers)

  dat_sub <- dat[subsample, ]
  increase <- dat_sub$Bratio_2022 > dat_sub$Bratio_2021

  palepink <- rgb(1, 0, 0, 0.5)
  paleblue <- rgb(0, 0, 1, 0.2)
  colour <- rep(paleblue, length(increase))
  colour[increase] <- palepink      # pink if increasing

  matplot(x = start.yr:end.yr,
          y = t(dat_sub),
          col = colour,
          type = 'l',
          add=TRUE,
          lty = 1)
  box()
  axis(1, at = start.yr:end.yr) #cex.axis = 0.8, tcl = -0.6)
  axis(2, at = 0:5, las = 1)
  legend('topleft',
         legend = c(paste0(sum(increase),
                           " MCMC samples that increase from 2021 to 2022"),
                    paste0(sum(!increase),
                           " MCMC samples that decrease from 2021 to 2022")),
         col = c(palepink,
                 paleblue),
         lwd = 2,
         bty = 'n')
  par <- oldpar
  # To plot histograms shown in #747, put a browser here and these:
  # breaks_vec <- seq(-1.5, 1.5, by=0.05)
  # diff <- dat_sub[ , "Bratio_2022"] - dat_sub[ , "Bratio_2021"]
  #  # Difference in the medians (what you see on Figure i):
  # diff_med <- median(dat_sub[ , "Bratio_2022"]) - median(dat_sub[ ,
  #                                                               "Bratio_2021"])
  # median_change <- median(diff)   # median of the changes
  # hist(diff[increase],
  #     col=palepink, freq=TRUE, breaks=breaks_vec, main =
  #        "Relative spawning biomass in 2022 minus that in 2021",
  #        xlab="Change", xlim = c(-1.5, 1.5), ylim = c(0, 280))
  #hist(diff[!increase],
  #     col=paleblue, freq=TRUE, add=TRUE, breaks=breaks_vec)
  #abline(v = median_change, col = "magenta")
  #  # abline(v = diff_med, col = "magenta", lwd = 2) # doesn't really help
  #text(-1.65, 250, paste0("Median 2022 - median 2021 =", f(diff_med, 3)), pos=4)
  #text(-1.65, 220, paste0("Median change =", f(median_change, 3)), pos=4, col="magenta")
  #legend('topleft',
  #       legend = c(paste0(sum(increase),
  #                         " MCMC increasing samples"),
  #                  paste0(sum(!increase),
  #                         " MCMC decreases samples")),
  #       col = c(palepink,
  #               paleblue),
  #       lwd = 2,
  #       bty = 'n')
  # # sum(diff > median_change & diff < 0)  # 13.4% of samples are in here
}

## adapting from make.mcmc.depletion.plot, and values for make.recruitment.plot
## Plot of MCMC samples of recruitment, to help for Issue #820.
## just running as:
##   make.mcmc.recruitment.plot(base.model, start.yr = start.yr, equil.yr = unfished.eq.yr)
## and manually saving .png.
## make.mcmc.recruitment.plot(base.model, start.yr = 2006, equil.yr = unfished.eq.yr, samples = 100)
## make.mcmc.recruitment.plot(base.model, start.yr = 2006, equil.yr = unfished.eq.yr, samples = 100, rescale = TRUE)
## make.mcmc.recruitment.plot(base.model, start.yr = 1966, equil.yr = unfished.eq.yr, samples = NULL, rescale = TRUE, traceplot = FALSE)

make.mcmc.recruitment.plot <- function(model,         ## model is a model with an mcmc run which has the output of the
                                                    ##  r4ss package's function
                                                    ##  SSgetMCMC and has the extra.mcmc member
                                       equil.yr,
                                       start.yr,      ## Year to start the plot
                                       end.yr = 2023,        ## Year to end the plot
                                       y.max = NULL,   ## maximum value for the y-axis
                                       samples = 1000,## how many lines to show
                                       rescale = FALSE, ## whether to rescale by
                                                        ## a certain year's recruitment
                                       rescale.yr = 2010,  # year to rescale by if rescaling
                                       traceplot = TRUE   # do a traceplot of
                                         # MCMC samples else a median and 95%
                                         # interval plot
                                       ){
  oldpar <- par()
  par(las = 1, mar = c(5, 4, 1, 1) + 0.1, cex.axis = 0.9)

  dat <- as_tibble(model$mcmc) %>%
    select(paste0("Recr_", start.yr):paste0("Recr_", end.yr))


# browser()
  if(rescale){
    dat <- dat / dat$"Recr_2010"    # generalise ***
    if(is.null(y.max)){
      y.max <- 1.2                    # so will miss some super high ones, but
                                      # easier to see others
    }
    yLab <- "Age-0 recruits relative to those in 2010"    # generalise **
  } else {
    yLab <- "Age-0 recruits (billions)"
  }

  # subsamble to help the lines be more visible
  nsamp <- nrow(dat)    # total samples
  if(!is.null(samples)){
    subsample <- floor(seq(1, nsamp, length.out=samples)) # subset (floor to get
                                                          # integers)
    dat_sub <- dat[subsample, ]
  } else {                                                # no subsampling
    dat_sub <- dat
  }

  if(is.null(y.max)){
    y.max <- max(max(dat_sub) * 0.8)  # so will miss some super high ones, but
                                      # easier to see others
  }

  plot(0,
       type = 'n',
       xlim = c(start.yr-0.5, end.yr+0.5),
       ylim = c(0, y.max),
       axes = FALSE,
       xlab = "Year",
       ylab = yLab)

  abline(h = 0, col = "lightgrey")
  paleblue <- rgb(0, 0, 1, 0.2)

  if(traceplot){
    matplot(x = start.yr:end.yr,
            y = t(dat_sub),
            col = paleblue,
            type = 'l',
            add=TRUE,
            lty = 1)
  } else {        # medians and intervals

    lower <- apply(dat_sub, 2, quantile, probs = 0.025)
    medians <- apply(dat_sub, 2, median)
    upper <- apply(dat_sub, 2, quantile, probs = 0.975)

    yrs <- start.yr:end.yr
    points(yrs, medians, pch = 20)
    segments(x0 = yrs,
             y0 = lower,
             x1 = yrs,
             y1 = upper,
             col = "blue")
  }

  box()
  axis(1, at = start.yr:end.yr) #cex.axis = 0.8, tcl = -0.6)
  axis(2)  #, at = 0:5, las = 1)
  par <- oldpar
}

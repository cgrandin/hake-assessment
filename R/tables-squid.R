make.recr.dev.uncertainty.table <- function(models,
                                            model.names,
                                            assess.yr,
                                            age = 2,
                                            cohorts = c(2010, 2014, 2016),
                                            digits = 3,
                                            xcaption   = "default",
                                            xlabel = "default",
                                            font.size = 9,
                                            space.size = 10,
                                            placement = "H"){
  ## Return xtable with recruitment values by cohort with uncertainty
  ## with the models compared

  tab <- lapply(1:length(models),
                function(x){
                  k <- lapply(cohorts, function(yr){
                    j <- models[[x]]$retros[[assess.yr - yr - 2]]$recruitpars %>%
                      dplyr::filter(grepl(paste0("^.*RecrDev_",
                                          yr,
                                          "$"), rownames(.))) %>%
                      select(-c(type, Yr)) %>%
                      transmute(Cohort = yr,
                                Value,
                                `Log(SD)` = Parm_StDev)
                    j[-1] <- f(j[-1], digits)
                    names(j) <- latex.bold(names(j))
                    j
                  })
                  kk <- do.call(rbind, k)
                  if(x > 1){
                    kk <- kk[,-1]
                  }
                  kk
                })
  tab <- do.call(cbind, tab)
  tab[,1] <- as.character(tab[,1])

  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  addtorow$pos[[2]] <- 0

  addtorow$command <- paste0(latex.cline(paste0("1-", ncol(tab))),
                             latex.mcol(3,
                                        "c",
                                        latex.bold(model.names[1])))
  for(i in 1:(length(models) - 1)){
    addtorow$command <- paste0(addtorow$command,
                               latex.amp(),
                               latex.mcol(2,
                                          "|c",
                                          latex.bold(model.names[i + 1])))
  }
  addtorow$command <- paste0(addtorow$command,
                             latex.nline,
                             latex.cline(paste0("1-", ncol(tab))))
  addtorow$command <- c(addtorow$command, latex.cline(paste0("1-", ncol(tab))))
  size.string <- latex.size.str(font.size, space.size)
  print(xtable(tab,
               caption = xcaption,
               label = xlabel,
               align = get.align(ncol(tab))),
        caption.placement = "top",
        include.rownames = FALSE,
        sanitize.text.function = function(x){x},
        size = size.string,
        add.to.row = addtorow,
        table.placement = placement,
        tabular.environment = "tabularx",
        width = "\\textwidth",
        hline.after = NULL)
}



library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
#para usar yday.leap -> pasando de bisiestos
#library(meteologica)


rm(list=ls())

yday_leap <- function(x){
    bisiesto <- leap_year(x)
    dia <- yday(x)
    return(ifelse(bisiesto & dia>=60, dia-1,dia))
}

anho <- 2015

# Read temp record --------------------------------------------------------

data1 <- readRDS(file='data/salamanca.rds')

# solo una de las dos
data <- data1[[1]]

data <- data %>% mutate(ndia=yday_leap(fecha_obs))

# Saco el año problema del registro
yprob <- data %>% filter(year(fecha_obs)==anho)
# El registro serán todos los años hasta el problema
record <- data %>% filter(year(fecha_obs)<anho)

# Temperatura Media Diaria

# Por día del año: más alta del registro, más baja, intervalo de confianza del 95% de la media por dia.
record_st <- record %>% group_by(ndia) %>% dplyr::summarise(rechigh=max(tempmed, na.rm=T),
                                                            reclow=min(tempmed, na.rm=T),
                                                            recmean=mean(tempmed, na.rm=T),
                                                            se_mean=sd(tempmed, na.rm=T)/sqrt(length(na.omit(tempmed))),
                                                            mean_upp=recmean + 2.101*se_mean,
                                                            mean_low=recmean - 2.101*se_mean,
                                                            n=n()
)

record_st <- record_st %>% mutate(fecha=as.POSIXct("2014-12-31") + days(ndia))


# Días del año problema con las temperaturas más altas o más bajas del registro: esto quizá es muy radical..

aux <- left_join(record_st %>% select(ndia, rechigh, reclow), yprob %>% select(ndia, tempmed, fecha_obs), by="ndia")

maximas <- aux %>% filter(tempmed>=rechigh)
minimas <- aux %>% filter(tempmed<=reclow)


# Chart -------------------------------------------------------------------

gr <- ggplot(data=record_st, aes(x=ndia))

# Theme

gr <- gr + theme(plot.background = element_blank(),
                 panel.grid.minor = element_blank(),
                 panel.grid.major = element_blank(),
                 panel.border = element_blank(),
                 panel.background = element_blank(),
                 axis.ticks = element_blank(),
                 #axis.text = element_blank(),  
                 axis.title = element_blank())

# Capa de valores max-min por dia del año
gr <- gr + geom_linerange(aes(x=ndia, ymin=reclow, ymax=rechigh), colour = "wheat2")

# Capa de valores normales por dia del año
gr <- gr + geom_linerange(aes(x=ndia, ymin=mean_low, ymax=mean_upp), colour = "wheat4")

# Datos del año problema

gr <- gr + geom_line(data=yprob, aes(x=ndia, y=tempmed))

# Pinto el ejeY a mano
gr <- gr + geom_vline(xintercept = 1, colour = "wheat4", linetype=1, size=1)

# Pintamos a mano las guías de la temp (en blanco)
AddGuiasH <- function(p, min=-15, max=35, int=5){
    
    for (i in seq(min, max, int)){
        p <- p + geom_hline(yintercept = i, colour = "white", linetype=1)
    }
    return(p)
}

gr <- AddGuiasH(gr, min=-10, max=30)

# Pintamos a mano las guías verticales (último día de mes)
AddGuiasV <- function(p){
    
    for (imes in 2:12){
        p <- p + geom_vline(xintercept=yday_leap(as.POSIXct("2014-12-01") + months(imes)), colour = "wheat4", linetype=3, size=.5)
    }
    # linea del 31 de diciembre
    p <- p + geom_vline(xintercept=yday_leap(as.POSIXct("2015-12-31")), colour = "wheat4", linetype=3, size=.5)
    
    return(p)
}

gr <- AddGuiasV(gr)

# Etiquetas de los ejes

# function to turn y-axis labels into degree formatted values
dgr_fmt <- function(x, ...) {
    parse(text = paste(x, "*degree", sep = ""))
}

yaxis_max <- 35
yaxis_min <- -15
int <- 5

# create y-axis variable
a <- dgr_fmt(seq(yaxis_min, yaxis_max, by=5))

# breaks de fechas en el 15 de cada mes
b <- yday_leap(as.POSIXct("2015-01-15") + months(0:11))
blb <- format((as.POSIXct("2015-01-15") + months(0:11)), format = "%B")

gr <- gr + coord_cartesian(ylim=c(yaxis_min, yaxis_max)) + 
    scale_y_continuous(breaks=seq(yaxis_min, yaxis_max, int), labels=a) +
    scale_x_continuous(breaks=b, labels=blb)


# ponemos las máximas y mínimas del registro total

if (nrow(maximas)>0){
    gr <- gr + geom_point(data=maximas, aes(x=ndia, y=tempmed), colour="red")
    # TO DO: etiqueta con la fecha de los días de máxima
}

if (nrow(minimas)>0){
    gr <- gr + geom_point(data=minimas, aes(x=ndia, y=tempmed), colour="blue")
}


# Textos varios





#!/usr/bin/env R

library(ggplot2)
library(dplyr)
library(reshape2)
library(sf)
library(stringr)
library(gridExtra)
library(scales)
library(GGally)
library(mandeR)
library(xtable)
library(ggrepel)


fips   <- list("01"="Alabama", "02"="Alaska", "04"="Arizona", "05"="Arkansas", "06"="California", "08"="Colorado", "09"="Connecticut", "10"="Delaware", "11"="District of Columbia", "12"="Florida", "13"="Georgia", "15"="Hawaii", "16"="Idaho", "17"="Illinois", "18"="Indiana", "19"="Iowa", "20"="Kansas", "21"="Kentucky", "22"="Louisiana", "23"="Maine", "24"="Maryland", "25"="Massachusetts", "26"="Michigan", "27"="Minnesota", "28"="Mississippi", "29"="Missouri", "30"="Montana", "31"="Nebraska", "32"="Nevada", "33"="New Hampshire", "34"="New Jersey", "35"="New Mexico", "36"="New York", "37"="North Carolina", "38"="North Dakota", "39"="Ohio", "40"="Oklahoma", "41"="Oregon", "42"="Pennsylvania", "44"="Rhode Island", "45"="South Carolina", "46"="South Dakota", "47"="Tennessee", "48"="Texas", "49"="Utah", "50"="Vermont", "51"="Virginia", "53"="Washington", "54"="West Virginia", "55"="Wisconsin", "56"="Wyoming", "60"="American Samoa", "66"="Guam", "69"="Commonwealth of the Northern Mariana Islands", "72"="Puerto Rico", "78"="U.S. Virgin Islands")
fipsab <- list("01"="AL", "02"="AK", "04"="AZ", "05"="AR", "06"="CA", "08"="CO", "09"="CN", "10"="DE", "11"="DC", "12"="FL", "13"="GA", "15"="HI", "16"="ID", "17"="IL", "18"="IN", "19"="IO", "20"="KA", "21"="KY", "22"="LA", "23"="ME", "24"="MD", "25"="MA", "26"="MI", "27"="MN", "28"="MS", "29"="MO", "30"="MT", "31"="NE", "32"="NV", "33"="NH", "34"="NJ", "35"="NM", "36"="NY", "37"="NC", "38"="ND", "39"="OH", "40"="OK", "41"="OR", "42"="PA", "44"="RI", "45"="SC", "46"="SD", "47"="TN", "48"="TX", "49"="UT", "50"="VT", "51"="VA", "53"="WA", "54"="WV", "55"="WI", "56"="WY", "60"="AS", "66"="GU", "69"="MP", "72"="PR", "78"="VI")

make_geoids_char <- function(x) {
  x <- as.character(x)
  str_pad(x, 4, pad = "0")
}

################################################################################
################################################################################

df <- read.csv('out_simplify_individually.csv')
#df <- df %>% filter(!(variable %in% c('area','perim'))) #Exclude area and perim
df$id <- make_geoids_char(df$id)

df$tol <- as.factor(df$tol)
#Set area and perim on a log scale
df <- df %>% mutate(value=ifelse(variable %in% c('area','perim'),log10(value),value))

data_summary <- function(x) {
   m    <- mean(x)
   ymin <- min(x)
   ymax <- max(x)
   return(c(y=m,ymin=ymin,ymax=ymax))
}



#############
#Poster image

if(!file.exists('fig_simplify_individually_poster.png')){
  p <-  ggplot(df, aes(x=id, y=value))+
        facet_wrap(~variable, scales='free', ncol=1)+
        scale_x_discrete()+
        stat_summary(fun.data=data_summary, geom="linerange")+
        geom_point(aes(color=tol))+
        #theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())+
        xlab("US Electoral District") +
        theme(axis.text.x = element_text(angle = 90, hjust = 0.5, size=5)) +
        guides(color=guide_legend(title="Simplification\nTolerance (m)"))+
        scale_colour_brewer(type="div", palette="RdYlGn", direction=-1)

  ggsave('fig_simplify_individually_poster.png', plot=p, height=10, width=30, limitsize=FALSE)
}

if(!file.exists('fig_simplify_individually_summary.pdf')){
  #df <- df %>% filter(!(variable %in% c('area','perim')))

  df2 <- df %>% filter(variable %in% c("CvxHullPS", "PolsbyPopp", "ReockPS"))
  #df2 <- df2 %>% arrange(tol) %>% group_by(id,variable) %>% mutate(value=value-first(value))

  p <- ggplot(df2, aes(x=tol, y=value))+
    facet_wrap(~variable, scales='free', ncol=1)+
    geom_boxplot()+
    #geom_violin()+
    xlab("Tolerance (m)") +
    ylab("Value")

  ggsave('fig_simplify_individually_summary.pdf', plot=p, height=4, width=4, limitsize=FALSE)
}


################################################################################
################################################################################


if(!file.exists('img/fig_simplify_together_summary.pdf')){
  #df <- df %>% filter(!(variable %in% c('area','perim')))

  df <- read.csv('out_simplify_together.csv', colClasses=c("character","character","character","character","double"))
  #df <- df %>% filter(!(variable %in% c('area','perim'))) #Exclude area and perim

  #Set area and perim on a log scale
  #df <- df %>% mutate(value=ifelse(variable %in% c('area','perim'),log10(value),value))

  df$res <- factor(df$res,c("500k","5m","20m"))

  df <- df %>% mutate(variable=replace(variable, variable=="ConvexHull", "CvxHullPT"))
  df <- df %>% mutate(variable=replace(variable, variable=="Reock",      "ReockPT"))

  df2 <- df %>% group_by(id,variable) %>% 
                arrange(res) %>% 
                mutate(sdiff=value-first(value)) %>% 
                filter(res!="500k") %>% 
                ungroup()  %>%
                filter(abs(sdiff)>0.01)
  df2 <- df2 %>% filter(!(variable=="perim" & sdiff>0)) #Should filter one entry



  #df2 <- df2 %>% mutate(variable=replace(variable, variable=="area", "log(area)")) %>%
  #               mutate(variable=replace(variable, variable=="perim", "log(perim)"))



  MakePlot <- function(var){
    df3 <- df2 %>% filter(variable==var)
    ggplot(df3, aes(x=res, y=sdiff)) + geom_violin() + xlab("") + ylab("") + ggtitle(var)
  }

  asinh_trans <- function(){
    trans_new(name = 'asinh', transform = function(x) asinh(x), 
              inverse = function(x) sinh(x))
  }

  p <- grid.arrange(
    MakePlot('area') + scale_y_log10(),
    MakePlot('perim') + scale_y_continuous(trans = 'asinh',breaks=c(-1e7,-1e5,-1e3)),
    MakePlot('CvxHullPT') + ylim(c(0,0.3)),
    MakePlot('ReockPT') + ylim(c(0,0.3)),
    MakePlot('PolsbyPopp') + ylim(c(0,0.3)),
    ncol=1
  )

  ggsave('imgs/fig_simplify_together_summary.pdf', plot=p, height=6, width=4, limitsize=FALSE)
}



# #Find scores which changed a bunch between different levels of resolution
# df2 <- df %>% arrange(res) %>% group_by(id,variable) %>% mutate(value=value-first(value))
# df2 <- df2 %>% filter(!(variable %in% c('area','perim'))) #Exclude area and perim
# df2 <- df2 %>% filter(variable %in% c('PolsbyPopp','ConvexHull')) 
# df2 <- df2 %>% group_by(id,variable) %>% 
#         mutate(diff=abs(max(value)-min(value))) %>%
#         select(id,variable,diff) %>%
#         arrange(desc(diff)) %>%
#         ungroup() %>%
#         distinct(id,variable,diff)

# most_changed <- df2$id %>% head(n=20) %>% unique()






################################################################################
################################################################################




if(!file.exists('imgs/fig_projections.pdf')){
  df <- read.csv('out_projections.csv', colClasses=c("character","character","character","character","double"))
  df <- df %>% filter(variable %in% c('CvxHullPS', 'CvxHullPT', 'PolsbyPopp', 'ReockPS', 'ReockPT', 'Schwartzbe'))
  df <- df %>% filter(proj!='input')
  df <- df %>% filter(ptype!='national')

  is_outlier <- function(v, coef=1.5){
    quantiles <- quantile(v,probs=c(0.25,0.75))
    IQR <- quantiles[2]-quantiles[1]
    res <- v < (quantiles[1]-coef*IQR)|v > (quantiles[2]+coef*IQR)
    return(res)
  }

  idredo <- function(x){
    paste0(fipsab[substr(x, 1, 2)],substr(x, 3, 4))
  }

  df <- df %>% group_by(ptype,variable) %>% mutate(label=ifelse(is_outlier(value) & abs(value-mean(value))>0.07, idredo(id), NA))


  p <- ggplot(df, aes(x=ptype, y=value, label=label))+
    scale_x_discrete()+
#    geom_point()+
    facet_wrap(~variable)+
    geom_boxplot(alpha=0.2, width=1, position = position_dodge(width = 1.5))+
    geom_text_repel()+
    xlab("")+
    ylab("Range Under Reprojection")+
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size=9))

  df %>% group_by(ptype,variable) %>% summarise(median=median(value), quant=quantile(value, probs=c(0.99)))

  ggsave('imgs/fig_projections.pdf', plot=p, width=3, height=4, limitsize=FALSE)
}




################################################################################
################################################################################

if(!file.exists('effect_of_topography.pdf')){
  df <- read.table('effect_of_topography.tbl', header=TRUE, colClasses=c("character","double","double","double","double"))
  df <- df %>% mutate(SAfromTopo=ifelse(SAfromTopo==0,1,SAfromTopo))
  df <- df %>% filter(SAwoTopo>0) %>% filter(SAwTopo>0)

  df <- df %>% mutate(Planar=4*pi*SAwoTopo/Perim/Perim, Topographic=4*pi*SAwTopo/Perim/Perim)
  df <- df %>% mutate(Diff=Topographic-Planar)
  df <- df %>% select(Dist,Diff)
  df <- melt(df, id.vars=c('Dist'))

  p <- ggplot(df, aes(x=variable, y=value))+
       geom_boxplot()+
       theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())+
       xlab("")+
       ylab("Difference in Score")

  ggsave('fig_effect_of_topography.pdf', plot=p, width=2, height=2, limitsize=FALSE)
}

# if(!file.exists('tl_diff_map.pdf')){
#   cd <- sf::read_sf('data/cb_2015_us_cd114_500k.shp')
#   tl <- sf::read_sf('data/tl_2015_us_cd114.shp')

#   cd <- sf::st_transform(cd,"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
#   tl <- sf::st_transform(tl,"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")

#   p<-ggplot()+geom_sf(fill=NA, color="red", data=tl)+
#            geom_sf(fill="gray",color="black",data=cd)+
#            coord_sf(crs=st_crs(cd), xlim=c(280000,1250000), ylim=c(500000,1250000))+
#            theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())+
#            theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())

#   ggsave('tl_diff_map.pdf', plot=p, width=2, height=2, limitsize=FALSE)
# }






################################################################################
################################################################################

if(!file.exists('fig_effect_of_borders.pdf')){
  df       <- read.table('scores.csv', header=TRUE) #TODO
  df$GEOID <- make_geoids_char(df$GEOID)

  diffs <- df %>% group_by(substr(GEOID,1,2)) %>% filter(n()>1)   %>% ungroup() %>%
                  mutate(CvxHull=abs(CvxHullPTB-CvxHullPT))       %>%
                  mutate(Reock=abs(ReockPTB-ReockPT))             %>%
                  select(GEOID,CvxHull,Reock)                     %>%
                  melt(id.vars=('GEOID'))                         %>%
                  filter(abs(value)>=0.01)

  table(diffs$variable)

  p <- ggplot(diffs, aes(x=variable,y=value)) + 
    geom_violin()+
    ylab("Difference in Score")+
    xlab("")

  ggsave('fig_effect_of_borders.pdf', plot=p, width=2, height=2, limitsize=FALSE)
}


################################################################################
################################################################################


if(!file.exists('fig_effect_of_definitions.pdf')){
  df       <- read.table('scores.csv', header=TRUE) #TODO
  df$GEOID <- make_geoids_char(df$GEOID)

  diffs <- df %>% group_by(substr(GEOID,1,2)) %>% filter(n()>1)  %>% ungroup() %>%
                  mutate(CvxHull=abs(CvxHullPT-CvxHullPS))       %>%
                  mutate(Reock=abs(ReockPT-ReockPS))             %>%
                  select(GEOID,CvxHull,Reock)                    %>%
                  melt(id.vars=('GEOID'))                        %>%
                  filter(abs(value)>=0.01)

  table(diffs$variable)

  p <- ggplot(diffs, aes(x=variable,y=value)) + 
    geom_violin()+
    ylab("Difference in Score")+
    xlab("")

  ggsave('fig_effect_of_definitions.pdf', plot=p, width=2, height=2, limitsize=FALSE)
}



################################################################################
################################################################################

#Electoral districts per state
df       <- read.table('scores.csv', header=TRUE) #TODO
df$GEOID <- make_geoids_char(df$GEOID)
df$STATEFP <- as.factor(df$STATEFP)

print("Histogrma of number of districts per state")
df2 <- df %>% select(STATEFP)      %>%
              group_by(STATEFP)    %>% 
              summarise(count=n()) %>%
              ungroup()            %>%
              group_by(count)      %>%
              summarise(n=n())



################################################################################
################################################################################

#Misaligned borders

if(!file.exists('fig_effect_of_misalignment.pdf')){
  df       <- read.table('scores.csv', header=TRUE) #TODO
  df$GEOID <- make_geoids_char(df$GEOID)
  df$STATEFP <- as.factor(df$STATEFP)

  df2 <- df %>% group_by(substr(GEOID,1,2)) %>% filter(n()>1)  %>% ungroup() %>%
                mutate(AreaUncertainty=100*AreaUncert/areaAH) %>% 
                select(GEOID,areaAH,AreaUncertainty)          %>%
                filter(areaAH>=1e8)                           %>%
                arrange(AreaUncertainty)

  p <- ggplot(df2, aes(x='', y=AreaUncertainty)) +
    geom_boxplot()+
    theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())+
    ylab("% Uncertainty in Area")+
    xlab("")


  ggsave('fig_effect_of_misalignment.pdf', plot=p, width=2, height=2, limitsize=FALSE)
}






if(!file.exists('imgs/fig_score_order.pdf')){
  df         <- read.table('scores500.csv', header=TRUE) #TODO
  df$GEOID   <- make_geoids_char(df$GEOID)
  df$STATEFP <- as.factor(df$STATEFP)
  df2        <- df %>% group_by(substr(GEOID,1,2))                   %>% 
                       filter(n()>1)                                 %>% 
                       ungroup()                                     %>%
                       select(GEOID,CvxHullPS,CvxHullPT)             %>%
                       mutate(cvxdiff=abs(CvxHullPT-CvxHullPS)>1e-4) %>%
                       arrange(CvxHullPT)                            %>%
                       melt(id.vars=c("GEOID", "cvxdiff"))
  df3 <- df2 %>% filter(cvxdiff>0) 
  df2 <- df2 %>% filter(cvxdiff==0)

  df3$variable <- factor(df3$variable, levels=c("CvxHullPT", "CvxHullPS"), ordered=TRUE)
  df2$variable <- factor(df2$variable, levels=c("CvxHullPT", "CvxHullPS"), ordered=TRUE)

  p<- ggplot() + 
                 #geom_line(data=df2, aes(x = variable, y = value, group=GEOID), color="black", alpha=0.2,  size=0.25) +
                 geom_line(data=df3, aes(x = variable, y = value, group=GEOID), color="black", alpha=0.5, size=1)   +
                 xlab("") + scale_x_discrete(expand=c(0,0)) +
                 theme(axis.text.x = element_blank()) +
                 scale_y_continuous(name="CvxHullPT Score", sec.axis = sec_axis(~.*1, name = "CvxHullPS Score"))+
                 theme(axis.title.y = element_text(size=15))

  ggsave('imgs/fig_score_order.pdf', plot=p, width=4, height=4, limitsize=FALSE)





if(!file.exists('imgs/fig_score_order_corr.pdf')){
  df         <- read.table('scores500.csv', header=TRUE) #TODO
  df$GEOID   <- make_geoids_char(df$GEOID)
  df$STATEFP <- as.factor(df$STATEFP)
  df         <- df %>% select(CvxHullPS, CvxHullPT,CvxHullPTB,PolsbyPopp,   ReockPS,   ReockPT,  ReockPTB,Schwartzbe)

  cm <- cor(df, method="spearman")
  
  pdf('imgs/fig_score_order_corr.pdf', width=7, height=7)
  corrplot(cm, p.mat=cm, type='lower', method="circle", order="FPC", tl.pos="d", cl.lim=c(0.4,1), insig="p-value", pch.col="black", tl.col="black", col=colorRampPalette(c('red','red','red','red','red','red','red','#d7191c','#fdae61','#ffffbf','#abd9e9','#2c7bb6'))(11))
  dev.off()
}








###################################
#Effect of floating point data type
###################################


#ls *pp | xargs sed -i 's/double/float/g'
#diff -y --suppress-common-lines scored scored_float | grep = | sed 's/\ (Real)//g' | sed 's/= /,/g'  | sed 's/|/,/'  | d.reducespace > ~/projects/compactness/data-handling/figures/scores_double_vs_float

a           <- read.table('scores_double_vs_float',sep=',')
colnames(a) <- c('score','dval','score2','fval')

a <- a %>% select(-score2)
a$diff  = abs(a$fval-a$dval)
a$pdiff = 100*a$diff/a$dval
a <- a %>% arrange(desc(pdiff))
a %>% group_by(score) %>% summarise(max(pdiff))








##########################
#KOCH SNOWFLAKE
##########################



if(!file.exists('imgs/fig_koch_1.pdf')){

  a <- read.csv('koch.csv', colClasses=c("integer", "character"))
  a <- a %>% mutate(geomo=st_as_sfc(geom))
  a <- a %>% filter(level>0) %>% filter(level<=8)
  a <- cbind(a, a %>% rowwise() %>% do(mandeR::getScoresForWKT(.$geom)))


  #ls *koch* | xargs -n 1 -I {} pdfcrop {} {}
  for(i in 1:9){
    b <- a %>% filter(level==i)

    p<- ggplot(b) + geom_sf(aes(geometry=geomo)) + 
                theme_void() +
                theme(
                  axis.title.x     = element_blank(),
                  axis.text.x      = element_blank(),
                  axis.ticks.x     = element_blank(),
                  axis.title.y     = element_blank(),
                  axis.text.y      = element_blank(),
                  axis.ticks.y     = element_blank(),
                )
    ggsave(paste0('imgs/fig_koch_',i,'.pdf'), plot=p, width=1, height=1)
  }

  txt <- a %>% mutate(path=paste0('\\includegraphics[width=0.5in]{imgs/fig_koch_',level,'.pdf}')) %>% 
               select(path,PolsbyPopp,Schwartzbe,CvxHullPS,ReockPS,areaAH,perimSH)
  txt <- txt %>% mutate(
    perPols       = 100*(PolsbyPopp-lag(PolsbyPopp))/PolsbyPopp,
    perSchwartzbe = 100*(Schwartzbe-lag(Schwartzbe))/Schwartzbe,
    perCvxHullPS  = 100*(CvxHullPS-lag(CvxHullPS))/CvxHullPS,
    perReockPS    = 100*(ReockPS-lag(ReockPS))/ReockPS
  )

  txt <- t(txt)
  print(xtable(txt), sanitize.text.function = identity, floating.environment = 'figure*', include.colnames=FALSE)

}









FindEvil <- function(a, fixid){

  #Score compared to a histogram in which districts without a choice of borders
  #are included
  diffnc <- a %>% 
        group_by(proj,tol,variable) %>% 
        summarise(
          median   = median(value),
          mean     = mean(value),
          distval  = sum(ifelse(id == fixid,value,0))
        ) %>%
        mutate(
          med_diff  = abs(median-distval),
          mean_diff = abs(mean-distval)
        ) %>%
        mutate(
          med_quant  = ecdf(med_diff)(med_diff),
          mean_quant = ecdf(mean_diff)(mean_diff)
        ) %>% 
        mutate(
          choice='nochoice'
        ) %>% rowwise()

  #Score compared to a histogram in which district without a choice of
  #boundaries are excluded
  diffc <- a %>% 
        filter(substr(id,3,4)!='00')     %>%
        group_by(proj,tol,variable) %>% 
        summarise(
          median   = median(value),
          mean     = mean(value),
          distval  = sum(ifelse(id == fixid,value,0))
        ) %>%
        mutate(
          med_diff  = abs(median-distval),
          mean_diff = abs(mean-distval)
        ) %>%
        mutate(
          med_quant  = ecdf(med_diff)(med_diff),
          mean_quant = ecdf(mean_diff)(mean_diff)
        ) %>% 
        mutate(
          choice='choice'
        ) %>% rowwise()

  #Meld the foregoing
  diff <- rbind(diffnc,diffc)

  #Get the "best practices" score which most clearly indicates this district was gerrymandered
  bestd <- diff %>% 
           #filter(proj=='EPSG:102003' & tol==0) %>% 
           arrange(desc(mean_diff)) %>% head(n=1)
  diffd <- diff %>% 
           #filter(variable==bestd$variable) %>% 
           filter(as.numeric(levels(tol))[tol]<5000) %>% #Limit the degree of simplification
           arrange(mean_diff) %>% head(n=1)

  cat(paste(fixid,'&',round(bestd$distval,2),'&',round(bestd$mean_diff,2),'&',bestd$proj,'&',bestd$tol,'&',bestd$variable,'&',bestd$choice,"\\\\ \n"))
  cat(paste(fixid,'&',round(diffd$distval,2),'&',round(diffd$mean_diff,2),'&',diffd$proj,'&',diffd$tol,'&',diffd$variable,'&',diffd$choice,"\\vspace{0.5em} \\\\ \n"))

  #Histogram making the district look bad
  besthist <- a %>% filter(proj==bestd$proj & tol==bestd$tol & variable==bestd$variable)
  if(bestd$choice=='choice'){
    besthist <- besthist %>% filter(substr(id,3,4)!='00') 
  }

  #Histogram making the district look good
  diffhist <- a %>% filter(proj==diffd$proj & tol==diffd$tol & variable==diffd$variable)
  if(diffd$choice=='choice'){
    diffhist <- diffhist %>% filter(substr(id,3,4)!='00') 
  }


  style <-  theme_void() +
        theme(
          axis.title.x     = element_blank(),
          axis.text.x      = element_blank(),
          axis.ticks.x     = element_blank(),
          axis.title.y     = element_blank(),
          axis.text.y      = element_blank(),
          axis.ticks.y     = element_blank(),
        )

  p <- grid.arrange(
    ggplot(besthist, aes(x=value)) + style  + geom_histogram(fill="#C1C1C1", aes(y=..count../max(..count..))) + geom_vline(xintercept=bestd$distval, color='black'),
    ggplot(diffhist, aes(x=value)) + style  + geom_histogram(fill="#C1C1C1", aes(y=..count../max(..count..))) + geom_vline(xintercept=diffd$distval, color='black'),
    ncol=1
  )

  p
}

inp <- read.csv('out_fix.csv', colClasses=c('character','character','character','character','factor','character', 'double'))
a   <- inp %>% filter(proj!='input') %>% filter(!(variable %in% c('perimSH', 'areaSH', 'areaAH', 'HoleCount')))
#a   <- a %>% filter(variable!='CvxHullPTB')

a$proj = gsub('local_lcc','Local LCC',a$proj)
a$proj = gsub('local_alb','Local AEA',a$proj)
a$proj = gsub('local_alb','Local AEA',a$proj)
a$proj = gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", a$proj, perl=TRUE)

idredo <- function(x){
  paste0(fipsab[substr(x, 1, 2)],substr(x, 3, 4))
}

a$id = idredo(a$id)


dists_to_fix <- c('2403','3712','2402','1205','3701','4207','4833','3704','1704','4835')
dists_to_fix = idredo(dists_to_fix)

cat("\\begin{tabular}{lllllll}\n")
cat("District & Score Value & Diff from Mean & Score Name & Tolerance & Projection & Choice \\\\ \\hline \n")
for(fixid in dists_to_fix){
  p<-FindEvil(a,fixid)
  ggsave(paste0('imgs/fig_evil_',fixid,'.pdf'), plot=p, width=1, height=0.5)
}
cat("\\end{tabular}\n")
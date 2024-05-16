calcDevelopmentRate<-function(tavg, baseT, criticalT, Rmax, alpha, beta)
{
# Yin et al. 1995. A nonlinear model for crop development as a function of temperature
    if (tavg > baseT && tavg < criticalT)
        fT = (tavg - baseT)^alpha * (criticalT - tavg)^beta
    else
        fT = 0

    DR = exp(Rmax) * fT
    return (DR)
}

main<-function(wx, plantingDate, lat, baseT, criticalT, alpha, beta, RmaxVeg, RmaxRep)
{
    sigmaDR = 0
    nday = dim(wx)[1]
    heading = 0
    gdd = 0
    for (d in 1:nday)
    {
        tmax = wx$tmax[d]
        tmin = wx$tmin[d]	
        doy  = wx$doy[d] 
        if (doy < plantingDate)
        {
            next
        }

        if (sigmaDR < 1)
        {
            Rmax <- RmaxVeg
        }
        else
        {
            Rmax <- RmaxRep
        }
        tavg = (tmax + tmin) / 2
        DR = calcDevelopmentRate(tavg, baseT, criticalT, Rmax, alpha, beta)

        sigmaDR = sigmaDR + DR 
        if (sigmaDR > 1)
        {
            heading = doy 
            break 
        }
    }

    return (heading)
}

runModel<-function(par, data)
{
# short day plant 
    baseT = par[1]
    criticalT = par[2]
    alpha = par[3]
    beta = par[4]
    RmaxVeg = par[5]
    RmaxRep = par[6]

    records = data
    nrecord = dim(records)[1]
    estimated = rep(-999, nrecord)
    for (i in 1:nrecord)
    {
        plantingDate = records$planting[i]
        yearstr = substr(paste(records$year[i]), 3, 4)
        wxfilename = paste(records$site[i], yearstr, "01.WTH", sep="")
        wxfile = readLines(wxfilename)
        header1l = grep("^@ INSI",wxfile)
        header2l = grep("^@DATE",wxfile)
        wx1<-strsplit(trimws(wxfile[header1l+1])," +")
        lat <- as.numeric(wx1[[1]][2])
        wx2 = read.table(wxfilename, header=TRUE, skip=header2l-1)
        year = as.integer(wx2$X.DATE/1000)+1900
        year = ifelse(year<1950,year+100,year)
        doy = wx2$X.DATE%%1000
        wx = cbind(year, doy, wx2[, c(2, 4, 3)])
        colnames(wx) = c("year", "doy", "sundur", "tmin", "tmax")

        heading = main(wx, plantingDate, lat,  baseT, criticalT, alpha, beta, RmaxVeg, RmaxRep)
        estimated[i] = heading
    }
    records$estimated = estimated
    return (records)
}

calibrationFile<-"input.txt"
outputFile<-"output.txt"
records = read.table(calibrationFile, sep="\t", header=TRUE)

paramfilename='parameter.txt'
paramfile = read.table(paramfilename, sep='\t', header=TRUE)
param = unlist(paramfile)

output = runModel(param,records)
colnames(output)<-c("site","year","planting","headingM","headingS")
write.table(output, outputFile, sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)


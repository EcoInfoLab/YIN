# YIN
A model for estimation of heading dates using Yin et al. (1995)    
* Yin, X., Kropff, M. J., McLaren, G., & Visperas, R. M. (1995). A nonlinear model for crop development as a function of temperature. Agricultural and Forest Meteorology, 77(1-2), 1-16.

Input file (input.txt)    
-------------
Tab separated file    
Includes sitename, year, planting dates, and measured heading dates (-99 if missing)
````
site	year	planting	heading    
X105	1999	145	216    
X105	2000	146	215    
X105	2001	141	213     
X105	2002	140	217    
````
Input file (parameter.txt)    
-------------
Tab separated file    
````
baseT	criticalT	alpha	beta	RmaxVeg	RmaxRep
11.9	34	3.5	0.3	-13.7	-5.7
````
Input file (weather files)    
-------------
Use DSSAT format

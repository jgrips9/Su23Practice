*import sample cars dataset
sysuse auto, clear

*Goal predict mpg from weight and length of car. 

*5 number summary price, mpg, weight, length.
su price mpg weight length

*summary table. 
tabstat price mpg, by(foreign) s(mean med sd)

*Relationship between variables. Split by binary variable. 
scatter mpg weight, by(foreign)

scatter mpg length, by(foreign)

*Show distribution of variables. What is spread. 
hist mpg
hist weight
hist length

*perform correlation. Going to create regression equation predicting mpg from weight and length. 
corr mpg weight length

regress mpg weight length

*ttest total MPG to 15
ttest mpg == 15

*ttest by group. MPG for Domestic and foreign
ttest mpg, by(foreign)
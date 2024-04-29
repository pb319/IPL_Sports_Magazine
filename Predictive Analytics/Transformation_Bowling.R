#Data Load
library(readxl)
d= read_excel("Yuzvendra Chahal.xlsx")
View(d)                                                                      
#Data Transformation
d$PC1 = ((-0.02003457)*d$`MAT`)+((-0.05790883)*d$`OVERS`)+((0.99781349)*d$`AVE`)+((0.02476751)*d$`ECON`)      
d$PC2 = ((-0.18822317)*d$MAT)+((-0.97898242)*d$OVERS)+((0.06179758)*d$AVE)+(( 0.04844082)*d$ECON)      
d

# If not Installed--  install.packages("openxlsx")

library(openxlsx)
file_path <- "Chahal_trans.xlsx"
write.xlsx(d, file_path)

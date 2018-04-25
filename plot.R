# plot output

setwd("~/projects/rigol/")
data=read.csv("out.csv")

data = data[-(1:30),]

plot(data[,"time"], data[,"I1"] * 1000, type="l", xlab="t", ylab="I1/mA")

plot(data[,"time"], data[,"I2"] * 1000, type="l", xlab="t", ylab="I/mA")

plot(data[,"time"], data[,"V2"], type="l", xlab="t", ylab="U2/V")

i = data[data[,"I2"]>20e-3,"I2"]
u = data[data[,"V2"]>20e-3,"V2"]
plot(i[15:220], type="l")
mean(i[15:220])
mean(i[15:220] * u[15:220])


pdf("RXM-GNSS-GM-current.pdf")
plot(data[,"time"], data[,"I2"] * 1000, type="l", xlab="t/s", ylab="I/mA")
title("RXM-GNSS-GM current 'Always Locate'")
abline(h=31, col="grey")
abline(h=9.4, col="grey")
#
plot(data[,"time"], data[,"V2"] * data[,"I2"] * 1000, type="l", xlab="t/s", ylab="P/mW")
title("RXM-GNSS-GM power consumption")
abline(h=102.3, col="grey")
abline(h=30.98, col="grey")
dev.off()

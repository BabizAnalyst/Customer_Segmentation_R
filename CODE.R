offers<-read.csv(file="./input/OfferInformation.csv")
transactions<-read.csv(file="Transactions.csv")

#Load Library
library(reshape)

# Melt transactions, cast offer by customers
pivot<-melt(transactions[1:2])
pivot<-(cast(pivot,value~Customer.Last.Name,fill=0,fun.aggregate=function(x) length(x)))

# Bind to offers, we remove the first column of our new pivot because it's redundant. 
pivot<-cbind(offers,pivot[-1])

# Load library
library(fpc)

# Only use customer transaction data and we will rotate the matrix
cluster.data<-pivot[,8:length(pivot)]
cluster.data<-t(cluster.data)

# We will run KMeans using pamk (more robust) with 4 clusters. 
cluster.kmeans<-pamk(cluster.data,k=4)

# Use this to view the clusters
View(cluster.kmeans$pamobject$clustering)

#Merge Data
cluster.deals<-merge(transactions[1:2],cluster.kmeans$pamobject$clustering,by.x = "Customer.Last.Name", by.y = "row.names")
colnames(cluster.deals)<-c("Name","Offer","Cluster")

# Melt, cast, and bind
cluster.pivot<-melt(cluster.deals,id=c("Offer","Cluster"))
cluster.pivot<-cast(cluster.pivot,Offer~Cluster,fun.aggregate=length)
cluster.topDeals<-cbind(offers,cluster.pivot[-1])


write.csv(file="./output/topdeals.csv",cluster.topDeals,row.names=F)

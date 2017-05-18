*********************Customer Segmentation****************************************
Customer segmentation is as simple as it sounds: grouping customers by their characteristics – and why would you want to do that? To better serve their needs!
So how does one go about segmenting customers? One method we will look at is an unsupervised method of machine learning called k-Means clustering. Unsupervised learning means finding out stuff without knowing anything about the data to start … so you want to discover.
Our example today is to do with e-mail marketing. We use the dataset from Chapter 2 on Wiley’s website – download a vanilla copy here
What we have are offers sent via email, and transactions based on those offers. What we want to do with K-Means clustering is classify customers based on offers they consume. Simplystatistics.org have a nice animation of what this might look like:

K-Means Clustering – R
We will go through the same steps we did. We start with our vanilla files – provided in CSV format:
Offers
Transactions
Download these files into a folder where you will work from in R. Fire up RStudio and lets get started.
Step 1: Pivot & Copy
First we want to read our data. This is simple enough:
# Read offers and transaction data
offers<-read.csv(file="OfferInformation.csv")
transactions<-read.csv(file="Transactions.csv")
We now need to combine these 2 files to get a frequency matrix – equivalent to pivoting in Excel. This can be done using the reshape library in R. Specifically we will use the melt and cast functions.
We first melt the 2 columns of the transaction data. This will create data that we can pivot: customer, variable, and value. We only have 1 variable here – Offer.
We then want to cast this data by putting value first (the offer number) in rows, customer names in the columns. This is done by using R’s style of formula input: Value ~ Customers.
We then want to count each occurrence of customers in the row. This can be done by using a function that takes customer names as input, counts how many there are, and returns the result. Simply: function(x) length(x)
Lastly, we want to combine the data from offers with our new transaction matrix. This is done using cbind (column bind) which glues stuff together automagically.
Lots of explanations for 3 lines of code!
#Load Library
library(reshape)
 
# Melt transactions, cast offer by customers
pivot<-melt(transactions[1:2])
pivot<-(cast(pivot,value~Customer.Last.Name,fill=0,fun.aggregate=function(x) length(x)))
 
# Bind to offers, we remove the first column of our new pivot because it's redundant. 
pivot<-cbind(offers,pivot[-1])
We can output the pivot table into a new CSV file called pivot.
write.csv(file="pivot.csv",pivot)
Step 2: Clustering
To cluster the data we will use only the columns starting from “Adams” until “Young”.
We will use the fpc library to run the KMeans algorithm with 4 clusters.
To use the algorithm we will need to rotate the transaction matrix with t().
That’s all you need: 4 lines of code!
# Load library
library(fpc)
 
# Only use customer transaction data and we will rotate the matrix
cluster.data<-pivot[,8:length(pivot)]
cluster.data<-t(cluster.data)
 
# We will run KMeans using pamk (more robust) with 4 clusters. 
cluster.kmeans<-pamk(cluster.data,k=4)
 
# Use this to view the clusters
View(cluster.kmeans$pamobject$clustering)
Step 3: Solving for Cluster Centers
This is not a necessary step in R! Pat yourself on the back, get another cup of tea or coffee and move onto to step 4.
Step 4: Top deals by clusters
Top get the top deals we will have to do a little bit of data manipulation. First we need to combine our clusters and transactions. Noteably the lengths of the ‘tables’ holding transactions and clusters are different. So we need a way to merge the data … so we use the merge() function and give our columns sensible names:
#Merge Data
cluster.deals<-merge(transactions[1:2],cluster.kmeans$pamobject$clustering,by.x = "Customer.Last.Name", by.y = "row.names")
colnames(cluster.deals)<-c("Name","Offer","Cluster")
We then want to repeat the pivoting process to get Offers in rows and clusters in columns counting the total number of transactions for each cluster. Once we have our pivot table we will merge it with the offers data table like we did before:
# Melt, cast, and bind
cluster.pivot<-melt(cluster.deals,id=c("Offer","Cluster"))
cluster.pivot<-cast(cluster.pivot,Offer~Cluster,fun.aggregate=length)
cluster.topDeals<-cbind(offers,cluster.pivot[-1])
We can then reproduce the excel version by writing to a csv file:
write.csv(file="topdeals.csv",cluster.topDeals,row.names=F)
Note
It’s important to note that cluster 1 in excel does not correspond to cluster 1 in R. It’s just the way the algorithms run. Moreover, the allocation of clusters might differ slightly because of the nature of kmeans algorithm. However, your insights will be the same; in R we also see that cluster 3 prefers Pinot Noir and cluster 4 has a strong preference for Offer 22.
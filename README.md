# Quarkus on Amazon Kambda

This is a simple demo application showing Quarkus usage with Amazon Lambda.  The included deploy script is what I use to build and bundle
 the application and deploy it to Amazon.  There are a few rough edges (application bundling) that we'll hopefully smooth over in time 
 but this should get you started.
 
## Build requirements
This currently requires that you check out [Quarkus's](https://github.com/quarkusio/quarkus) `master` branch and install locally.  Once 
there is a release that includes the updated Amazon Lambda bits, this project will be updated correctly.  That target milestone for that 
release is 0.14 at this moment. 

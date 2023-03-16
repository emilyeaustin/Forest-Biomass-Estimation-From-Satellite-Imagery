# Forest-Biomass-Estimation-From-Satellite-Imagery
Business Objective

Carbon credits are being bought and sold today on carbon markets. Photosynthesis remains the most efficient way to remove carbon from the atmosphere, and nature-based carbon credits are a big part of today’s carbon market. In order for nature-based carbon credits to have value, they must be verified by the credit issuing agency. Verification involves measuring the carbon in the forest which is traditionally done by measuring the diameter of trees and extrapolating. However, hiring foresters to perform forest inventory is expensive and makes carbon credits cost prohibitive to smaller land owners. Models that use freely available remote sensing data from satellites can drastically reduce the cost of measuring carbon in forests and may make the carbon market accessible to more land owners.

Data Ingestion
This project included two types of data. The first was 6.9GB of satellite image data from the sentinel -2 satellite and the second is a CSV file of a long-term survey of forest biomass throughout Maine (~1000 plots). The satellite images were loaded into R along with a projection of the state of Maine and the survey data. The values of each band were extracted for the area in each of the plots and the median value was taken for each band across all available images.

Machine Learning
The data produced in R was loaded into a python environment and all of the machine learning was performed in scikit- learn. Based on the quantity and types of data, the following models were selected: Random Forest Regressor, Ridge Regression, SVM and Random Forest with gradient boosting

The machine learning component included regression models (Random Forest Regressor, Ridge Regressor), feature engineering (Standard Scaler), and ensemble models (Random Forest with Gradient Boosting).

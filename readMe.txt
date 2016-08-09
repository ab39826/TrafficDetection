DESCRIPTION:
We implement a system for vehicle detection and
tracking from traffic video using Gaussian mixture models and
Bayesian estimation. In particular, the system provides robust
foreground segmentation of moving vehicles through a K-means
clustering approximation as well as vehicle tracking correspon-
dence between frames by correlating Kalman and particle filter
prediction updates to current observations through the solution
of the assignment problem. In addition, we conduct performance
and accuracy benchmarks that show about a 90 percent reduc-
tion in runtime at the expense of reducing the robustness of
the mixture model classification and about a 30 percent and 45
percent reduction in accumulated error of the Kalman filter and
particle filter respectively as compared to a system without any
prediction.

*In retrospect, the results for the particle filter were found to be miscalculated. Adjustment of the model assumptions must be made to show particle filter tracking improvements.

Read the project report for a more detailed description of the code.

INSTRUCTIONS:
In order to run the code, 

run the following command

foregroundEstimation('justCarsTrim.avi');

or any other .avi video you wish to see the results of.

This will output a video called 'foreground.avi' which will show the background segmentation

and tracking applied
contingent upon whether

trackingOn = 1;

or 

trackingOn = 0;

Be warned as this takes about 30 minutes to run the simulation and generate the file.

However, if you'd like you can view the result at the youtube link below instead which shows both output results.
https://www.youtube.com/watch?v=GwyQ3QdBzaY

--------------------------




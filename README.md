# human-analysis 

Dissertation - Is the characterisation of Parkinson’s Disease in humans and zebrafish possible by using evolutionary algorithms?

## fingerdisplacementplot

fingerdisplacementplot.m plots the displacement between finger and thumb, and uses the information to calculate key characteristics such as movement speed, distance travelled, number of hesitations, frequency etc.

![image of fingerdisplacementplot results](https://i.imgur.com/X60auZm.png)

## speedregressionplots

speedregressionplots.m calculates the regression of finger movement speeds over a period of time, to try and identify
symptoms of the 'Sequence Effect'.

![image of speedregressionplots results](https://i.imgur.com/wEnYRVl.png)

## speedregressionpercentage

Calculates the gradient of the best-fit line from previous plots for all 184 human datasets, and determines which of Control 
or Parkinsonian zebrafish display more signs of fatigue

## amplituderegressionplots & amplituderegressionpercentage

The same processes as used in the speedregression files, however with the amplitudes of movements instead of speed.

## humanHesitations

humanHesitations performs an algorithm on the movement data of every dataset, and determines how many hesitations are present 
in the movements.

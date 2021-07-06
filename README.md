# Active Brownian Crawler model
## Written in MATLAB

By Jack Treado, Yale University, 2021


## Getting started

The main file that runs the simulation is the function `activeBrownianCrawler.m`.

<p float="left">
  <img src="imgs/abc_NV32_ca1.3042_kb0_v00.05_Dr0.01.gif" width="400" />
  <img src="imgs/abc_NV32_ca1.3042_kb0_v00.05_Dr0.1.gif" width="400" /> 
</p>

The code can be tuned from directed, pseudopod motion (left) to random, focal adhesion-like motion (right). 


### Inputs

The main function is defined as follows:

`function activeBrownianCrawler(NV,calA0,Kl,Kb,v0,Dr,Ds,NT,dt,NFRAMES,seed,savestr)`

* `NV`: integer number of vertices that make up the deformable particle (DP)
* `calA0`: initial **preferred** shape parameter
	* Defined as <img src="https://render.githubusercontent.com/render/math?math=\mathcal{A}_0 = p_0^2/4\pi a_0"> where <img src="https://render.githubusercontent.com/render/math?math=p_0"> and <img src="https://render.githubusercontent.com/render/math?math=a_0"> are the preferred perimeter and area of the cell, respectively.
* `Kl`: mechanical constant for perimeter
* `Kb`: mechanical constant for curvature
* `v0`: crawling speed
* `Dr`: cell-based director diffusion coefficient
* `Ds`: "foot size", spread of velocity distribution to nearby vertices
* `NT`: number of time steps to simulate
* `dt`: time step size
	* Note that total time will be `ttotal = NT * dt`
* `NFRAMES`: total number of "frames" to be saved during simulation.
	* Frame count rounds down, i.e. if there are `NT = 8` time steps and you ask for `NFRAMES = 3`, you will only print out `2` frames total
* `seed`: integer seed for random number generator, **must be integer > 0.**
* `savestr`: string variable, path to file with saved data from simulation. Data saved in `.mat` file format, [see MATLAB documentation on MAT-files](https://www.mathworks.com/help/matlab/ref/matlab.io.matfile.html).


## Running Locally

To run locally on your machine, call the MATLAB function from the MATLAB command line with relevant inputs. The left example was run with 
```matlab
>>> activeBrownianCrawler(32, 1.3, 1.0, 0.0, 0.05, 0.01, 0.2, 1e6, 0.005, 200, 1, 'test.mat');
```
and the right-hand example with
```matlab
>>> activeBrownianCrawler(32, 1.3, 1.0, 0.0, 0.05, 0.1, 0.1, 1e6, 0.005, 200, 1, 'test.mat');
```
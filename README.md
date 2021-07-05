# Active Brownian Crawler model
## Written in MATLAB

By Jack Treado, Yale University, 2021


## Getting started

The main file that runs the simulation is the function `activeBrownianCrawler.m`. This is a MATLAB function that you can run from the command
line in the MATLAB editor screen. 

The main function is defined as follows:

`function activeBrownianCrawler(NV,calA0,Kl,Kb,v0,Dr,NT,dt,NFRAMES,seed,savestr)`

### Inputs
* `NV`: integer number of vertices that make up the deformable particle (DP)
* `calA0`: initial **preferred** shape parameter
	* Defined as <img src="https://render.githubusercontent.com/render/math?math=\mathcal{A}_0 = p_0^2/4\pi a_0"> where <img src="https://render.githubusercontent.com/render/math?math=p_0"> and <img src="https://render.githubusercontent.com/render/math?math=a_0"> are the preferred perimeter and area of the cell, respectively.
* `Kl`: mechanical constant for perimeter
* `Kb`: mechanical constant for curvature
* `v0`: crawling speed
* `Dr`: cell-based director diffusion coefficient
* `NT`: number of time steps to simulate
* `dt`: time step size
	* Note that total time will be `ttotal = NT * dt`
* `NFRAMES`: total number of "frames" to be saved during simulation.
	* Frame count rounds down, i.e. if there are `NT = 8` time steps and you ask for `NFRAMES = 3`, you will only print out `2` frames total
* `seed`: integer seed for random number generator, **must be integer > 0.**
* `savestr`: string variable, path to file with saved data from simulation. Data saved in `.mat` file format, [see MATLAB documentation on MAT-files](https://www.mathworks.com/help/matlab/ref/matlab.io.matfile.html).


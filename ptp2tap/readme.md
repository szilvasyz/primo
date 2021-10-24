## ptp2tap.py

Python3 code for converting Primo ptp files to C64 tap format. C64 tap files can be used with TAPUINO.

	usage: ptp2tap.py [-h] [-v] [-s] [-H] [-S SILENCE] [-C CLOCK]
	                  infiles [infiles ...]

	positional arguments:
	  infiles               input filenames

	optional arguments:
	  -h, --help            show this help message and exit
	  -v, --verbose         detailed output during converting
	  -s, --split           split to multiple output files
	  -H, --highspeed       high-speed (3.75MHz) Primo timings
	  -S SILENCE, --silence SILENCE
	                        silence in ms before program header
	  -C CLOCK, --clock CLOCK
	                        tap file clock frequency in Hz

* prkbdtest: test suite for visualizing all individual keys on Primo keyboards

A small assembly routine has been written for scanning and plotting key states
on the screen. Its source is in prkbdtest.src, assembled binary is in prkbdtest.cim.

In prkbdtest.bas the assembler routine is copied from data lines to memory, no more
files/parts is needed besides the bas file to run the test.

prkbdtest.wav, prkbdtest.ptp and kbdtest.corr.ptp are the loadable form of the program
in variuos formats. Since emulator makes mistakenly calculated CRCs in the ptp file,
prkbdtest.ptp showr load errors when loading (but it is completely error-free).

In file kbdtest.corr.ptp only CRCs have been recalculated for eliminating error reportings.
Otherwise the file is exactly the same as prkbdtest.ptp.
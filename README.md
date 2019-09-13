Software for "Gerrymandering and Compactness: Implementation Flexibility and Abuse"
===================================================================================

**Title of Manuscript**:
Gerrymandering and Compactness: Implementation Flexibility and Abuse

**Authors**: Richard Barnes and Justin Solomon

**Corresponding Author**: Richard Barnes (richard.barnes@berkeley.edu)

**DOI Number of Manuscript**: TODO

**Code Repositories**
 * [Author's GitHub Repository](https://github.com/r-barnes/Barnes2019-compactness-flexibility)

This repository contains the code needed to produce the figures and data
described in the manuscript above.



Abstract
--------

The shape of an electoral district may suggest whether it was drawn with
political motivations, or _gerrymandered_. For this reason, quantifying the
shape of districts, in particular their compactness, is a key task in politics
and civil rights. A growing body of literature suggests and analyzes compactness
measures mathematically, but little consideration has been given to how these
scores should be calculated in practice. Here, we consider the effects of a
number of decisions that must be made in interpreting and implementing a set of
popular compactness scores. We show that the choices made in quantifying
compactness may themselves become political tools, with seemingly innocuous
decisions leading to disparate scores. We show that when the full range of
implementation flexibility is used, it can be abused to make clearly
gerrymandered districts appear quantitatively reasonable. This complicates using
compactness as a legislative or judicial standard to counteract unfair
redistricting practices. This paper accompanies the release of packages in C++,
Python, and R which correctly, efficiently, and reproducibly calculate a variety
of compactness scores.



To Generate Figures
-------------------

### Install Dependencies

Figures are known to generate correctly with Python 3.6.8 and R version 3.4.4

Install bash dependencies:

    sudo apt install shapelib shapetools gdal-bin r-base make cmake python3

Install Python dependencies:

    pip3 install -r requirements.txt

Install R dependencies:

    R
    install.packages(c("corrplot", "dplyr", "GGally", "ggplot2", "ggrepel", "gridExtra", "reshape2", "scales", "sf", "stringr", "xtable"))

The following R package versions were used to generate the figures in the paper.

    corrplot     0.84
    dplyr     0.8.0.1
    GGally      1.4.0
    ggplot2     3.1.0
    ggrepel     0.8.1
    gridExtra     2.3
    reshape2    1.4.3
    scales      1.0.0
    sf          0.7-7
    stringr     1.4.0
    xtable      1.8-3

### Via Github

In addition to the above, if you have obtained this code from Github, you must ensure you have acquired the code's submodules.

Clone the repo:

    git clone https://github.com/gerrymandr/python-mander.git

Check out the submodules:

    git submodule update --init --recursive

### Build Figures

Figures are known to generate without problems on a 2011 Thinkpad X201 with a Intel(R) Core(TM) i5 M480@2.67GHz CPU with 4 cores and 8GB of RAM.

All of the figures are built by running a single command:

    make

Make will create a folder to run `cmake` in and then execute all the commands needed to generate the figures. The final figures will be saved to a folder named `figures/`. It may take quite a while.

`scores_double_vs_float` is presupplied because its effect size is small and generating it takes significant manual work. To generate it, replace `double` with `float` throughout `submodules/compactnesslib/api` and `submodules/compactnesslib/src` and rerun all score generation, per the makefile.

`effect_of_topography.tbl` is presupplied because its effect size is small and generating it takes significant manual work. To generate it, acquire NED 10m elevation data for the US (several gigabytes), cut the elevation data to the boundary of each congressional district using `gdal`, and then measure the length of the outline with and without topography using RichDEM.

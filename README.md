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

Figures are known to generate correctly with Python (v3.6.8), R (v3.4.4), and pdfLaTeX (3.14159265-2.6-1.40.20, TeX Live 2019).

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

The following LaTeX packages were used to generate TeX figures in the paper:

    graphicx (1.1a 2017-06-01)
    siunitx (2.7s 2018-05-17)
    tikz (3.1.4b 2019-08-03)



### Via Github

In addition to the above, if you have obtained this code from Github, you must ensure you have acquired the code's submodules.

Clone the repo:

    git clone https://github.com/gerrymandr/python-mander.git

Check out the submodules:

    git submodule update --init --recursive

### Build Figures

Figures are known to generate without problems on a 2011 Thinkpad X201 with a Intel(R) Core(TM) i5 M480@2.67GHz CPU with 4 cores in 1 hour and 7 minutes using a peak of 700MB of RAM.

All of the figures are built by running a single command:

    make

Make will create a folder to run `cmake` in and then execute all the commands needed to generate the figures. The final figures will be saved to a folder named `figures/`. It may take quite a while.



File List
------------------------

The repository contains the following files:

 * `data/cb_2015_us_cd114_20m.shp`: 20m resolution Congressional District boundaries from "United States Census Bureau. 2016. Cartographic Boundary Shapefiles. https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html accessed on 2017-08-26."
 * `data/cb_2015_us_cd114_500k.shp`: 500k resolution Congressional District boundaries from "United States Census Bureau. 2016. Cartographic Boundary Shapefiles. https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html accessed on 2017-08-26."
 * `data/cb_2015_us_cd114_5m.shp`: 5m resolution Congressional District boundaries from "United States Census Bureau. 2016. Cartographic Boundary Shapefiles. https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html accessed on 2017-08-26."
 * `data/cb_2015_us_state_20m.shp`: 20m resolution state boundaries from "United States Census Bureau. 2016. Cartographic Boundary Shapefiles. https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html accessed on 2017-08-26."
 * `data/cb_2015_us_state_500k.shp`: 500k resolution state boundaries from "United States Census Bureau. 2016. Cartographic Boundary Shapefiles. https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html accessed on 2017-08-26."
 * `data/cb_2015_us_state_5m.shp`: 5m resolution state boundaries from "United States Census Bureau. 2016. Cartographic Boundary Shapefiles. https://www.census.gov/geo/maps-data/data/cbf/cbf_cds.html accessed on 2017-08-26."
 * `figures/`: Directory containing generated figures
 * `output/`: Directory containing intermediate outputs
 * `submodules/`: Directory containing `compactnesslib` and `python-mander`, which are used to calculate the compactness scores themselves.
 * `tex/`: Directory containing TeX source for several of the figures.
 * `output/scores_double_vs_float`: Compactness scores as generated with single- versus double-precision floating-point. This file is presupplied because its effect size is small and generating it takes significant manual work. To generate it, replace `double` with `float` throughout `submodules/compactnesslib/api` and `submodules/compactnesslib/src` and rerun all score generation, per the makefile.
 * `output/effect_of_topography.tbl`: Compactness scores as calculated accounting for topography and not. This file is presupplied because its effect size is small and generating it takes significant manual work. To generate it, acquire NED 10m elevation data for the US (several gigabytes), cut the elevation data to the boundary of each congressional district using `gdal`, and then measure the length of the outline with and without topography using RichDEM.
 * `src/augmenter.cpp`: Adds scores to existing shapefiles.
 * `src/CMakeLists.txt`: Part of the build process.
 * `src/common.py`: Functions used my multiple of the scripts in `src/`.
 * `src/districtplot.py`: Plots district silhouettes.
 * `src/koch.cpp`: Generates a Koch snowflake.
 * `src/koch_scores.py`: Calculates scores for a Koch snowflake.
 * `src/make_figs.y`: Generates all of the intermediate figure images.
 * `src/res_bounded.py`: Calculates scores when superunit boundaries are accounted for.
 * `src/res_fig_gerrymandering.py`: Calculates joint effect of many other effects combined.
 * `src/res_projections.py`: Calculates effect of different projections on compactness scores.
 * `src/res_simp_indiv.py`: Calculates effect of simplifying district shapes when each district is considered independently.
 * `src/res_simp_together.py*`: Calculates effect of simplifying district shapes when groups of districts are considered as part of the simplification.
 * `src/Timer.cpp`: Used for timing various operations
 * `src/Timer.hpp`: Used for timing various operations

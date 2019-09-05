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

Clone the repo:

    git clone https://github.com/gerrymandr/python-mander.git

Check out the submodules:

    git submodule update --init --recursive

Install dependencies (TODO)

dbfdump
import sys
import shapely
import shapely.ops
import shapely.geometry
import functools
import fiona
import json
import mander
import pyproj
import pandas as pd



Dependencies
------------

You will need [python-mander](https://pypi.python.org/pypi/mander/0.3) to run
the code.

Install it using:

    pip3 install mander

You will also need **R** and **gdal** installed.



Data
-----------

You will need the following data files, or equivalent, from the U.S. Census
Bureau:

 * `cb_2015_us_cd114_20m.shp`
 * `cb_2015_us_cd114_500k.shp`
 * `cb_2015_us_cd114_5m.shp`
 * `cb_2015_us_state_20m.shp`
 * `cb_2015_us_state_500k.shp`
 * `cb_2015_us_state_5m.shp`
 * `tl_2015_us_cd114.shp`



Usage
-----------

To generate figures, use the command:

    ./RUN.sh

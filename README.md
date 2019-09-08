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

Install bash dependencies:

    sudo apt install shapelib shapetools gdal-bin r-base make cmake

Install Python dependencies:

    pip3 install -r requirements.txt

Install R dependencies:

    R
    install.packages(c("corrplot", "dplyr", "GGally", "ggplot2", "ggrepel", "gridExtra", "reshape2", "scales", "sf", "stringr", "xtable"))

Run everything by typing:

    make

Make will create a folder to run cmake in and then execute all the commands needed to generate the figures. It may take quite a while.

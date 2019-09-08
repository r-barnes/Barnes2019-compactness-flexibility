all:
	#Build stuff
	-mkdir build
	cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j 4 && make install
	#Install Python Mander
	cd submodules/python-mander && python3 setup.py install --user
	#Generate Koch snowflake data
	./bin/koch.exe > output/koch.csv
	./bin/koch_scores.py output/koch.csv output/koch_scores.csv
	#Reproject data
	ogr2ogr -f "ESRI Shapefile" output/cb_2015_us_cd114_500k_reproj.shp data/cb_2015_us_cd114_500k.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" output/cb_2015_us_cd114_5m_reproj.shp   data/cb_2015_us_cd114_5m.shp   -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" output/cb_2015_us_cd114_20m_reproj.shp data/cb_2015_us_cd114_20m.shp   -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	#Reproject data
	ogr2ogr -f "ESRI Shapefile" output/cb_2015_us_state_5m_reproj.shp   data/cb_2015_us_state_5m.shp   -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" output/cb_2015_us_state_500k_reproj.shp data/cb_2015_us_state_500k.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" output/cb_2015_us_state_20m_reproj.shp  data/cb_2015_us_state_20m.shp  -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	#Augment shapefiles with score data
	#TODO
	./bin/augmenter.exe output/cb_2015_us_cd114_500k_reproj.shp output/cb_2015_us_state_500k_reproj.shp output/cb_2015_us_cd114_500k_scored.shp STATEFP
	./bin/augmenter.exe output/cb_2015_us_cd114_5m_reproj.shp   output/cb_2015_us_state_5m_reproj.shp   output/cb_2015_us_cd114_5m_scored.shp   STATEFP
	./bin/augmenter.exe output/cb_2015_us_cd114_20m_reproj.shp  output/cb_2015_us_state_20m_reproj.shp  output/cb_2015_us_cd114_20m_scored.shp  STATEFP
	#Process data
	./bin/res_bounded.py            output/cb_2015_us_cd114_500k_reproj.shp output/cb_2015_us_state_500k_reproj.shp output/cb_2015_us_cd114_500k_scored.shp STATEFP
	./bin/res_simp_together.py      data/cb_2015_us_cd114_500k.shp data/cb_2015_us_cd114_5m.shp data/cb_2015_us_cd114_20m.shp
	./bin/res_projections.py        data/cb_2015_us_cd114_500k.shp
	./bin/res_simp_indiv.py         data/cb_2015_us_cd114_500k.shp
	./bin/res_fig_gerrymandering.py data/cb_2015_us_cd114_500k.shp data/cb_2015_us_state_500k.shp
	#Extract the score data
	dbfdump output/cb_2015_us_cd114_500k_scored.shp  > output/scores500.csv
	dbfdump data/cb_2015_us_cd114_20m_scored.shp   > output/scores20.csv #TODO: CUt
	dbfdump data/cb_2015_us_cd114_5m_scored.shp    > output/scores5.csv #TODO: CUT
	#Generate the figures
	R --no-save < bin/make_figs.R
	#Generate district images
	./bin/districtplot.py 1205 1704 2103 2103 2103 2201 2201 2201 2402 2403 3701 3704 3712 4207 4833 4835
	#Crop figures
	ls imgs/*koch*pdf | xargs -n 1 -I {} pdfcrop {} {}
	ls imgs/fig_evil*pdf | xargs -n 1 -I {} pdfcrop {} {}

all:
	#Generate Koch snowflake generator
	$(CXX) -g -O3 -o koch.exe koch.cpp
	#Generate Koch snowflake data
	./koch.exe > koch.csv
	#Generate compactness CLI
	$(MAKE) -C submodules/compactness-cli
	#Reproject data
	ogr2ogr -f "ESRI Shapefile" data/cb_2015_us_cd114_500k_reproj.shp data/cb_2015_us_cd114_500k.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" data/cb_2015_us_cd114_5m_reproj.shp data/cb_2015_us_cd114_5m.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" data/cb_2015_us_cd114_20m_reproj.shp data/cb_2015_us_cd114_20m.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	#Reproject data
	ogr2ogr -f "ESRI Shapefile" data/cb_2015_us_state_5m_reproj.shp data/cb_2015_us_state_5m.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" data/cb_2015_us_state_500k_reproj.shp data/cb_2015_us_state_500k.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	ogr2ogr -f "ESRI Shapefile" data/cb_2015_us_state_20m_reproj.shp data/cb_2015_us_state_20m.shp -t_srs '+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,-0,-0,-0,0 +units=m +no_defs'
	#Process data
	./res_simp_together.py data/cb_2015_us_cd114_500k.shp data/cb_2015_us_cd114_5m.shp data/cb_2015_us_cd114_20m.shp
	./res_projections.py   data/cb_2015_us_cd114_500k.shp
	./res_simp_indiv.py    data/cb_2015_us_cd114_500k.shp
	./res_bounded.py       data/cb_2015_us_cd114_500k_reproj.shp data/cb_2015_us_state_500k_reproj.shp data/cb_2015_us_cd114_500k_scored.shp STATEFP
	#Augment shapefiles with score data
	./submodules/compactness-cli/compactness.exe data/cb_2015_us_cd114_500k_reproj.shp data/cb_2015_us_state_500k_reproj.shp data/cb_2015_us_cd114_500k_scored.shp STATEFP
	./submodules/compactness-cli/compactness.exe data/cb_2015_us_cd114_5m_reproj.shp   data/cb_2015_us_state_5m_reproj.shp   data/cb_2015_us_cd114_5m_scored.shp   STATEFP
	./submodules/compactness-cli/compactness.exe data/cb_2015_us_cd114_20m_reproj.shp  data/cb_2015_us_state_20m_reproj.shp  data/cb_2015_us_cd114_20m_scored.shp  STATEFP
	#Extract the score data
	dbfdump data/cb_2015_us_cd114_500k_scored.shp  > scores500.csv
	dbfdump data/cb_2015_us_cd114_20m_scored.shp   > scores20.csv
	dbfdump data/cb_2015_us_cd114_5m_scored.shp    > scores5.csv
	#Generate the figures
	R --no-save < make_figs.R





districtplot.py

res_fig_gerrymandering.py*


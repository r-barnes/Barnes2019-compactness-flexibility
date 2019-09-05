all:
	#Generate Koch snowflake generator
	$(CXX) -g -O3 -o koch.exe koch.cpp
	#Generate Koch snowflake data
	./koch.exe > koch.csv
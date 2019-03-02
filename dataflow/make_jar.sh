#!/bin/bash

if [ ! -e './NanostreamDataflowMain/libs/japsa.jar' ]; then
	echo 'cannot find ./NanostreamDataflowMain/libs/japsa.jar'
fi

mvn install:install-file -Dfile=NanostreamDataflowMain/libs/japsa.jar -DgroupId=coin -DartifactId=japsa -Dversion=1.9-3c -Dpackaging=jar
mvn install:install-file -Dfile=NanostreamDataflowMain/libs/pal1.5.1.1.jar -DgroupId=nz.ac.auckland -DartifactId=pal -Dversion=1.5.1.1 -Dpackaging=jar
cd NanostreamDataflowMain
mvn clean package
cd ..

if [ ! -e './NanostreamDataflowMain/target/NanostreamDataflowMain-1.0-SNAPSHOT.jar' ]; then
  echo 'not successfully built'
  exit 1;
if

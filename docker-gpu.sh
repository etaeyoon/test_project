#!/bin/bash

docker run -ti --rm --runtime=nvidia -v /media/bigdrive/data/autodriving:/home/anon/data -v ~/work/github/AuDri:/home/anon/AuDri -v ~/work/github/yekeun/AuDri:/home/anon/AuDri_yekeun -v ~/work/github/Ext_g2o:/home/anon/Ext_g2o --net host -e DISPLAY='unix:0.0' viogpuextg2o_app
#docker run -ti --rm --runtime=nvidia -v /media/bigdrive/data/autodriving:/home/anon/data -v ~/work/github/AuDri:/home/anon/AuDri -v ~/work/github/Ext_g2o:/home/anon/Ext_g2o -v ~/work/github/gyutae-park:/home/anon/gyutae-park --net host -e DISPLAY='unix:0.0' viogpuextg2o_app

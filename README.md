# Rigol ROF reader #

###`Work in progress!`###

## Overview ##

This is a [Rigol](http://rigolna.com) ROF file reader. ROF files contail recorded 
data from bench power supplies such as the [DP832](http://www.rigolna.com/products/dc-power-supplies/dp800/dp832).

The format proprietary, but luckily it has already been reverse engineered: [https://sigrok.org](https://sigrok.org/wiki/File_format:Rigol_rof).

## Parser ##

The parser is written in [Haskell](https://www.haskell.org/).


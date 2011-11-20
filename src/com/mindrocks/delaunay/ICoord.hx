package com.mindrocks.delaunay;

import flash.geom.Point;

interface ICoord {
	public var coord(get_coord, null):Point;
	public function get_coord():Point;
}

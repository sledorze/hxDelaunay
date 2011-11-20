package com.mindrocks.delaunay;

import flash.Vector;

/**
 * ...
 * @author sledorze
 */

class VectorHelper  {
	
	inline public static function filter<T>(v : Vector<T>, pred : T -> Bool) : Vector<T> {
		var res = new Vector<T>();
		for (e in v) {
			if (pred(e))
				res.push(e);
		}
		return res;
	}
}
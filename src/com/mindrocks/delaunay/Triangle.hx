package com.mindrocks.delaunay;

import flash.Vector;

@:final class Triangle {
	private var _sites:Vector<Site>;
	public var sites(get_sites, null) : Vector<Site>;
	inline public function get_sites():Vector<Site> {
		return _sites;
	}
	
	inline public function Triangle(a:Site, b:Site, c:Site) {
//		_sites = new Vector<Site>([ a, b, c ]);
		_sites = new Vector<Site>(3, true);
		_sites[0] = a;
		_sites[1] = b;
		_sites[2] = c;	
	}
	
	inline public function dispose():Void {
		_sites.length = 0;
		_sites = null;
	}

}

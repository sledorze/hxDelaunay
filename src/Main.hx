package ;

import com.mindrocks.delaunay.Voronoi;
import flash.Lib;

/**
 * ...
 * @author sledorze
 */

class Main 
{
	var voro : Voronoi;
	static function main() 
	{
		new Main();
	}
	function new() {
		voro = new Voronoi(null, null, null);
	}
}
package com.mindrocks.delaunay;

import flash.geom.Point;
import flash.display.BitmapData;
import flash.Vector;
import com.mindrocks.geom.LineSegment;

using com.mindrocks.delaunay.VectorHelper;

class SelectHelper {

	
	public static function visibleLineSegments(edges:Vector<Edge>):Vector<LineSegment>
	{
		var segments = new Vector<LineSegment>();
	
		for (edge in edges) {
			if (edge.visible) {
				var p1 = edge.clippedEnds(LR.LEFT);
				var p2 = edge.clippedEnds(LR.RIGHT);
				segments.push(new LineSegment(p1, p2));
			}
		}
		
		return segments;
	}
	
	public static function selectNonIntersectingEdges(keepOutMask:BitmapData, edgesToTest:Vector<Edge>):Vector<Edge> {
		if (keepOutMask == null)
		{
			return edgesToTest;
		}
		
		var zeroPoint:Point = new Point();
		
		return edgesToTest.filter(
			function (edge:Edge):Bool {
				var delaunayLineBmp = edge.makeDelaunayLineBmp();
				var notIntersecting = !(keepOutMask.hitTest(zeroPoint, 1, delaunayLineBmp, zeroPoint, 1));
				delaunayLineBmp.dispose();
				return notIntersecting;
			}
		);		
	}
	
	public static function selectEdgesForSitePoint(coord:Point, edgesToTest:Vector<Edge>):Vector<Edge>
	{
		return edgesToTest.filter(
			function (edge:Edge)
				return ((edge.leftSite!=null && edge.leftSite.coord == coord) ||  (edge.rightSite!=null && edge.rightSite.coord == coord))
		);
	}	
	
	public static function delaunayLinesForEdges(edges:Vector<Edge>):Vector<LineSegment>
	{
		var segments = new Vector<LineSegment>();
		for (edge in edges) {
			segments.push(edge.delaunayLine());
		}
		return segments;
	}	
	
}
	

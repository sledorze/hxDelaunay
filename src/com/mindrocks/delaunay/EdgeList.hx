package com.mindrocks.delaunay;

import com.mindrocks.utils.IDisposable;

import flash.geom.Point;
import flash.Vector;

@:final class EdgeList implements IDisposable {
	
	private var _deltax:Float;
	private var _xmin:Float;
	
	private var _hashsize:Int;
	private var _hash:Vector<Halfedge>;
	private var _leftEnd:Halfedge;
	public var leftEnd(get_leftEnd, null):Halfedge;
	
	inline public function get_leftEnd():Halfedge {
		return _leftEnd;
	}
	private var _rightEnd:Halfedge;
	public var rightEnd(get_rightEnd, null):Halfedge;
	inline public function get_rightEnd():Halfedge {
		return _rightEnd;
	}
	
	public function dispose():Void
	{
    
		var halfEdge:Halfedge = _leftEnd;
		var prevHe:Halfedge;
		while (halfEdge != _rightEnd)
		{
			prevHe = halfEdge;
			halfEdge = halfEdge.edgeListRightNeighbor;
			prevHe.dispose();
		}
		_leftEnd = null;
		_rightEnd.dispose();
		_rightEnd = null;

		var i:Int;
		for (i in 0..._hashsize) {
			_hash[i] = null;
		}
		_hash = null;
	}
	
	public function new(xmin:Float, deltax:Float, sqrt_nsites:Int) {
		_xmin = xmin;
		_deltax = deltax;
		_hashsize = 2 * sqrt_nsites;

//		var i:Int;
		_hash = new Vector<Halfedge>(_hashsize, true);
		
		// two dummy Halfedges:
		_leftEnd = Halfedge.createDummy();
		_rightEnd = Halfedge.createDummy();
		_leftEnd.edgeListLeftNeighbor = null;
		_leftEnd.edgeListRightNeighbor = _rightEnd;
		_rightEnd.edgeListLeftNeighbor = _leftEnd;
		_rightEnd.edgeListRightNeighbor = null;
		_hash[0] = _leftEnd;
		_hash[_hashsize - 1] = _rightEnd;
	}

	/**
	 * Insert newHalfedge to the right of lb 
	 * @param lb
	 * @param newHalfedge
	 * 
	 */
	public function insert(lb:Halfedge, newHalfedge:Halfedge):Void
	{
		newHalfedge.edgeListLeftNeighbor = lb;
		newHalfedge.edgeListRightNeighbor = lb.edgeListRightNeighbor;
		lb.edgeListRightNeighbor.edgeListLeftNeighbor = newHalfedge;
		lb.edgeListRightNeighbor = newHalfedge;
	}

	/**
	 * This function only removes the Halfedge from the left-right list.
	 * We cannot dispose it yet because we are still using it. 
	 * @param halfEdge
	 * 
	 */
	
	public function remove(halfEdge:Halfedge):Void
	{
		halfEdge.edgeListLeftNeighbor.edgeListRightNeighbor = halfEdge.edgeListRightNeighbor;
		halfEdge.edgeListRightNeighbor.edgeListLeftNeighbor = halfEdge.edgeListLeftNeighbor;
		//trace("RRRRRRREEEEEEEEEEEEEMMMMMMMMMMMOOOOOOOOOOVVVVVVVVVVVEEEEEEEEEEEDDDDDDDDDD");
		halfEdge.edge = Edge.DELETED;
		halfEdge.edgeListLeftNeighbor = halfEdge.edgeListRightNeighbor = null;
	}

	/**
	 * Find the rightmost Halfedge that is still left of p 
	 * @param p
	 * @return 
	 * 
	 */
	public function edgeListLeftNeighbor(p:Point):Halfedge {
		
		/* Use hash table to get close to desired halfedge */
		var bucket = Std.int(((p.x - _xmin)/_deltax) * _hashsize);
		if (bucket < 0) {
			bucket = 0;
		}
		if (bucket >= _hashsize) {
			bucket = _hashsize - 1;
		}
		
		var halfEdge = getHash(bucket);
		if (halfEdge == null) {
			var i = 1;
			while (true) {
				halfEdge = getHash(bucket - i);
				if (halfEdge != null) break;
				halfEdge = getHash(bucket + i);
				if (halfEdge != null) break;
				i++;
			}
		}
		
		/* Now search linear list of halfedges for the correct one */
		if (halfEdge == leftEnd  || (halfEdge != rightEnd && halfEdge.isLeftOf(p)))
		{
			do
			{
				halfEdge = halfEdge.edgeListRightNeighbor;
			}
			while (halfEdge != rightEnd && halfEdge.isLeftOf(p));
			halfEdge = halfEdge.edgeListLeftNeighbor;
		}
		else
		{
			do
			{
				halfEdge = halfEdge.edgeListLeftNeighbor;
			}
			while (halfEdge != leftEnd && !halfEdge.isLeftOf(p));
		}
		
		/* Update hash table and reference counts */
		if (bucket > 0 && bucket <_hashsize - 1)
		{
			_hash[bucket] = halfEdge;
		}
		return halfEdge;
	}

	/* Get entry from hash table, pruning any deleted nodes */
	inline private function getHash(b:Int):Halfedge {
		var halfEdge:Halfedge = null;
		
		if (b >= 0 && b < _hashsize) {
			halfEdge = _hash[b]; 
			if (halfEdge != null && halfEdge.edge == Edge.DELETED)
			{
				/* Hash table points to deleted halfedge.  Patch as necessary. */
				_hash[b] = null;
				// still can't dispose halfEdge yet!
				halfEdge = null;
			}
		}
		return halfEdge;
	}

}

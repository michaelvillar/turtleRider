var LoopingSegment = function(segment) {
	this.originalSegment = segment;
	this.mid = null;
	this.controlStart = null;
	this.controlEnd = null;
	this.circleCenter = null;
	this.circleRadius = 100;
	this.selectedPoint = null;

	this.init();
};

LoopingSegment.unarchive = function(archive) {
	var originalSegment = CurveSegment.unarchive(archive['original_segment']);
	return new LoopingSegment(originalSegment);
};

LoopingSegment.prototype.archive = function() {
	var archive = {};
	archive["type"] = 2;
	archive["original_segment"] = this.originalSegment.archive();

	var startPoints = [];
	var endPoints = [];
	var pointsCount = Math.floor(this.originalSegment.length() / Main.pointFrequence);
	var tInc = 1 / pointsCount;
	var midPassed = false;
	for (var t = 0; t <= 1; t += tInc) {
		if (t + tInc > 1)
			t = 1;
	
		var x = (1 - t) * (1 - t) * this.originalSegment.start.x + 2 * (1 - t) * t * this.originalSegment.control.x + t * t * this.originalSegment.end.x;
		var y = (1 - t) * (1 - t) * this.originalSegment.start.y + 2 * (1 - t) * t * this.originalSegment.control.y + t * t * this.originalSegment.end.y;
		var point = new Point(x, y);
		if (!midPassed && x > this.mid.x) {
			x = this.mid.x;
			y = this.mid.y;
		}

		if (x <= this.mid.x)
			startPoints.push(point.archive());
	 	else
	 		endPoints.push(point.archive());
	}

	var circleLength = 2 * Math.PI * this.circleRadius;
	pointsCount = Math.floor(circleLength / Main.pointFrequence);
	var startAngle = Math.atan((this.circleCenter.y - this.mid.y) / (this.circleCenter.x - this.mid.x));
	var aInc = 2 * Math.PI / pointsCount;

	for (var a = startAngle; a <= startAngle + 2 * Math.PI; a += aInc) {
		if (a + aInc > startAngle + 2 * Math.PI)
			a = startAngle + 2 * Math.PI;

		var point = new Point(this.circleCenter.x + this.circleRadius * Math.cos(a), this.circleCenter.y + this.circleRadius * Math.sin(a));
		startPoints.push(point.archive());
	}

	archive["all_points"] = startPoints.concat(endPoints);

	return archive;
};

LoopingSegment.prototype.init = function() {
	this.start = this.originalSegment.start;
	this.end = this.originalSegment.end;

	var t = 0.5;
	var midX = (1 - t) * (1 - t) * this.start.x + 2 * (1 - t) * t * this.originalSegment.control.x + t * t * this.end.x;
	var midY = (1 - t) * (1 - t) * this.start.y + 2 * (1 - t) * t * this.originalSegment.control.y + t * t * this.end.y;
	this.mid = new Point(midX, midY);

	var cxStart = this.start.x + (this.mid.x - this.start.x) / 2;
	var cyStart = this.start.y + (cxStart - this.start.x) * this.startSlope();
	this.controlStart = new Point(cxStart, cyStart);

	var cxEnd = this.mid.x + (this.end.x - this.mid.x) / 2;
	var cyEnd = this.end.y - (this.end.x - cxEnd) * this.endSlope();
	this.controlEnd = new Point(cxEnd, cyEnd);

	var slope = (this.end.y - this.start.y) / (this.end.x - this.start.x);
	slope = -1 / slope; 

	var angle = Math.atan(slope);
	if (slope > 0)
		angle += Math.PI;

	var circleX = midX + Math.cos(angle) * this.circleRadius;
	var circleY = midY + Math.sin(angle) * this.circleRadius;
	this.circleCenter = new Point(circleX, circleY);
};

LoopingSegment.prototype.startSlope = function() {
	return this.originalSegment.startSlope();
};

LoopingSegment.prototype.endSlope = function() {
	return this.originalSegment.endSlope();
};

LoopingSegment.prototype.selectPoint = function(point, withStart) {
	var offset = 8;

	if (point.x > this.end.x - offset && point.x < this.end.x + offset && point.y > this.end.y - offset && point.y < this.end.y + offset) {
		this.selectedPoint = "end";
		return true;
	}

	if (withStart && point.x > this.start.x - offset && point.x < this.start.x + offset && point.y > this.start.y - offset && point.y < this.start.y + offset) {
		this.selectedPoint = "start";
		return true;
	}

	return false;
};

LoopingSegment.prototype.deselect = function() {
	this.selectedPoint = null;
};

LoopingSegment.prototype.boundingRect = function() {
	var origin = new Point(Math.min(this.start.x, this.controlStart.x, this.controlEnd.x, this.end.x), this.circleCenter.y - this.circleRadius);
	var width = this.end.x - this.start.x;
	var height = Math.max(Math.abs(this.end.y - origin.y), Math.abs(this.controlStart.y - origin.y), Math.abs(this.start.y - origin.y), Math.abs(this.controlEnd.y - origin.y));
	return {"origin": origin, size: {"width": width, "height": height}};
};

LoopingSegment.prototype.draw = function(ctx) {
	ctx.save();
	ctx.beginPath();
	ctx.moveTo(this.start.x, this.start.y);
	ctx.quadraticCurveTo(this.controlStart.x, this.controlStart.y, this.mid.x, this.mid.y);
	ctx.stroke();
	ctx.quadraticCurveTo(this.controlEnd.x, this.controlEnd.y, this.end.x, this.end.y);
	ctx.stroke();
	ctx.fillStyle = "rgb(0, 0, 0)"; 
	ctx.fillRect(this.end.x - 4, this.end.y - 4, 8, 8);

	ctx.closePath();

	ctx.beginPath();
	ctx.strokeStyle = "rgb(0, 0, 0)";  
	ctx.arc(this.circleCenter.x, this.circleCenter.y, this.circleRadius, 0, Math.PI * 2);
	ctx.stroke();
  ctx.restore();
};
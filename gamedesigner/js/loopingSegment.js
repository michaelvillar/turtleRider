var LoopingSegment = function(segment) {
	this.beziers = null;
	this.circle = null;
	this.originalSegment = segment;
	this.mid = null;
	this.control = null;
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
	archive["beziers"] = [];

	for (var i = 0; i < this.beziers.length; i++) {
		var bezier = {
			"start": this.beziers[i].start.archive(),
			"control": this.beziers[i].control.archive(),
			"end": this.beziers[i].end.archive(),
			"arc_length": this.lengthOfBezier(this.beziers[i])
		};
		archive["beziers"].push(bezier);
	}

	archive["circle"] = {
		"center": this.circle.center.archive(),
		"radius": this.circle.radius
	};

	archive["original_segment"] = this.originalSegment.archive();
	return archive;
};

LoopingSegment.prototype.pointForX = function(x) {
	return this.originalSegment.pointForX(x);
}

LoopingSegment.prototype.init = function() {
	this.start = this.originalSegment.start;
	this.end = this.originalSegment.end;

	var radius = 100;
	this.circle = {
		"center": new Point(this.end.x - 20 - radius, this.end.y - radius),
		"radius": radius
	};

	var slope = this.originalSegment.startSlope();
	var mid = new Point(this.circle.center.x, this.start.y + (this.circle.center.x - this.start.x) * this.originalSegment.startSlope());

	var bezier1 = {
		"start": this.start,
		"control": new Point(this.start.x + (mid.x - this.start.x) / 2, this.start.y + (mid.y - this.start.y) / 2),
		"end": mid
	};

	var bezier2 = {
		"start": bezier1.end,
		"control": new Point(this.circle.center.x + this.circle.radius, bezier1.end.y + (this.circle.center.x + this.circle.radius - bezier1.end.x) * this.originalSegment.startSlope()),
		"end": new Point(this.circle.center.x + this.circle.radius, this.circle.center.y)
	};

	var bezier3 = {
		"start": new Point(this.circle.center.x, this.circle.center.y + this.circle.radius),
		"control": new Point(this.circle.center.x + 20, this.circle.center.y + this.circle.radius),
		"end": this.end
	}

	this.beziers = [bezier1, bezier2, bezier3];
};

LoopingSegment.prototype.lengthOfBezier = function(bezier) {
	var ax = bezier.start.x - 2*bezier.control.x + bezier.end.x;
	var ay = bezier.start.y - 2*bezier.control.y + bezier.end.y;
	var bx = 2*bezier.control.x - 2*bezier.start.x;
	var by = 2*bezier.control.y - 2*bezier.start.y;
	
	var a = 4*(ax*ax + ay*ay);
	var b = 4*(ax*bx + ay*by);
	var c = bx*bx + by*by;
	
	var abc = 2*Math.sqrt(a+b+c);
	var a2  = Math.sqrt(a);
	var a32 = 2*a*a2;
	var c2  = 2*Math.sqrt(c);
	var ba  = b/a2;
	var length = (a32*abc + a2*b*(abc-c2) + (4*c*a-b*b)*Math.log((2*a2+ba+abc)/(ba+c2)))/(4*a32);
	if (Number.isNaN(length)) {
		return Math.sqrt(Math.pow(bezier.end.x - bezier.start.x, 2) + Math.pow(bezier.end.y - bezier.start.y, 2));
	}
	return length;
};

LoopingSegment.prototype.startSlope = function() {
	return this.originalSegment.startSlope();
};

LoopingSegment.prototype.endSlope = function() {
	return 0;
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
	var origin = new Point(Math.min(this.start.x, this.circle.center.x - this.circle.radius), this.circle.center.y - this.circle.radius);
	var width = this.end.x - origin.x;
	var height = Math.max(Math.abs(this.circle.center.y - this.end.y), Math.abs(this.circle.center.y - this.start.y), Math.abs(this.circle.center.y - this.beziers[0].end.y)) + this.circle.radius;
	return {"origin": origin, size: {"width": width, "height": height}};
};

LoopingSegment.prototype.draw = function(ctx) {
	ctx.save();
	ctx.fillRect(this.end.x - 4, this.end.y - 4, 8 ,8);

	ctx.beginPath();
	ctx.moveTo(this.beziers[0].start.x, this.beziers[0].start.y);
	ctx.quadraticCurveTo(this.beziers[0].control.x, this.beziers[0].control.y, this.beziers[0].end.x, this.beziers[0].end.y);
	ctx.quadraticCurveTo(this.beziers[1].control.x, this.beziers[1].control.y, this.beziers[1].end.x, this.beziers[1].end.y);
	ctx.moveTo(this.beziers[2].start.x, this.beziers[2].start.y);
	ctx.quadraticCurveTo(this.beziers[2].control.x, this.beziers[2].control.y, this.beziers[2].end.x, this.beziers[2].end.y);

	ctx.arc(this.circle.center.x, this.circle.center.y, this.circle.radius, Math.PI / 2, 0);

	ctx.stroke();
  ctx.restore();
};
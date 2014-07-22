var CameraGuide = function(point) {
	this.position = point;
	this.side = 12;
	this.flexibleSpan = 200;
};

CameraGuide.unarchive = function(archive) {
	return new CameraGuide(Point.unarchive(archive['position']));
};

CameraGuide.prototype.pointInside = function(point) {
	return (point.x > this.position.x - this.side / 2 && point.x < this.position.x + this.side / 2 &&
				  point.y > this.position.y - this.side / 2 && point.y < this.position.y + this.side / 2);
};

CameraGuide.prototype.move = function(point) {
	this.position = point;
};

CameraGuide.prototype.archive = function() {
	return {"position": this.position.archive()};
};

CameraGuide.prototype.draw = function(ctx, color) {
	ctx.save();
	ctx.beginPath();
	ctx.lineWidth = 2;
  ctx.strokeStyle = color;
  ctx.strokeRect(this.position.x - this.side / 2, this.position.y - this.side / 2, this.side, this.side);
  ctx.restore();
};
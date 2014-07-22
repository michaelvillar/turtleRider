var ScaleGuide = function(point) {
	this.position = point;
	this.radius = 7;
	this.value = 0;
};

ScaleGuide.unarchive = function(archive) {
	var scaleGuide = new ScaleGuide(Point.unarchive(archive['position']));
	scaleGuide.updateValue(archive['value']);
	return scaleGuide;
};

ScaleGuide.prototype.pointInside = function(point) {
	return (point.x > this.position.x - this.radius && point.x < this.position.x + this.radius &&
			point.y > this.position.y - this.radius && point.y < this.position.y + this.radius);
};

ScaleGuide.prototype.move = function(point) {
	this.position = point;
};

ScaleGuide.prototype.updateValue = function(value) {
	this.value = value;
}

ScaleGuide.prototype.archive = function() {
	return {"position": this.position.archive(),
					"value": this.value};
};

ScaleGuide.prototype.draw = function(ctx) {
	ctx.save();
	ctx.beginPath();
	ctx.arc(this.position.x, this.position.y, this.radius, 0, 2 * Math.PI, false);
  ctx.lineWidth = 2;
  ctx.strokeStyle = 'rbg(0, 0, 0)';
  ctx.stroke();

  ctx.beginPath();
  ctx.arc(this.position.x, this.position.y, this.radius * this.value, 0, 2 * Math.PI, false);
  ctx.fillStyle = 'rgb(0, 0, 0)';
  ctx.fill();

 	ctx.fillText(this.value, 
  						 this.position.x - ctx.measureText(this.value).width / 2,
  						 this.position.y - 30);
  ctx.restore();
};
var Point = function(x, y) {
	this.x = x;
	this.y = y;
};

Point.unarchive = function(archive) {
	return new Point(archive['x'] + Main.origin.x, archive['y'] + Main.origin.y);
};

Point.prototype.archive = function() {
	return {"x": this.x - Main.origin.x, "y": this.y - Main.origin.y};
};
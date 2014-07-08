var FileManager = function() {
};

FileManager.saveToDisk = function(archive) {
	var blob = new Blob([JSON.stringify(archive)], {type: "application/json"});
	var url = URL.createObjectURL(blob);

	var a = document.createElement('a');
	a.download = "level.json";
	a.href = url;
	a.click();
};

FileManager.loadFile = function(f, callback) {
	if (!f.type.match('.json'))
		return null;

  var reader = new FileReader();
  reader.onload = (function(file) {
    return function(e) {
    	callback(JSON.parse(e.target.result));
    };
  })(f);

  reader.readAsText(f);
}


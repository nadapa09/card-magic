			// Grab elements, create settings, etc.
document.addEventListener('DOMContentLoaded', function() {
			var video = document.getElementById('video');

			// Get access to the camera!
			    // Not adding `{ audio: true }` since we only want video now
      var success = function (stream) {
        video.src = window.URL.createObjectURL(stream);
        video.play();
      }.bind(this);

      var failure = function (stream) {
        alert("ERROR");
      }.bind(this);

			navigator.getUserMedia({ video: true, audio: false }, success, failure);
    /*
  var checkPageButton = document.getElementById('checkPage');
  checkPageButton.addEventListener('click', function() {

    chrome.tabs.getSelected(null, function(tab) {
      d = document;

      var f = d.createElement('form');
      f.action = 'http://gtmetrix.com/analyze.html?bm';
      f.method = 'post';
      var i = d.createElement('input');
      i.type = 'hidden';
      i.name = 'url';
      i.value = tab.url;
      f.appendChild(i);
      d.body.appendChild(f);
      f.submit();
    });
  }, false);
    */
}, false);

function Methods () {
  this.initialize.apply(this, arguments);
}

Methods.prototype = {
  initialize: function() {
    this.accessor = new Accessor(this);
    this.recognition = new webkitSpeechRecognition();
    this.recognition.lang = "ja-JP";
    this.recognition.interimResults = true;
    this.recognition.continuous = true;
    this.recognition.maxAlternatives = 10;
    var this_ = this;

    this.recognition.onsoundstart = function(){
      console.log("soundstart");
    };

    this.recognition.onnomatch = function(){
      console.log("nomatch");
    };

    this.recognition.onerror= function(e){
      console.log("error");
      console.log(e);
      setTimeout(function() {
        this_.recognition.start();
      }, 200);
    };

    this.recognition.onsoundend = function(){
      console.log("soundend");
      this_.recognition.stop();
      setTimeout(function() {
        this_.recognition.start();
      }, 200);
    };

    this.recognition.onresult = function(event){
      console.log(event);
      var results = event.results;
      if(results[results.length - 1].isFinal){
        console.log(results[results.length - 1][0].transcript);
        this_.accessor.call_method_asynchronous("result", results[results.length - 1][0].transcript);
      }
    };
  },
  start_speech_recognition: function() {
    this.recognition.start();
  },
  accessor_close: function() {
    this.recognition.stop();
  }
};

var main = new Methods();

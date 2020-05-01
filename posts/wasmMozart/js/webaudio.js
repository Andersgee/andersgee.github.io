function webaudio() {
  var audio = new AudioContext();
  return audio;
}

async function fetchnotes(url) {
  var notes = [];
  for (var i=0; i<96; i++) {
    notes[i] = fetchnote(url, i);
  }
  return await Promise.all(notes);
}

function fetchnote(url, n) {
  var note = {};
  var filename = url+"notes/n"+(n+1)+".mp3";
  fetch(filename)
  .then(res=>res.arrayBuffer())
  .then(buf=>audio.decodeAudioData(buf))
  .then(decoded=>{note.buffer = decoded;});
  return note
}

function playnote(n, v) {
  var source = audio.createBufferSource();
  source.buffer = notes[n].buffer;

  var gain = audio.createGain();
  gain.gain.value = v*1.0;

  source.connect(gain).connect(audio.destination);
  //return source
  source.start();
}

function playnotes(velocity) {
  for (var i=0; i<96; i++) {
    if (velocity[i]>0 && i+12<96) { 
      //note to self: format0 (which its trained on) has different middle C than format1 style (which I have mp3 notes of?)
      //in any case; adding an octave (12 notes) sounds correct.
      playnote(i+12, velocity[i]);
    }
  }  
}

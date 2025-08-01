import React, { useState } from 'react';

export default function VoiceRecorder() {
  const [isRecording, setIsRecording] = useState(false);

  const toggleRecording = () => {
    setIsRecording(!isRecording);
    // Voice capture logic goes here
  };

  return (
    <div>
      <h2>Voice Intake</h2>
      <button onClick={toggleRecording}>
        {isRecording ? 'Stop Recording' : 'Start Recording'}
      </button>
    </div>
  );
}

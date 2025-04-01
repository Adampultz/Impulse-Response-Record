# Impulse Response Record
Environment for recording impulse responses.

Please note: this is a very basis setup for recording impulse responses and could do with an upgrade.
It plays an exponential sine sweep and, through deconvolution, creates an impulse response.

Both the impulse response and the object sweep responses will be saved when pressing "Save Response".

Make sure you have SuperCollider installed, as well as the Signal Box Quark.

Open the QSF_ImpulseRec_1.07 file.
The only thing you need to do here is to manually type in your interface surrounded by "". See the Fireface example already in there
Now place the cursor on line 1 and press command + enter.
This should open a GUI.

Start by dragging the folder where you want to store your files to the box at the top of the GIU.
Then type the name of your file in the box below and press enter.
Important: Any change you make in the GUI needs to be confirmed by pressing enter.

Depending on which channel your speaker is on, you need to adjust the output channel (it is currently 2).
You can Test the total system delay by clicking "Get system delay". Do this a few times and choose the value that appears most frequently. Note this down, as it is currently not saved in the file name.

Then press "Play Sine" and the exponential sine sweep should be audible.

Wait until the waveforms appear. You can then Monitor the sweep response of the object, as well as the actual impulse response.
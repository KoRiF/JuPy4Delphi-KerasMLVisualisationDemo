'''
    A proxy unit to establish a callback bridge between a Delphi based front-end and
    a Python-based training code for a deep learning model.


'''
import json
from keras.callbacks import Callback

import delphi_module

class DelphiTrainingCallback(Callback):

    def on_epoch_end(self, epoch, logs={}):
        print("\nlog:", json.dumps(logs))
        #flag = delphy4python.training_callback(epoch, logs.get("val_accuracy"), logs.get("val_loss"))
        flag = delphi_module.training_callback(epoch, json.dumps(logs))
        if flag=="stop":
            print("Training is stopped by Delphi's flag")
            self.model.stop_training = True


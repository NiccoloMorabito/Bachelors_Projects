import matplotlib.pyplot as plt
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Activation
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import Dense
from get_train_and_test import get_train_and_test, model_path, n_classes

print("\n\n\n")

# parameters
_epochs = 30
_batch_size = 128

# Load datasets
X_train, y_train, Y_train, X_test, y_test, Y_test = get_train_and_test()

# Building a linear stack of layers with the sequential model
model = Sequential()
model.add(Dense(512, input_shape=(28*28*3,)))
model.add(Activation('relu'))                            
model.add(Dropout(0.2))
model.add(Dense(512))
model.add(Activation('relu'))
model.add(Dropout(0.2))
model.add(Dense(n_classes))
model.add(Activation('softmax'))

# Compiling the sequential model
model.compile(loss='categorical_crossentropy', metrics=['accuracy'], optimizer='adam')

# Training the model and saving metrics in history
history = model.fit(X_train, Y_train,
          batch_size=_batch_size, epochs=_epochs,
          verbose=2,
          validation_data=(X_test, Y_test))

# Saving the model
model.save(model_path)
print('Saved trained model at %s ' % model_path)

# Plotting the metrics
fig = plt.figure()
plt.subplot(2,1,1)
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('model accuracy')
plt.ylabel('accuracy')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='lower right')

plt.subplot(2,1,2)
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper right')

plt.tight_layout()


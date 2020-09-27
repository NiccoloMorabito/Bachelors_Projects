import numpy as np
import os
import cv2
from keras.utils import np_utils
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

# paths
train_dir = 'DITS-full/DITS-classification/classification train'
test_dir = 'DITS-full/DITS-classification/classification test'
model_path = 'results/hw5_model.h5'

img_size = 28
n_classes = 59

def get_all_images(dir_name):
    '''Returns the paths of all the images in dir_name'''
    files_list = os.listdir(dir_name)
    all_files = list()
    
    for entry in files_list:
        path = os.path.join(dir_name, entry)
        if os.path.isdir(path):
            all_files = all_files + get_all_images(path)
        else:
            all_files.append(path)
        
    return all_files


def load_data(data_dir, img_size, position_class):
    images = list()
    classes = list()
    
    for img_path in get_all_images(data_dir):
        img_class = int(img_path.split("/")[-position_class])
        image = cv2.imread(img_path)
        image_rs = cv2.resize(image, (img_size, img_size), 3)
        R, G, B = cv2.split(image_rs)
        img_r = cv2.equalizeHist(R)
        img_g = cv2.equalizeHist(G)
        img_b = cv2.equalizeHist(B)
        new_image = cv2.merge((img_r, img_g, img_b))     
        
        images.append(new_image)
        classes.append(img_class)
    
    X = np.array(images)
    Y = np.array(classes)
    
    return (X, Y)

def get_train_and_test():
    # Loading datasets
    (X_train, y_train) = load_data(train_dir, img_size, 3)
    (X_test, y_test) = load_data(test_dir, img_size, 2)
    
    # Building the input vector from the 28x28x3 pixels
    X_train = X_train.reshape((X_train.shape[0], X_train.shape[1] * X_train.shape[2] * 3))
    X_test = X_test.reshape((X_test.shape[0], X_test.shape[1] * X_test.shape[2] * 3))
    X_train = X_train.astype('float32')
    X_test = X_test.astype('float32')
    
    # Normalizing the data to help with the training
    X_train /= 255
    X_test /= 255
    
    # One-hot encoding using keras' numpy-related utilities
    Y_train = np_utils.to_categorical(y_train, n_classes)
    Y_test = np_utils.to_categorical(y_test, n_classes)
    
    return X_train, y_train, Y_train, X_test, y_test, Y_test




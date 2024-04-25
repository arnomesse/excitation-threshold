import numpy as np 
import tensorflow as tf 
from tensorflow.keras import backend as K
import matplotlib.pyplot as plt
import copy

# load MNIST training/test datasets
(x_train, y_train),\
	(x_test, y_test) = tf.keras.datasets.mnist.load_data() 

# normalize the images 
x_train = x_train/255
x_test = x_test/255

# define custom activation steep function 
def custact(x):
    return K.sigmoid(50*x)

tf.keras.utils.get_custom_objects().update({'custact': custact})

# define the single layer perceptron model 
model = tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(300, 
    	kernel_constraint=tf.keras.constraints.non_neg(), 
    	kernel_regularizer=tf.keras.regularizers.L1L2(l1=1e-2, l2=1e-4), 
    	activation=custact), 
    tf.keras.layers.Dense(10, 
    	kernel_constraint=tf.keras.constraints.non_neg(), 
     	activation='softmax')
])

model.summary()

# run simulations over multiple runs
runs = 50
thrlist = np.linspace(-0.25,0.25,51) 

res = np.empty(shape=(runs,2))                       # loss and accuracy of the trained weighted models on the testing data over rune
dens = np.empty(shape=(runs))                        # density of connections between the input and hidden layer of the weighted models over runs
resthr = np.empty(shape=(runs,len(thrlist),2))       # loss and accuracy of the thresholded and binarized models on the testing data over runs and threshold values
densthr = np.empty(shape=(runs,len(thrlist)))        # density of connections between the input and hidden layer of thresholded and binarized models over runs and threshold values

for run in range(runs):
	testmodel = tf.keras.models.clone_model(model)
	testmodel.compile( optimizer='sgd', loss='sparse_categorical_crossentropy', metrics=['accuracy']) 
	
	testmodel.fit(x=x_train, y=y_train, epochs=10)
	res[run, :] = testmodel.evaluate(x_test, y_test) 
	
	dat = testmodel.get_weights()
	dens[run] = np.count_nonzero(dat[0])
	newdat = copy.deepcopy(dat)
	newdat[1].fill(0)

	for idx, thr in enumerate(thrlist):
		mask = (dat[0]+dat[1][None,:])>thr
		newdat[0][mask] = 1
		newdat[0][np.logical_not(mask)] = 0
		newdat[0][dat[0]==0] = 0
		densthr[run, idx] = np.count_nonzero(newdat[0])
		testmodel.set_weights(newdat)
		resthr[run, idx, :] = testmodel.evaluate(x_test, y_test) 

dens = dens/np.size(newdat[0])
densthr = densthr/np.size(newdat[0])

# display results
plt.figure(1)
plt.subplot(121)
plt.plot(thrlist,np.mean(resthr[:, :, 1],0), color='b')
plt.axhline(y=np.mean(res[:, 1],0), color='r', linestyle='-')
plt.xlabel("threshold")
plt.ylabel("accuracy")
plt.grid()

plt.subplot(122)
plt.plot(thrlist,np.mean(densthr,0), color='b')
plt.axhline(y=np.mean(dens,0), color='r', linestyle='-')
plt.xlabel("threshold")
plt.ylabel("density")
plt.grid()

plt.legend(["binary", "weighted"])

plt.show()


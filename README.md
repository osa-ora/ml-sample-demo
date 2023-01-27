# Red Hat OpenShift ML Demo

Red Hat OpenShift Data Science (RHODS) is an easy-to-configure MLOps platform for building and deploying AI/ML models and intelligent applications. In this demo we will go through how to use it to build and deploy ML applications easily.  

This sample is based on fork from Red Hst Git Repo:  
https://redhat-scholars.github.io/rhods-lp-workshop/rhods-lp-workshop/index.html

The tutorial for building this application is also here:
https://redhat-scholars.github.io/rhods-lp-workshop/rhods-lp-workshop/index.html


The project is detecting the car plate numbers, here we will demo this application over OpenShift to show how we can utilize the power of OpenShift in handling the different milestone in ML application.


<img width="583" alt="Screen Shot 2023-01-27 at 17 51 25" src="https://user-images.githubusercontent.com/18471537/215102893-4a08f502-4d32-4d96-9b44-62383c59e110.png">


## 1) Get The Environment

We need an OpenShift cluster to use, the easiest way is to utilize the Red Hat OpenShift Developer Sandbox which gives us a free trial of OpenShift and it includes access to OpenShift Data Science.

Go to: https://developers.redhat.com/developer-sandbox and register for the sandbox.

<img width="1407" alt="Screen Shot 2023-01-27 at 17 52 04" src="https://user-images.githubusercontent.com/18471537/215103044-31e01e34-ee65-4c82-adc3-e87c8955af81.png">

Open the sandbox to land on OpenShift console, then navigate to the Data Science as in the following picture:

<img width="1340" alt="Screen Shot 2023-01-27 at 17 55 04" src="https://user-images.githubusercontent.com/18471537/215103713-50ea46ea-ba35-411d-827d-804b1fc232cb.png">

After authentication and authorization, you will see Red Hat OpenShift Data Science Console.

<img width="733" alt="Screen Shot 2023-01-27 at 17 56 20" src="https://user-images.githubusercontent.com/18471537/215103960-051c0644-fa5b-4db3-bb56-274997c11206.png">

## 2) Create Jupyter Notebook Server

From the console, lunch the Jupyter notebook application and let's create a notebook to work on.

As you can see the notebook already come with different notebook server template to use that's optimized and liberaries are pre-installed so we can pick what we need or we can build our own custom template.

<img width="399" alt="Screen Shot 2023-01-27 at 17 59 12" src="https://user-images.githubusercontent.com/18471537/215104574-9890d109-713a-4d65-956d-bdb866c402ba.png">

Select options as above Tensor Flow and small as this is sandbox environment. Once the server is started, you need to check our the code by going to the Git section and pick clone the code

<img width="364" alt="Screen Shot 2023-01-27 at 18 02 03" src="https://user-images.githubusercontent.com/18471537/215105180-3a68a8a3-a200-49b1-9b3c-c3811d9e0223.png">

<img width="289" alt="Screen Shot 2023-01-27 at 18 03 26" src="https://user-images.githubusercontent.com/18471537/215105503-4625ef86-99f8-4164-b00e-6ceef0a0207c.png">
Clone our git repository: https://github.com/osa-ora/ml-sample-demo

## 3) ML Development & Testing 

You can now run the Notebook using the file : 02_License-plate-recognition.ipynb which contains all the logic to detect the car plate, go through it step by step to understand the logic.


<img width="516" alt="Screen Shot 2023-01-27 at 18 22 54" src="https://user-images.githubusercontent.com/18471537/215109459-1a47b4bf-b1c8-49d9-885a-af8d745dbcde.png">

You can upload any car images with a plate to the dataset/images folder and run the last notebook cell to test the detection of that new car as well.

Here you can write, modify, commit and test your ML app, and this comes fullt supported from Red Hat and optimized to work with the underlying capavilities such as GPUs (using Nvidia GPU OpenShift Operator).

Once you have a mature ML model, you can write your application to utilize it as in this example, all the previous cell codes are unified into a single prediction.py file, which can now be expose to do the prediction by using a flask Python app that can expose the APIs and route the request to the prediction application with a newly added predict function in prediction.py.  

<img width="403" alt="Screen Shot 2023-01-27 at 18 29 01" src="https://user-images.githubusercontent.com/18471537/215110784-68c42974-f4ef-4533-8298-a05f500e3327.png">

Check the flask application APIs in the file: wsgi.py. 

<img width="406" alt="Screen Shot 2023-01-27 at 18 29 40" src="https://user-images.githubusercontent.com/18471537/215110949-eebbe2f8-5405-4650-b24d-65ad0287e93b.png">

As you can see 2 APIs one is mapped to the root "/" which is used for healthcheck the application and it return ok, while the other APIs is mapped to "prediction" which send json input to the predict function in prediction.py.

Now, to run this application, you can use the file: 03_LPR_run_application.ipynb which will listen to API calls.
To test the application, open the 04_LPR_test_application.ipynb file and follow the instructions.

All the previous activities are part of developing a ML application, we assumed the dataset already gathered and the model already pre-built but you can modify, improve and change it for further experience this part of ML lifecyle.
In most of the cases these days most of the models are already written by different people or vendors and you can just optimize or update based on specific requirements.

## 4) ML Deployment

Once we have and ready ML application/APIs we need to experience how to deploy them on OpenShift.
You have 2 choices, one is utilizing the Source2Image OpenShift capability and give all the build process to OpenShift or build a pipeline so you can enrich the lifecycle and automate many parts and integrate many options such as security and others.

### Using Source2Image
Got to OpenShift console, select Add and then select from Git Repository:

<img width="179" alt="Screen Shot 2023-01-27 at 18 41 31" src="https://user-images.githubusercontent.com/18471537/215113469-8ef128f5-bf04-4f1c-8741-11da0d6cb864.png">

Provide the required details as following:
In the Git Repo URL field, enter: "https://github.com/osa-ora/ml-sample-demo"
Select "main" branch
From the Builder Image version list, select "Python 3.8-ubi7"
Resources type “Deployment”
Then click on create button.

Once created, click on the route to open the root which is mapped to the healthcheck API and we can see the status is ok.

Copy the route URL and invoke it with any car images that you have to test the application. (should be either png or jpg)

```
(echo -n '{"image": "'; base64 {IMAGE-NAME-HERE}; echo '"}') | curl -H "Content-Type: application/json" -d @- {{ROUTE-URL-HERE}/predictions

//if everything is okay it will return response like:
{"prediction":"63518"}
```

Now, we can enable our application to trigger the BuildConfig for our application so with any new Git commits, the application can be built and deployed automatically.

### Using OpenShift Pipeline
By using OpenShift Pipeline based on Tekton we can incorporate many options such as notification, testing, security scanning, etc.


```
/login to OpenShift cluster
oc login ...
//download the script
curl https://raw.githubusercontent.com/osa-ora/ml-sample-demo/main/script/init.sh > init.sh
chmod +x init.sh
//execute the script with 2 parameters: the name of "ML" project, and slack channel webhook url (to send notifications)
./init.sh ooransa-dev https://hooks.slack.co...{fill in your slack url here}

```
This will create and execute the pipeline in the specified project. If everything is configured properly, you will see something like:


<img width="1470" alt="Screen Shot 2023-01-27 at 16 50 13" src="https://user-images.githubusercontent.com/18471537/215119602-3bdf1d7f-9d35-431c-b501-35f80385e8a4.png">

Now, we can automate the build and deployment using the tekton pipeline for more efficient ML-OPs.



